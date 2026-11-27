import XCTest
@testable import StrandAnalytics

/// Pins `SleepRegularityIndex` (the Sleep Regularity Index, Phillips et al. 2017) with hand-worked weeks, and the
/// oracle the Kotlin twin (`SleepRegularityIndexTest`) asserts from the same generator, so the two cannot drift.
final class SleepRegularityIndexTests: XCTestCase {

    /// The night of local day `day` in UTC+1: from `startHour` (negative = the evening before) for `hours`.
    private func sriNight(_ day: Int, startHour: Double = -1, hours: Double = 8) -> (start: Int, end: Int) {
        let localMidnight = 1_700_006_400 + day * 86_400 - 3_600
        let start = localMidnight + Int(startHour * 3_600)
        return (start, start + Int(hours * 3_600))
    }

    func testTheSameNightEveryDayScoresOneHundred() {
        let week = (1...8).map { sriNight($0) }
        XCTAssertEqual(SleepRegularityIndex.compute(spans: week, offsetSec: 3_600), 100.0)
    }

    func testNightsAlternatingByFourHoursScoreAThird() {
        // 23:00-07:00 and 03:00-11:00 in turn: each pair disagrees for 8 of 24 hours.
        let week = (1...8).map { $0 % 2 == 0 ? sriNight($0) : sriNight($0, startHour: 3) }
        XCTAssertEqual(SleepRegularityIndex.compute(spans: week, offsetSec: 3_600) ?? .nan, 33.333333333, accuracy: 1e-6)
    }

    func testItNeedsFourPairsOfWornDays() {
        XCTAssertNil(SleepRegularityIndex.compute(spans: (1...4).map { sriNight($0) }, offsetSec: 3_600))
        XCTAssertEqual(SleepRegularityIndex.compute(spans: (1...5).map { sriNight($0) }, offsetSec: 3_600), 100.0)
        // Every other night missing leaves no pair at all.
        XCTAssertNil(SleepRegularityIndex.compute(spans: stride(from: 1, through: 15, by: 2).map { sriNight($0) },
                                                  offsetSec: 3_600))
        XCTAssertNil(SleepRegularityIndex.compute(spans: [], offsetSec: 3_600))
    }

    func testADayCountsFromThreeHoursOfSleep() {
        // A night under 3 hours leaves its day out; at 3 hours it counts and disagrees for 5 hours each side.
        let short = (1...8).map { $0 == 5 ? sriNight($0, hours: 2.99) : sriNight($0) }
        XCTAssertEqual(SleepRegularityIndex.compute(spans: short, offsetSec: 3_600), 100.0)
        let three = (1...8).map { $0 == 5 ? sriNight($0, hours: 3) : sriNight($0) }
        XCTAssertEqual(SleepRegularityIndex.compute(spans: three, offsetSec: 3_600) ?? .nan,
                       200.0 * 9_480.0 / 10_080.0 - 100.0, accuracy: 1e-9)
    }

    func testANapCountsAsSleep() {
        // An hour's nap on day 4 at 14:00: two pairs disagree for that hour.
        let week = (1...8).map { sriNight($0) } + [sriNight(4, startHour: 14, hours: 1)]
        XCTAssertEqual(SleepRegularityIndex.compute(spans: week, offsetSec: 3_600) ?? .nan,
                       200.0 * 9_960.0 / 10_080.0 - 100.0, accuracy: 1e-9)
    }

    func testTheRestPartIsTheIndexOnItsOwnScale() {
        XCTAssertNil(SleepRegularityIndex.consistency(nil))
        XCTAssertEqual(SleepRegularityIndex.consistency(81), 0.81)
        XCTAssertEqual(SleepRegularityIndex.consistency(-20), 0.0)
        XCTAssertEqual(SleepRegularityIndex.consistency(100), 1.0)
    }

    // MARK: - The oracle (shared with Kotlin)

    private var sriLcg: UInt64 = 0x2545F4914F6CDD1D

    private func sriNext(_ n: Int) -> Int {
        sriLcg = sriLcg &* 6364136223846793005 &+ 1442695040888963407
        return Int((sriLcg >> 33) % UInt64(n))
    }

    func testMatchesTheKotlinOracleOverThreeThousandRandomHistories() {
        var h: UInt64 = 0xcbf29ce484222325
        var firstCase = ""
        var nils = 0
        for i in 0..<3000 {
            let offset = (sriNext(105) - 48) * 900
            let base = 1_700_006_400 + sriNext(400) * 86_400
            let days = 1 + sriNext(20)
            var spans: [(start: Int, end: Int)] = []
            for d in 0..<days {
                let dayStart = base + d * 86_400 - offset
                if sriNext(100) < 95 {
                    let bed = dayStart - 7_200 + (sriNext(73) - 36) * 300
                    let len = 9_000 + sriNext(85) * 300
                    spans.append((bed, bed + len))
                    if sriNext(10) == 0 { spans.append((bed + 600, bed + len - 900)) }
                }
                if sriNext(100) < 20 {
                    let nap = dayStart + 46_800 + sriNext(49) * 300
                    spans.append((nap, nap + 1_200 + sriNext(21) * 300))
                }
                if sriNext(40) == 0 { spans.append((dayStart, dayStart)) }
            }
            if spans.count > 1 && sriNext(4) == 0 { spans.swapAt(sriNext(spans.count), sriNext(spans.count)) }
            let idx = SleepRegularityIndex.compute(spans: spans, offsetSec: offset)
            let out = idx.map { String(format: "%016llx", $0.bitPattern) } ?? "nil"
            if idx == nil { nils += 1 }
            for byte in out.utf8 { h ^= UInt64(byte); h = h &* 0x100000001b3 }
            h ^= 0x0A; h = h &* 0x100000001b3
            if i == 0 { firstCase = "\(offset)|\(spans.count)|\(spans.first.map { "\($0.start)-\($0.end)" } ?? "-")=>\(out)" }
        }
        XCTAssertEqual(firstCase, "-7200|14|1709945100-1709967300=>404ff1c71c71c71c")
        XCTAssertEqual(nils, 2122)
        XCTAssertEqual(String(format: "%016llx", h), "3a8a2d067deb0bf6")
    }
}
