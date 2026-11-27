import XCTest
@testable import StrandAnalytics
import WhoopProtocol

/// Pins `SleepStager.applyWakeRescoring`: Webster's rescoring rules (Webster et al., Sleep 1982) and the
/// night's final awakening at the end of its last 10 minutes of unbroken sleep. The oracle literals below are
/// the ones the Kotlin twin (`SleepWakeRescoringTest`) asserts, from the same generator, so the two cannot
/// drift.
final class SleepWakeRescoringTests: XCTestCase {

    private func wakeRuleSeg(_ start: Int, _ end: Int, _ stage: String) -> StageSegment {
        StageSegment(start: start, end: end, stage: stage)
    }

    private func wakeRuleLine(_ segs: [StageSegment]) -> String {
        segs.map { "\($0.start)-\($0.end):\($0.stage)" }.joined(separator: ";")
    }

    private let t = 1_700_000_000

    func testAfterFourMinutesAwakeTheNextMinuteOfSleepIsAwake() {
        let night = [wakeRuleSeg(t, t + 1_800, "light"), wakeRuleSeg(t + 1_800, t + 2_100, "wake"),
                     wakeRuleSeg(t + 2_100, t + 3_900, "light")]
        XCTAssertEqual(wakeRuleLine(SleepStager.applyWakeRescoring(night)),
                       "\(t)-\(t + 1_800):light;\(t + 1_800)-\(t + 2_160):wake;\(t + 2_160)-\(t + 3_900):light")
    }

    func testAfterTenAndFifteenMinutesAwakeThreeAndFourMinutesAreAwake() {
        let ten = [wakeRuleSeg(t, t + 1_800, "deep"), wakeRuleSeg(t + 1_800, t + 2_520, "wake"),
                   wakeRuleSeg(t + 2_520, t + 4_320, "rem")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(ten)[1], wakeRuleSeg(t + 1_800, t + 2_700, "wake"))
        let fifteen = [wakeRuleSeg(t, t + 1_800, "deep"), wakeRuleSeg(t + 1_800, t + 2_760, "wake"),
                       wakeRuleSeg(t + 2_760, t + 4_560, "rem")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(fifteen)[1], wakeRuleSeg(t + 1_800, t + 3_000, "wake"))
    }

    func testAShortSleepInsideLongWakeIsAwake() {
        // 5 minutes of sleep between 11-minute wakes (rule d), then the night's real sleep.
        let d = [wakeRuleSeg(t, t + 1_800, "light"), wakeRuleSeg(t + 1_800, t + 2_460, "wake"),
                 wakeRuleSeg(t + 2_460, t + 2_760, "light"), wakeRuleSeg(t + 2_760, t + 3_420, "wake"),
                 wakeRuleSeg(t + 3_420, t + 5_220, "light")]
        XCTAssertEqual(wakeRuleLine(SleepStager.applyWakeRescoring(d)),
                       "\(t)-\(t + 1_800):light;\(t + 1_800)-\(t + 3_600):wake;\(t + 3_600)-\(t + 5_220):light")
        // 8 minutes between 21-minute wakes is wake (rule e); between 11-minute wakes only its first 3 go.
        let e = [wakeRuleSeg(t, t + 1_800, "light"), wakeRuleSeg(t + 1_800, t + 3_060, "wake"),
                 wakeRuleSeg(t + 3_060, t + 3_540, "rem"), wakeRuleSeg(t + 3_540, t + 4_800, "wake"),
                 wakeRuleSeg(t + 4_800, t + 6_600, "light")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(e)[1], wakeRuleSeg(t + 1_800, t + 5_040, "wake"))
        let notE = [wakeRuleSeg(t, t + 1_800, "light"), wakeRuleSeg(t + 1_800, t + 2_460, "wake"),
                    wakeRuleSeg(t + 2_460, t + 2_940, "rem"), wakeRuleSeg(t + 2_940, t + 3_600, "wake"),
                    wakeRuleSeg(t + 3_600, t + 5_400, "light")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(notE)[2], wakeRuleSeg(t + 2_640, t + 2_940, "rem"))
    }

    func testTheNightEndsAtItsLastTenMinutesOfSleep() {
        // An hour asleep, awake 3 minutes, 6 minutes of sleep, awake again: the night ended at the first wake.
        let night = [wakeRuleSeg(t, t + 3_600, "light"), wakeRuleSeg(t + 3_600, t + 3_780, "wake"),
                     wakeRuleSeg(t + 3_780, t + 4_140, "light"), wakeRuleSeg(t + 4_140, t + 4_500, "wake")]
        XCTAssertEqual(wakeRuleLine(SleepStager.applyWakeRescoring(night)),
                       "\(t)-\(t + 3_600):light;\(t + 3_600)-\(t + 4_500):wake")
        // Ten minutes after the brief wake is a real return to sleep: the night ends after it.
        let back = [wakeRuleSeg(t, t + 3_600, "light"), wakeRuleSeg(t + 3_600, t + 3_780, "wake"),
                    wakeRuleSeg(t + 3_780, t + 4_380, "rem"), wakeRuleSeg(t + 4_380, t + 4_500, "wake")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(back), back)
    }

    func testANightWithoutWakeOrPersistentSleepKeepsItsSleep() {
        let asleep = [wakeRuleSeg(t, t + 1_800, "light"), wakeRuleSeg(t + 1_800, t + 3_000, "deep")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(asleep), asleep)
        // Short sleeps with brief wakes and no 10-minute run: nothing is deleted.
        let short = [wakeRuleSeg(t, t + 300, "light"), wakeRuleSeg(t + 300, t + 420, "wake"),
                     wakeRuleSeg(t + 420, t + 840, "rem")]
        XCTAssertEqual(SleepStager.applyWakeRescoring(short), short)
    }

    /// Every night `detectSleep` returns obeys the rule: its last sleep run lasts at least 10 minutes. An
    /// invariant only: this still synthetic night ends on a long run either way. That `detectSleep` applies
    /// the rule is proven on 31 PSG nights by `Tools/SleepPSG --section waso` (its port check).
    func testDetectedNightsEndOnAPersistentRun() {
        let refMidnight = 1_749_513_600
        let start = refMidnight + 2 * 3_600
        let dur = 3 * 3_600
        let grav = (0..<dur).map { GravitySample(ts: start + $0, x: 0, y: 0, z: 1.0) }
        let hr = (0..<dur).map { HRSample(ts: start + $0, bpm: $0 < 1_800 ? 62 : 50) }
        let sessions = SleepStager.detectSleep(hr: hr, gravity: grav, useSleepStagerV2: true)
        XCTAssertFalse(sessions.isEmpty)
        for s in sessions {
            let sorted = s.stages.sorted { $0.start < $1.start }
            guard let i = sorted.lastIndex(where: { !SleepStageVocabulary.isWake($0.stage) }) else { continue }
            var begin = sorted[i].start
            var j = i - 1
            while j >= 0, !SleepStageVocabulary.isWake(sorted[j].stage) { begin = sorted[j].start; j -= 1 }
            XCTAssertGreaterThanOrEqual(sorted[i].end - begin, SleepStager.persistentSleepMin * 60)
        }
    }

    // MARK: - The oracle (shared with Kotlin)

    private var wakeRuleLcg: UInt64 = 0xD1B54A32D192ED03

    private func wakeRuleNext(_ n: Int) -> Int {
        wakeRuleLcg = wakeRuleLcg &* 6364136223846793005 &+ 1442695040888963407
        return Int((wakeRuleLcg >> 33) % UInt64(n))
    }

    func testMatchesTheKotlinOracleOverFiveThousandRandomNights() {
        let stageNames = ["wake", "light", "deep", "rem", "awake", "AWAKE", "light", "wake"]
        let persists = [600, 300, 900]
        var h: UInt64 = 0xcbf29ce484222325
        var cases: [String] = []
        for _ in 0..<5000 {
            let n = 1 + wakeRuleNext(24)
            var start = 1_700_000_000 + wakeRuleNext(1000) * 30
            var segs: [StageSegment] = []
            for _ in 0..<n {
                if wakeRuleNext(8) == 0 { start += wakeRuleNext(5) * 30 }
                let d = (1 + wakeRuleNext(50)) * 30
                segs.append(wakeRuleSeg(start, start + d, stageNames[wakeRuleNext(stageNames.count)]))
                start += d
            }
            if segs.count > 1 && wakeRuleNext(5) == 0 {
                let a = wakeRuleNext(segs.count), b = wakeRuleNext(segs.count)
                segs.swapAt(a, b)
            }
            if segs.count > 1 && wakeRuleNext(10) == 0 {
                let k = 1 + wakeRuleNext(segs.count - 1)
                segs[k].start = segs[k - 1].start
            }
            let p = persists[wakeRuleNext(persists.count)]
            let input = wakeRuleLine(segs)
            let out = wakeRuleLine(SleepStager.applyWakeRescoring(segs, minPersistS: p))
            for byte in out.utf8 { h ^= UInt64(byte); h = h &* 0x100000001b3 }
            h ^= 0x0A; h = h &* 0x100000001b3
            if cases.count < 3 { cases.append("\(p)|\(input)=>\(out)") }
        }
        XCTAssertEqual(cases.count, 3)
        XCTAssertEqual(cases.last ?? "",
                       "600|1700020970-1700022230:wake;1700022230-1700022770:light;1700022770-1700023190:light;"
                       + "1700023190-1700024420:awake;1700024420-1700024900:AWAKE=>1700020970-1700022470:wake;"
                       + "1700022470-1700023190:light;1700023190-1700024420:awake;1700024420-1700024900:AWAKE")
        XCTAssertEqual(String(format: "%016llx", h), "2414143cc0221255")
    }
}
