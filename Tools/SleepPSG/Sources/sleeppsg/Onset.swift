import Foundation
import StrandAnalytics
import WhoopProtocol

// Onset — section 9: does NOOP's SESSION DETECTION put sleep onset and the final awakening where PSG does?
//
// Every other section stages a window it is handed (the labelled span). This one runs the SHIPPED detection
// end to end, `SleepStager.detectSleep` with V2 staging as the app runs it, over each sleep-accel subject's lab
// night with the hours around it, and compares three readouts with the PSG hypnogram:
//
//   in bed        the detected session's start: when the wrist went still
//   fell asleep   the session's first sleep segment, after `SleepStager.applyPersistentOnset`
//   woke          the end of its last sleep segment
//
// PSG sleep onset is the first of three consecutive non-wake epochs (the Rechtschaffen and Kales onset Nano et
// al., Front Neurosci 2020, used); the final awakening is the end of the last non-wake epoch. Lights out is
// the first scored epoch, so "in bed - lights out" says how well stillness finds the moment the subject lay
// down, and "fell asleep - PSG onset" is the error the wearer sees.
//
// One assumption, stated: the dataset gives no clock times, so lights out is placed at 23:00 local. Only the
// detector's daytime guards read the clock, and a 23:00 night is far from them.

enum OnsetReport {

    struct Night {
        let id: String
        let lightsOut: Int, lightsOn: Int
        let psgOnset: Int?, psgFinalWake: Int?
        let inBed: Int?, fellAsleep: Int?, woke: Int?
        let psgSleepMin: Double, noopSleepInWindowMin: Double?
    }

    /// The truth grid and the streams around it, `hoursBefore` lights out to `hoursAfter` lights on.
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
        let lightsOut = base + minT, lightsOn = base + maxT + 30

        func firstRun(_ n: Int) -> Int? {
            var run = 0
            for (i, l) in labels.enumerated() {
                if let l, l != "wake" { run += 1 } else { run = 0 }
                if run >= n { return lightsOut + (i - n + 1) * 30 }
            }
            return nil
        }
        let finalWake = labels.indices.reversed().first { labels[$0].map { $0 != "wake" } ?? false }
            .map { lightsOut + ($0 + 1) * 30 }

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
        let main = sessions.max {
            max(0, min($0.end, lightsOn) - max($0.start, lightsOut)) < max(0, min($1.end, lightsOn) - max($1.start, lightsOut))
        }
        let sleepSegs = main?.stages.filter { !SleepStageVocabulary.isWake($0.stage) }
        let asleepInWindow = sleepSegs.map { segs in
            Double(segs.reduce(0) { $0 + max(0, min($1.end, lightsOn) - max($1.start, lightsOut)) }) / 60
        }
        return Night(id: id, lightsOut: lightsOut, lightsOn: lightsOn,
                     psgOnset: firstRun(3), psgFinalWake: finalWake,
                     inBed: main?.start, fellAsleep: sleepSegs?.map(\.start).min(), woke: sleepSegs?.map(\.end).max(),
                     psgSleepMin: Double(labels.filter { $0 != nil && $0 != "wake" }.count) / 2,
                     noopSleepInWindowMin: asleepInWindow)
    }

    static func run(root: String, ids: [String]) {
        print("""

        ================================================================================
        9. SLEEP ONSET AND THE FINAL AWAKENING — the shipped detection against PSG
        ================================================================================
        NOOP's whole detection over each lab night with 6 h before and 3 h after it. Minutes; negative = early.
        """)
        var nights = [Night?](repeating: nil, count: ids.count)
        nights.withUnsafeMutableBufferPointer { buf in
            let out = buf
            DispatchQueue.concurrentPerform(iterations: ids.count) { out[$0] = load(root: root, id: ids[$0]) }
        }
        func m(_ a: Int?, _ b: Int?) -> Double? { guard let a, let b else { return nil }; return Double(a - b) / 60 }
        var inBedErr: [Double] = [], fellErr: [Double] = [], wokeErr: [Double] = [], tstErr: [Double] = []
        var trueLatency: [Double] = [], shownLatency: [Double] = []
        print("    subject    PSG latency   in bed-onset   fell asleep-onset   woke-final wake   sleep in window")
        for n in nights.compactMap({ $0 }) {
            guard let a = m(n.inBed, n.psgOnset), let b = m(n.fellAsleep, n.psgOnset), let c = m(n.woke, n.psgFinalWake),
                  let lat = m(n.psgOnset, n.lightsOut), let shown = m(n.fellAsleep, n.lightsOut),
                  let tst = n.noopSleepInWindowMin else {
                print("    \(n.id.padding(toLength: 10, withPad: " ", startingAt: 0)) no detected night"); continue
            }
            inBedErr.append(a); fellErr.append(b); wokeErr.append(c); tstErr.append(tst - n.psgSleepMin)
            trueLatency.append(lat); shownLatency.append(shown)
            print("    \(n.id.padding(toLength: 10, withPad: " ", startingAt: 0)) \(f(lat, 8, 1))      \(f(a, 8, 1))      "
                  + "\(f(b, 10, 1))          \(f(c, 8, 1))        \(f(tst - n.psgSleepMin, 8, 1))")
        }
        func line(_ name: String, _ v: [Double]) {
            guard !v.isEmpty else { return }
            let within = v.filter { abs($0) <= 15 }.count
            print("    \(name.padding(toLength: 34, withPad: " ", startingAt: 0)) bias \(f(mean(v), 6, 1))   "
                  + "median \(f(median(v), 6, 1))   MAE \(f(mean(v.map(abs)), 5, 1))   within 15 min \(within)/\(v.count)")
        }
        print("")
        line("in bed (start) vs PSG onset", inBedErr)
        line("fell asleep vs PSG onset", fellErr)
        line("woke vs PSG final awakening", wokeErr)
        line("sleep inside lights-out window", tstErr)
        print("    PSG latency median \(f(median(trueLatency), 5, 1)) min (range \(f(trueLatency.min() ?? 0, 4, 1))–"
              + "\(f(trueLatency.max() ?? 0, 4, 1))); shown latency median \(f(median(shownLatency), 5, 1))")
    }
}
