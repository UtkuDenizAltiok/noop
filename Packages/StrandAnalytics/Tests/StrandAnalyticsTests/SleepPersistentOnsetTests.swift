import XCTest
@testable import StrandAnalytics
import WhoopProtocol

/// Pins `SleepStager.applyPersistentOnset`: a night's sleep starts at its first 10 minutes of unbroken staged
/// sleep (latency to persistent sleep). The oracle literals below are the ones the Kotlin twin
/// (`SleepPersistentOnsetTest`) asserts, from the same generator, so the two cannot drift.
final class SleepPersistentOnsetTests: XCTestCase {

    private func onsetSeg(_ start: Int, _ end: Int, _ stage: String) -> StageSegment {
        StageSegment(start: start, end: end, stage: stage)
    }

    private func onsetLine(_ segs: [StageSegment]) -> String {
        segs.map { "\($0.start)-\($0.end):\($0.stage)" }.joined(separator: ";")
    }

    func testBeforeTheFirstTenUnbrokenMinutesIsAwake() {
        let t = 1_700_000_000
        let night = [onsetSeg(t, t + 300, "light"), onsetSeg(t + 300, t + 420, "wake"),
                     onsetSeg(t + 420, t + 660, "light"), onsetSeg(t + 660, t + 720, "wake"),
                     onsetSeg(t + 720, t + 1500, "light"), onsetSeg(t + 1500, t + 2520, "deep")]
        XCTAssertEqual(onsetLine(SleepStager.applyPersistentOnset(night)),
                       "\(t)-\(t + 720):wake;\(t + 720)-\(t + 1500):light;\(t + 1500)-\(t + 2520):deep")
    }

    func testANightAlreadyAsleepFromItsStartIsUnchanged() {
        let t = 1_700_000_000
        let night = [onsetSeg(t, t + 900, "light"), onsetSeg(t + 900, t + 1200, "wake"),
                     onsetSeg(t + 1200, t + 1800, "rem")]
        XCTAssertEqual(SleepStager.applyPersistentOnset(night), night)
    }

    func testANightWithNoPersistentRunIsUnchanged() {
        let t = 1_700_000_000
        let night = [onsetSeg(t, t + 300, "light"), onsetSeg(t + 300, t + 360, "wake"),
                     onsetSeg(t + 360, t + 800, "rem")]
        XCTAssertEqual(SleepStager.applyPersistentOnset(night), night)
    }

    func testTheRuleIsTenMinutes() {
        XCTAssertEqual(SleepStager.persistentSleepMin, 10)
        let t = 1_700_000_000
        // 9.5 minutes of sleep, a minute awake, then 10 minutes: onset is the second run.
        let night = [onsetSeg(t, t + 570, "light"), onsetSeg(t + 570, t + 630, "wake"),
                     onsetSeg(t + 630, t + 1230, "light")]
        XCTAssertEqual(SleepStager.applyPersistentOnset(night).first?.end, t + 630)
    }

    /// Every night `detectSleep` returns obeys the rule: its first sleep segment begins a persistent run.
    func testDetectedNightsStartSleepAtAPersistentRun() {
        let refMidnight = 1_749_513_600
        let start = refMidnight + 2 * 3_600
        let dur = 3 * 3_600
        // Still all night; low heart rate.
        let grav = (0..<dur).map { GravitySample(ts: start + $0, x: 0, y: 0, z: 1.0) }
        let hr = (0..<dur).map { HRSample(ts: start + $0, bpm: $0 < 1_800 ? 62 : 50) }
        let sessions = SleepStager.detectSleep(hr: hr, gravity: grav, useSleepStagerV2: true)
        XCTAssertFalse(sessions.isEmpty)
        for s in sessions {
            let sorted = s.stages.sorted { $0.start < $1.start }
            guard let i = sorted.firstIndex(where: { !SleepStageVocabulary.isWake($0.stage) }) else { continue }
            var end = sorted[i].end
            var j = i + 1
            while j < sorted.count, !SleepStageVocabulary.isWake(sorted[j].stage) { end = sorted[j].end; j += 1 }
            XCTAssertGreaterThanOrEqual(end - sorted[i].start, SleepStager.persistentSleepMin * 60)
        }
    }

    // MARK: - The oracle (shared with Kotlin)

    private var onsetLcg: UInt64 = 0x9E3779B97F4A7C15

    private func onsetNext(_ n: Int) -> Int {
        onsetLcg = onsetLcg &* 6364136223846793005 &+ 1442695040888963407
        return Int((onsetLcg >> 33) % UInt64(n))
    }

    func testMatchesTheKotlinOracleOverFiveThousandRandomNights() {
        let stageNames = ["wake", "light", "deep", "rem", "awake", "AWAKE", "light", "rem"]
        let persists = [600, 300, 900]
        var h: UInt64 = 0xcbf29ce484222325
        var first: [String] = []
        for i in 0..<5000 {
            let n = 1 + onsetNext(12)
            var t = 1_700_000_000 + onsetNext(1000) * 30
            var segs: [StageSegment] = []
            for _ in 0..<n {
                if onsetNext(8) == 0 { t += onsetNext(5) * 30 }
                let d = (1 + onsetNext(40)) * 30
                segs.append(onsetSeg(t, t + d, stageNames[onsetNext(stageNames.count)]))
                t += d
            }
            if segs.count > 1 && onsetNext(5) == 0 {
                let a = onsetNext(segs.count), b = onsetNext(segs.count)
                segs.swapAt(a, b)
            }
            if segs.count > 1 && onsetNext(10) == 0 {
                let k = 1 + onsetNext(segs.count - 1)
                segs[k].start = segs[k - 1].start
            }
            let p = persists[onsetNext(persists.count)]
            let input = onsetLine(segs)
            let out = onsetLine(SleepStager.applyPersistentOnset(segs, minPersistS: p))
            for byte in out.utf8 { h ^= UInt64(byte); h = h &* 0x100000001b3 }
            h ^= 0x0A; h = h &* 0x100000001b3
            if i < 2 { first.append("\(p)|\(input)=>\(out)") }
        }
        XCTAssertEqual(first[1],
                       "900|1700000000-1700000720:rem;1700000720-1700001050:awake;1700001050-1700001080:rem;"
                       + "1700001080-1700001620:rem;1700001620-1700002430:light;1700002430-1700002730:awake;"
                       + "1700002730-1700003390:wake=>1700000000-1700001050:wake;1700001050-1700001620:rem;"
                       + "1700001620-1700002430:light;1700002430-1700002730:awake;1700002730-1700003390:wake")
        XCTAssertEqual(String(format: "%016llx", h), "45d53ddc7ee2920d")
    }
}
