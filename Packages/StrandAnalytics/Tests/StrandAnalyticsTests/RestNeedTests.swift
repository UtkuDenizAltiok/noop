import XCTest
@testable import StrandAnalytics

/// `AnalyticsEngine.Rest.personalizedNeedHours` (Wave 0 · T1) — population-anchored, age-floored
/// sleep need. The load-bearing property is the anti-self-referential guard: a chronic
/// under-sleeper's need must NOT drift down toward their own deficit (which a plain trailing mean
/// would do, inverting the honesty philosophy for exactly the users with the most sleep debt); it
/// stays anchored at the age-appropriate population floor.
final class RestNeedTests: XCTestCase {
    private typealias Rest = AnalyticsEngine.Rest

    func testChronicUnderSleeperStaysAtFloor() {
        // 14 nights of ~5.5 h. A self-referential mean returns ~5.5; the anchor must hold >= 7.0.
        let nights = Array(repeating: 5.5, count: 14)
        XCTAssertGreaterThanOrEqual(Rest.personalizedNeedHours(nightlyHours: nights, age: 30), 7.0)
    }

    func testNormalSleeperReflectsUnrestrictedNights() {
        let nights = [7.2, 7.8, 8.1, 7.5, 8.4, 7.9, 8.0, 7.6, 8.2, 7.7]
        let need = Rest.personalizedNeedHours(nightlyHours: nights, age: 35)
        XCTAssertGreaterThanOrEqual(need, 7.0)
        XCTAssertLessThanOrEqual(need, 9.5)
        // Upper-quartile, not the mean: reflects what they sleep on their longer nights.
        XCTAssertGreaterThanOrEqual(need, 7.8)
    }

    func testColdStartReturnsPopulationDefault() {
        // Fewer than minNeedNights → the population default (8.0), floored.
        XCTAssertEqual(Rest.personalizedNeedHours(nightlyHours: [7.0, 8.0, 6.5], age: 30),
                       Rest.defaultNeedHours, accuracy: 0.001)
    }

    func testCapsLongSleeper() {
        let nights = Array(repeating: 11.0, count: 10)
        XCTAssertLessThanOrEqual(Rest.personalizedNeedHours(nightlyHours: nights, age: 40), 9.5)
    }

    func testMinorHasHigherFloor() {
        let nights = Array(repeating: 6.0, count: 10)   // an under-sleeping teen
        XCTAssertGreaterThanOrEqual(Rest.personalizedNeedHours(nightlyHours: nights, age: 15), 8.0)
    }

    func testNilAgeUsesAdultFloor() {
        let nights = Array(repeating: 5.0, count: 10)
        XCTAssertGreaterThanOrEqual(Rest.personalizedNeedHours(nightlyHours: nights, age: nil), 7.0)
    }

    func testZeroAndNegativeNightsIgnored() {
        // no-data days (0) must not drag the estimate down or count toward the minimum.
        let nights = [0.0, -1.0, 7.5, 8.0, 7.8, 8.2, 7.6, 8.1, 7.9, 8.3, 0.0]
        XCTAssertGreaterThanOrEqual(Rest.personalizedNeedHours(nightlyHours: nights, age: 30), 7.5)
    }

    // MARK: - The one need (v6 step 7): age targets, the wearer's choice, and the Kotlin oracle

    func testOlderAdultsTargetSevenAndAHalfHours() {
        XCTAssertEqual(Rest.populationNeedFloorHours(age: 64), 8.0)
        XCTAssertEqual(Rest.populationNeedFloorHours(age: 65), 7.5)
        XCTAssertEqual(Rest.populationNeedFloorHours(age: 17), 9.0)
        XCTAssertEqual(Rest.personalizedNeedHours(nightlyHours: [7.0, 7.2], age: 70), 7.5)
    }

    func testAChosenNeedWinsAndIsClamped() {
        let nights = [Double](repeating: 9.0, count: 10)
        XCTAssertEqual(Rest.resolvedNeedHours(chosenMinutes: 0, nightlyHours: nights, age: 30), 9.0)
        XCTAssertEqual(Rest.resolvedNeedHours(chosenMinutes: 435, nightlyHours: nights, age: 30), 7.25)
        XCTAssertEqual(Rest.resolvedNeedHours(chosenMinutes: 400, nightlyHours: nights, age: 30), 7.0)
        XCTAssertEqual(Rest.resolvedNeedHours(chosenMinutes: 600, nightlyHours: nights, age: 30), 9.5)
    }

    private var needLcg: UInt64 = 0x2545F4914F6CDD1D

    private func needNext(_ n: Int) -> Int {
        needLcg = needLcg &* 6364136223846793005 &+ 1442695040888963407
        return Int((needLcg >> 33) % UInt64(n))
    }

    func testResolvedNeedMatchesTheKotlinOracle() {
        let ages: [Int?] = [nil, 0, 12, 17, 18, 30, 64, 65, 80]
        let chosen = [0, -5, 400, 420, 435, 480, 570, 600]
        var lines: [String] = []
        for i in 0..<400 {
            let n = needNext(14)
            let nights = (0..<n).map { _ in Double(needNext(1200)) / 100.0 - (needNext(10) == 0 ? 3.0 : 0) }
            let age = ages[needNext(ages.count)]
            let c = chosen[needNext(chosen.count)]
            let r = Rest.resolvedNeedHours(chosenMinutes: c, nightlyHours: nights, age: age)
            lines.append("\(i):\(String(r.bitPattern, radix: 16))")
        }
        var h: UInt64 = 0xcbf29ce484222325
        for l in lines { for b in l.utf8 { h ^= UInt64(b); h = h &* 0x100000001b3 }; h ^= 0x0A; h = h &* 0x100000001b3 }
        XCTAssertEqual(lines.prefix(5).joined(separator: " "),
                       "0:401c000000000000 1:4020000000000000 2:4023000000000000 3:401c000000000000 4:401c000000000000")
        XCTAssertEqual(String(format: "%016llx", h), "438d833811016adb")
    }
}
