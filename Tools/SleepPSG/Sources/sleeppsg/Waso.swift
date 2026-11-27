import Foundation
import StrandAnalytics
import WhoopProtocol

// Waso — section 10: where does the shipped detection's extra sleep come from, and which published rule
// takes it back without calling real sleep wake?
//
// Section 9 found total sleep about 20 minutes too high against PSG. This section splits that error by where
// it sits in the night, epoch by epoch against the hypnogram, over each lab night's lights-out window:
//
//   before onset     PSG wake before PSG sleep onset that NOOP called sleep (the onset rule's territory)
//   inside           PSG wake between onset and the final awakening that NOOP called sleep (missed WASO),
//                    and PSG sleep there that NOOP called wake (false wake)
//   after waking     PSG wake after the final awakening that NOOP called sleep (the "woke" time's error)
//
// Then it scores rules applied to the SAME detected nights, each chosen from the literature before measuring,
// subject by subject (every subject counts once). A rule is worth shipping only if it lowers the total-sleep
// error for most subjects AND raises per-subject sleep/wake agreement (Cohen's kappa) for most of them,
// without turning real sleep into wake: the #348/#437 trap, where a pooled wake share looked better while the
// typical subject got worse.
//
// The lights-out assumption of section 9 holds here too (23:00 local; only daytime guards read the clock).

enum WasoReport {

    struct Night {
        let id: String
        let lightsOut: Int
        /// PSG label per 30 s epoch from lights out; nil = unscored.
        let labels: [String?]
        /// Index of PSG sleep onset (first of three non-wake epochs) and of the last non-wake epoch.
        let onsetIdx: Int?, finalIdx: Int?
        let session: SleepSession?
        let hr: [HRSample]
        let grav: [GravitySample]
    }

    static func load(root: String, id: String, hoursBefore: Int = 6, hoursAfter: Int = 3) -> Night? {
        let labelRows = SleepAccel.readRows((root as NSString)
            .appendingPathComponent("labels/\(id)_labeled_sleep.txt"), expecting: 2)
        var byEpoch: [Int: String] = [:]
        var minT = Int.max, maxT = Int.min
        for r in labelRows {
            let t = Int((r[0] / 30.0).rounded()) * 30
            guard let stage = SleepAccel.stageForCode(Int(r[1].rounded())) else { continue }
            byEpoch[t] = stage
            minT = min(minT, t); maxT = max(maxT, t)
        }
        guard minT != Int.max else { return nil }
        var labels = [String?](repeating: nil, count: (maxT - minT) / 30 + 1)
        for (t, s) in byEpoch { labels[(t - minT) / 30] = s }
        let base = SleepAccel.timeBase
        let lightsOut = base + minT

        var onsetIdx: Int? = nil
        var run = 0
        for (i, l) in labels.enumerated() {
            if let l, l != "wake" { run += 1 } else { run = 0 }
            if run >= 3 { onsetIdx = i - 2; break }
        }
        let finalIdx = labels.indices.reversed().first { labels[$0].map { $0 != "wake" } ?? false }

        let lo = minT - hoursBefore * 3_600, hi = maxT + 30 + hoursAfter * 3_600
        let hr = SleepAccel.readRows((root as NSString).appendingPathComponent("heart_rate/\(id)_heartrate.txt"),
                                     expecting: 2)
            .compactMap { r -> HRSample? in
                let bpm = Int(r[1].rounded()), sec = SleepAccel.wholeSecond(r[0])
                guard bpm > 0, bpm < 300, sec >= lo, sec < hi else { return nil }
                return HRSample(ts: base + sec, bpm: bpm)
            }
            .sorted { $0.ts < $1.ts }
        let grav = SleepAccel.readAccelerationPerSecond(
            (root as NSString).appendingPathComponent("motion/\(id)_acceleration.txt"), loSec: lo, hiSec: hi)
        let tz = ((23 * 3_600 - (lightsOut % 86_400)) % 86_400 + 86_400) % 86_400
        let sessions = SleepStager.detectSleep(hr: hr, gravity: grav, tzOffsetSeconds: tz, useSleepStagerV2: true)
        let lightsOn = lightsOut + labels.count * 30
        let main = sessions.max {
            max(0, min($0.end, lightsOn) - max($0.start, lightsOut)) < max(0, min($1.end, lightsOn) - max($1.start, lightsOut))
        }
        return Night(id: id, lightsOut: lightsOut, labels: labels, onsetIdx: onsetIdx, finalIdx: finalIdx,
                     session: main, hr: hr, grav: grav)
    }

    // MARK: - Rules under test (each applied to a session's stages; pure)

    /// The session's stages as one sleep (true) / wake (false) flag per 30 s epoch from `start`.
    static func epochFlags(_ stages: [StageSegment], start: Int, end: Int) -> [Bool] {
        let n = max(0, (end - start + 29) / 30)
        var flags = [Bool](repeating: false, count: n)
        for s in stages where !SleepStageVocabulary.isWake(s.stage) {
            var t = s.start
            while t < s.end {
                let i = (t - start) / 30
                if i >= 0 && i < n { flags[i] = true }
                t += 30
            }
        }
        return flags
    }

    /// Re-label as wake the sleep epochs a flag array marks false, keeping every stage name otherwise.
    static func relabel(_ stages: [StageSegment], start: Int, keep: [Bool]) -> [StageSegment] {
        var out: [StageSegment] = []
        for s in stages {
            var t = s.start
            while t < s.end {
                let i = (t - start) / 30
                let stage = (!SleepStageVocabulary.isWake(s.stage) && i >= 0 && i < keep.count && !keep[i])
                    ? "wake" : s.stage
                let segEnd = min(s.end, start + (i + 1) * 30)
                if let last = out.last, last.stage == stage, last.end == t {
                    out[out.count - 1].end = segEnd
                } else {
                    out.append(StageSegment(start: t, end: segEnd, stage: stage))
                }
                t = segEnd
            }
        }
        return out
    }

    /// Webster's rescoring rules (Webster et al., Sleep 1982;5:389-399, as applied by Cole et al., Sleep
    /// 1992;15:461-469), in minutes, on 30 s epochs: after at least 4 min of wake the next 1 min of sleep is
    /// wake; after 10 min, the next 3; after 15 min, the next 4; a sleep run of 6 min or less with at least
    /// 10 min of wake on both sides is wake; a sleep run of 10 min or less with 20 min on both sides is wake.
    static func webster(_ flags: [Bool]) -> [Bool] {
        var out = flags
        let n = flags.count
        // (a)–(c): the sleep epochs right after a long enough wake run.
        var i = 0
        while i < n {
            guard !flags[i] else { i += 1; continue }
            var j = i
            while j < n && !flags[j] { j += 1 }
            let wakeMin = Double(j - i) / 2
            let rescore = wakeMin >= 15 ? 8 : wakeMin >= 10 ? 6 : wakeMin >= 4 ? 2 : 0
            var k = j
            while k < n && k < j + rescore && flags[k] { out[k] = false; k += 1 }
            i = j
        }
        // (d), (e): short sleep runs inside long wake (judged on the original flags).
        i = 0
        while i < n {
            guard flags[i] else { i += 1; continue }
            var j = i
            while j < n && flags[j] { j += 1 }
            let runMin = Double(j - i) / 2
            var before = 0, b = i - 1
            while b >= 0 && !flags[b] { before += 1; b -= 1 }
            var after = 0, a = j
            while a < n && !flags[a] { after += 1; a += 1 }
            let bMin = Double(before) / 2, aMin = Double(after) / 2
            if (runMin <= 6 && bMin >= 10 && aMin >= 10) || (runMin <= 10 && bMin >= 20 && aMin >= 20) {
                for k in i..<j { out[k] = false }
            }
            i = j
        }
        return out
    }

    /// Webster's rules inside the night only: the wake run that opens the session (in bed before the persistent
    /// onset) does not rescore the sleep after it, so the onset rule alone places "fell asleep".
    static func websterInside(_ flags: [Bool]) -> [Bool] {
        guard let first = flags.firstIndex(of: true) else { return flags }
        var head = flags
        for k in 0..<first { head[k] = true }   // hide the opening wake run from the rules
        var out = webster(head)
        for k in 0..<first { out[k] = false }
        return out
    }

    /// The night ends where its last `minPersistEpochs` of unbroken sleep end: later sleep runs shorter than
    /// that are wake. The mirror of the persistent onset.
    static func persistentFinal(_ flags: [Bool], minPersistEpochs: Int = 20) -> [Bool] {
        var out = flags
        var j = flags.count - 1
        while j >= 0 {
            guard flags[j] else { j -= 1; continue }
            var i = j
            while i >= 0 && flags[i] { i -= 1 }
            if j - i >= minPersistEpochs { return out }
            for k in (i + 1)...j { out[k] = false }
            j = i
        }
        return flags   // no persistent run at all: leave the night as it was
    }

    // MARK: - Scoring against PSG

    struct Score {
        var preFalseSleep = 0.0, inFalseSleep = 0.0, inFalseWake = 0.0, postFalseSleep = 0.0
        var psgInWake = 0.0, psgTST = 0.0, noopTST = 0.0
        var kappa = 0.0, wakeSens = 0.0, sleepSens = 0.0
        var wokeErr: Double? = nil
        var fellErr: Double? = nil
        var tstErr: Double { noopTST - psgTST }
    }

    static func score(_ night: Night, stages: [StageSegment]?) -> Score {
        var sc = Score()
        let n = night.labels.count
        var noop = [Bool](repeating: false, count: n)
        if let stages, let s = night.session {
            let flags = epochFlags(stages, start: s.start, end: s.end)
            for i in 0..<n {
                let t = night.lightsOut + i * 30 + 15
                let k = (t - s.start) / 30
                if t >= s.start, k >= 0, k < flags.count { noop[i] = flags[k] }
            }
            let lastSleepEnd = stages.filter { !SleepStageVocabulary.isWake($0.stage) }.map(\.end).max()
            if let lastSleepEnd, let fi = night.finalIdx {
                sc.wokeErr = Double(lastSleepEnd - (night.lightsOut + (fi + 1) * 30)) / 60
            }
            let firstSleep = stages.filter { !SleepStageVocabulary.isWake($0.stage) }.map(\.start).min()
            if let firstSleep, let oi = night.onsetIdx {
                sc.fellErr = Double(firstSleep - (night.lightsOut + oi * 30)) / 60
            }
        }
        var tp = 0.0, tn = 0.0, fp = 0.0, fn = 0.0   // positive = sleep
        for i in 0..<n {
            guard let l = night.labels[i] else { continue }
            let psgSleep = l != "wake", ns = noop[i]
            if psgSleep { sc.psgTST += 0.5 }
            if ns { sc.noopTST += 0.5 }
            switch (psgSleep, ns) {
            case (true, true): tp += 1
            case (false, false): tn += 1
            case (false, true): fp += 1
            case (true, false): fn += 1
            }
            let before = night.onsetIdx.map { i < $0 } ?? true
            let after = night.finalIdx.map { i > $0 } ?? false
            if !psgSleep && ns {
                if before { sc.preFalseSleep += 0.5 } else if after { sc.postFalseSleep += 0.5 } else { sc.inFalseSleep += 0.5 }
            }
            if !before && !after {
                if !psgSleep { sc.psgInWake += 0.5 }
                if psgSleep && !ns { sc.inFalseWake += 0.5 }
            }
        }
        let tot = tp + tn + fp + fn
        if tot > 0 {
            let po = (tp + tn) / tot
            let pe = ((tp + fp) * (tp + fn) + (tn + fn) * (tn + fp)) / (tot * tot)
            sc.kappa = pe < 1 ? (po - pe) / (1 - pe) : 0
        }
        sc.wakeSens = (tn + fp) > 0 ? tn / (tn + fp) : .nan
        sc.sleepSens = (tp + fn) > 0 ? tp / (tp + fn) : .nan
        return sc
    }

    // MARK: - Report

    static func run(root: String, ids: [String]) {
        print("""

        ================================================================================
        10. WAKE INSIDE THE NIGHT — where the extra sleep sits, and the rules that take part of it back
        ================================================================================
        The detection over each lab night (section 9's nights), compared epoch by epoch with PSG inside lights
        out. Minutes per night; "false sleep" = PSG wake that NOOP called sleep. "Before" is the night as it was
        staged before `SleepStager.applyWakeRescoring` (V2 staging and the persistent onset); "shipped" is
        `detectSleep` as it is compiled here.
        """)
        var nights = [Night?](repeating: nil, count: ids.count)
        nights.withUnsafeMutableBufferPointer { buf in
            let out = buf
            DispatchQueue.concurrentPerform(iterations: ids.count) { out[$0] = load(root: root, id: ids[$0]) }
        }
        let ok = nights.compactMap { $0 }.filter { $0.session != nil }
        func beforeStages(_ n: Night, motion: Bool = true) -> [StageSegment]? {
            guard let s = n.session else { return nil }
            return SleepStager.applyPersistentOnset(V2Recipe.stageSession(start: s.start, end: s.end,
                                                                          grav: motion ? n.grav : [], hr: n.hr,
                                                                          rr: [], resp: []))
        }
        let beforeSegs = ok.map { beforeStages($0) }
        let before = zip(ok, beforeSegs).map { score($0, stages: $1) }

        // The decomposition, before the rules.
        print("    subject    TST err   before onset   inside: missed wake / false wake (PSG wake)   after waking   kappa")
        for (n, s) in zip(ok, before) {
            print("    \(n.id.padding(toLength: 10, withPad: " ", startingAt: 0)) \(f(s.tstErr, 7, 1))   \(f(s.preFalseSleep, 8, 1))"
                  + "       \(f(s.inFalseSleep, 8, 1)) / \(f(s.inFalseWake, 5, 1))  (\(f(s.psgInWake, 5, 1)))"
                  + "               \(f(s.postFalseSleep, 8, 1))     \(f(s.kappa, 5, 3))")
        }
        func avg(_ k: KeyPath<Score, Double>, _ v: [Score]) -> Double { mean(v.map { $0[keyPath: k] }) }
        print("""

            mean per night: TST error \(f(avg(\.tstErr, before), 5, 1)) = before onset \(f(avg(\.preFalseSleep, before), 4, 1))
              + inside missed wake \(f(avg(\.inFalseSleep, before), 4, 1)) − inside false wake \(f(avg(\.inFalseWake, before), 4, 1))
              + after waking \(f(avg(\.postFalseSleep, before), 4, 1)) − false wake outside the sleep period (rest)
            PSG wake inside the sleep period: mean \(f(avg(\.psgInWake, before), 4, 1)) min a night; NOOP found
              \(f(100 * (1 - avg(\.inFalseSleep, before) / max(0.0001, avg(\.psgInWake, before))), 4, 0)) % of it.
        """)

        // How much of the missed wake inside the night had any wrist movement at all.
        var missedMoving = 0.0, missedStill = 0.0
        for (n, segs) in zip(ok, beforeSegs) {
            guard let s = n.session, let segs, let onset = n.onsetIdx, let fin = n.finalIdx else { continue }
            let det = V2Recipe.stageEpochsDetailed(start: s.start, end: s.end, grav: n.grav, hr: n.hr, rr: [], resp: [])
            var moved: [Int: Bool] = [:]
            for e in det.epochs {
                moved[e.start] = e.moveFrac > 0 || e.jerkMax > e.jerkScale * RecipeConfig.shipped.jerkFloorGateMult
            }
            let flags = epochFlags(segs, start: s.start, end: s.end)
            for i in onset...fin {
                guard n.labels[i] == "wake" else { continue }
                let t = n.lightsOut + i * 30 + 15
                let k = (t - s.start) / 30
                guard t >= s.start, k >= 0, k < flags.count, flags[k] else { continue }
                if moved[(t / 30) * 30] ?? false { missedMoving += 0.5 } else { missedStill += 0.5 }
            }
        }
        print("""
            Of the wake NOOP missed inside the sleep period, \(f(100 * missedStill / max(0.0001, missedMoving + missedStill), 4, 0)) % came in epochs where the wrist
              did not move at all (quiet wakefulness: the wrist's known limit, Marino et al., Sleep 2013).
        """)

        // Rules on the same nights, each scored against "before".
        func viaFlags(_ segs: [StageSegment]?, _ n: Night, _ rule: ([Bool]) -> [Bool]) -> [StageSegment]? {
            guard let s = n.session, let segs else { return nil }
            return relabel(segs, start: s.start, keep: rule(epochFlags(segs, start: s.start, end: s.end)))
        }
        func row(_ name: String, _ v: [Score], against base: [Score]) {
            let betterT = zip(v, base).filter { abs($0.tstErr) < abs($1.tstErr) - 0.25 }.count
            let worseT = zip(v, base).filter { abs($0.tstErr) > abs($1.tstErr) + 0.25 }.count
            let betterK = zip(v, base).filter { $0.kappa > $1.kappa + 0.0005 }.count
            let worseK = zip(v, base).filter { $0.kappa < $1.kappa - 0.0005 }.count
            let woke = v.compactMap(\.wokeErr)
            let under = v.filter { $0.tstErr < -15 }.count
            print("    \(name.padding(toLength: 36, withPad: " ", startingAt: 0)) \(f(avg(\.tstErr, v), 6, 1))  \(f(mean(v.map { abs($0.tstErr) }), 6, 1))"
                  + "      \(String(format: "%2d/%2d", betterT, worseT))     \(f(avg(\.kappa, v), 5, 3))   \(String(format: "%2d/%2d", betterK, worseK))"
                  + "      \(f(100 * mean(v.map(\.wakeSens).filter { !$0.isNaN }), 4, 1)) %    \(f(100 * mean(v.map(\.sleepSens).filter { !$0.isNaN }), 4, 1)) %"
                  + "    \(f(mean(woke), 5, 1)) (\(f(median(woke), 5, 1)))      \(under)"
                  + "        \(f(mean(v.compactMap(\.fellErr)), 5, 1)) (\(f(mean(v.compactMap(\.fellErr).map(abs)), 4, 1)))")
            for (n, x) in zip(ok, v) where x.tstErr < -15 {
                print("        under by more than 15 min: \(n.id) \(f(x.tstErr, 6, 1))")
            }
        }
        var clampOff = RecipeConfig.shipped
        clampOff.motionQuiescentClamp = false
        let shipped = ok.map { score($0, stages: $0.session?.stages) }
        print("""

            Rules applied to the same nights (n = \(ok.count)). Per subject against "before": better / worse.
            rule                                  TST err  |TST err|  better/worse  kappa  better/worse  wake found  sleep kept  woke err (median)  TST < -15  fell asleep err (MAE)
        """)
        row("before (onset rule only)", before, against: before)
        row("Webster rescoring (1982)", zip(ok, beforeSegs).map { score($0, stages: viaFlags($1, $0) { webster($0) }) }, against: before)
        row("night ends at last 10 min of sleep", zip(ok, beforeSegs).map { score($0, stages: viaFlags($1, $0) { persistentFinal($0) }) }, against: before)
        row("Webster + last 10 min (this tool)", zip(ok, beforeSegs).map { score($0, stages: viaFlags($1, $0) { persistentFinal(webster($0)) }) }, against: before)
        row("SHIPPED (applyWakeRescoring)", shipped, against: before)
        row("Webster inside the night only", zip(ok, beforeSegs).map { score($0, stages: viaFlags($1, $0) { websterInside($0) }) }, against: before)
        row("  robustness: last 5 min", zip(ok, beforeSegs).map { score($0, stages: viaFlags($1, $0) { persistentFinal(webster($0), minPersistEpochs: 10) }) }, against: before)
        row("  robustness: last 15 min", zip(ok, beforeSegs).map { score($0, stages: viaFlags($1, $0) { persistentFinal(webster($0), minPersistEpochs: 30) }) }, against: before)
        row("still-wrist HR clamp off (diagnostic)", ok.map { n in
            score(n, stages: n.session.map { s in SleepStager.applyPersistentOnset(V2Recipe.stageSession(
                start: s.start, end: s.end, grav: n.grav, hr: n.hr, rr: [], resp: [], cfg: clampOff)) })
        }, against: before)

        // The heart-rate-only path (no motion stream): the same nights staged without gravity.
        let hrOnly = ok.map { beforeStages($0, motion: false) }
        let hrBefore = zip(ok, hrOnly).map { score($0, stages: $1) }
        print("\n    Heart rate only (the path for a night with no motion stream), same session bounds:")
        row("HR only, onset rule", hrBefore, against: hrBefore)
        row("HR only + applyWakeRescoring", zip(ok, hrOnly).map { score($0, stages: $1.map { SleepStager.applyWakeRescoring($0) }) }, against: hrBefore)

        // Port check: the shipped function equals this tool's epoch rules on every night.
        var same = 0
        for (n, segs) in zip(ok, beforeSegs) {
            guard let s = n.session, let segs else { continue }
            let mine = epochFlags(relabel(segs, start: s.start, keep: persistentFinal(webster(epochFlags(segs, start: s.start, end: s.end)))),
                                  start: s.start, end: s.end)
            if mine == epochFlags(s.stages, start: s.start, end: s.end)
                && mine == epochFlags(SleepStager.applyWakeRescoring(segs), start: s.start, end: s.end) { same += 1 }
        }
        print("""

            Port check: the shipped detection and `applyWakeRescoring` equal this tool's epoch rules on \(same) of \(ok.count) nights.
            better/worse count subjects whose |TST error| moved by more than 15 s, or kappa by more than 0.0005.
            "wake found" = PSG wake epochs NOOP called wake; "sleep kept" = PSG sleep epochs NOOP called sleep.
            "TST < -15" counts subjects whose sleep NOOP now UNDER-states by more than 15 minutes.
        """)
    }
}
