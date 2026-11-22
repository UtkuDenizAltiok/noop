import XCTest
import StrandAnalytics
import WhoopStore
@testable import Strand

/// Pins the rules behind Design v6's Today ("Today answers"): the word under each score follows the one
/// Charge → Effort mapping, the early-estimate line counts against the engine's own trust threshold, tonight's
/// goal is the need plus a capped catch-up timed from the usual wake, activity is measured against the
/// wearer's own usual day, the Today card's sleep debt is the Sleep tab's, and the strap line stays quiet
/// until it has something true to say.
final class SimpleTodayV6Tests: XCTestCase {

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func v6FixtureInstant(_ day: Int, _ hour: Int, _ minute: Int) -> Date {
        utcCalendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    private func v6FixtureDay(_ day: String, sleepMin: Double?) -> DailyMetric {
        DailyMetric(day: day, totalSleepMin: sleepMin, efficiency: nil, deepMin: nil, remMin: nil, lightMin: nil,
                    disturbances: nil, restingHr: nil, avgHrv: nil, recovery: nil, strain: nil, exerciseCount: nil)
    }

    // MARK: - Score words

    /// The Charge word must be the mapping's own band at every Charge, so the word under the ring and the
    /// "a hard / a moderate / an easy day" line under it can never describe one Charge two ways.
    func testChargeWordFollowsTheMappingAtEveryCharge() {
        for charge in stride(from: 0.0, through: 100.0, by: 0.5) {
            guard let band = CoupledView.optimalStrainRange(recovery: charge) else {
                return XCTFail("no band for Charge \(charge)")
            }
            let expected: SimpleDayPlan.ChargeLevel
            switch SimpleDayPlan.intensity(of: band) {
            case .hard: expected = .high
            case .moderate: expected = .medium
            case .easy: expected = .low
            }
            XCTAssertEqual(SimpleDayPlan.chargeLevel(charge), expected, "Charge \(charge)")
        }
        XCTAssertEqual(SimpleDayPlan.chargeLevel(33.9), .low)
        XCTAssertEqual(SimpleDayPlan.chargeLevel(34), .medium)
        XCTAssertEqual(SimpleDayPlan.chargeLevel(66.9), .medium)
        XCTAssertEqual(SimpleDayPlan.chargeLevel(67), .high)
    }

    /// The Effort word changes just past the top of each suggested range, judged on the printed number like
    /// the card's "in the range", so the word and the card can never disagree about one Effort. On 0–100 the
    /// ranges print 19–48, 48–67 and 67–86.
    func testEffortWordChangesJustPastTheTopOfEachSuggestedRange() {
        let expectations: [(Double, SimpleDayPlan.EffortLevel)] = [
            (0, .easy), (48, .easy), (48.4, .easy), (48.6, .moderate), (67, .moderate), (67.4, .moderate),
            (67.6, .hard), (86, .hard), (86.6, .veryHard), (100, .veryHard),
        ]
        for (stored, expected) in expectations {
            XCTAssertEqual(SimpleDayPlan.effortLevel(stored: stored, scale: .hundred), expected, "stored \(stored)")
        }
        // Whatever the card calls "in the range" of a band carries that band's word or the one below it, never
        // the one above: walk every stored Effort on both scales.
        for scale in [EffortScale.hundred, .whoop] {
            for charge in [20.0, 50.0, 80.0] {
                guard let band21 = CoupledView.optimalStrainRange(recovery: charge) else { return XCTFail("no band") }
                let band = SimpleDayPlan.band(band21, on: scale)
                let ceiling: SimpleDayPlan.EffortLevel
                switch SimpleDayPlan.intensity(of: band21) {
                case .easy: ceiling = .easy
                case .moderate: ceiling = .moderate
                case .hard: ceiling = .hard
                }
                let order: [SimpleDayPlan.EffortLevel] = [.easy, .moderate, .hard, .veryHard]
                for stored in stride(from: 0.0, through: 100.0, by: 0.25)
                where SimpleDayPlan.progress(stored: stored, scale: scale, band: band) == .within {
                    let word = SimpleDayPlan.effortLevel(stored: stored, scale: scale)
                    XCTAssertLessThanOrEqual(order.firstIndex(of: word) ?? 9, order.firstIndex(of: ceiling) ?? -1,
                                             "stored \(stored) on \(scale) in the range of Charge \(charge)")
                }
            }
        }
    }

    // MARK: - Early estimate

    /// The line shows only for today's own Charge and only below the engine's trust threshold, which it
    /// reads rather than repeats.
    func testEarlyEstimateCountsAgainstTheEnginesTrustThreshold() {
        let trust = Baselines.minNightsTrust
        XCTAssertEqual(SimpleDayPlan.earlyEstimateNights(validNights: 6, chargeIsTodaysOwn: true), 6)
        XCTAssertEqual(SimpleDayPlan.earlyEstimateNights(validNights: trust - 1, chargeIsTodaysOwn: true), trust - 1)
        XCTAssertNil(SimpleDayPlan.earlyEstimateNights(validNights: trust, chargeIsTodaysOwn: true))
        XCTAssertNil(SimpleDayPlan.earlyEstimateNights(validNights: 6, chargeIsTodaysOwn: false),
                     "a carried or calibrating ring says so in its own words")
        XCTAssertNil(SimpleDayPlan.earlyEstimateNights(validNights: nil, chargeIsTodaysOwn: true))
    }

    // MARK: - Tonight's goal

    func testCatchUpIsTheDebtCappedAndRoundedToFiveMinutes() {
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 0), 0)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: -20), 0)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 2), 0)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 12), 10)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 37), 35)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 38), 40)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 60), 60)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: 200), SimpleDayPlan.catchUpCapMinutes)
        XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: .nan), 0)
    }

    /// The usual wake is the median of the most recent wakes, so one late morning does not move it, and it
    /// is nil until enough nights exist.
    func testUsualWakeIsTheMedianOfRecentWakes() {
        let few = (1...4).map { v6FixtureInstant($0, 7, 0) }
        XCTAssertNil(SimpleDayPlan.usualWakeMinute(wakeTimes: few, calendar: utcCalendar))

        var wakes = (1...6).map { v6FixtureInstant($0, 7, 0) }
        wakes.append(v6FixtureInstant(7, 10, 30))               // one late Sunday
        XCTAssertEqual(SimpleDayPlan.usualWakeMinute(wakeTimes: wakes, calendar: utcCalendar), 7 * 60)

        // Only the most recent `usualWakeWindowNights` count: twenty old 05:00 wakes, then fourteen 08:00 ones.
        let old = (0..<20).map { utcCalendar.date(byAdding: .day, value: -40 + $0, to: v6FixtureInstant(1, 5, 0))! }
        let recent = (1...14).map { v6FixtureInstant($0, 8, 0) }
        XCTAssertEqual(SimpleDayPlan.usualWakeMinute(wakeTimes: old + recent, calendar: utcCalendar), 8 * 60)
    }

    /// With a usual wake the goal carries the fall-asleep time for the next such wake; once that time has
    /// passed nothing is shown; without a usual wake it is the goal alone.
    func testTonightGoalIsTimedFromTheUsualWake() {
        let afternoon = v6FixtureInstant(15, 16, 0)
        let goal = SimpleDayPlan.tonightGoal(now: afternoon, calendar: utcCalendar, needMinutes: 480,
                                             catchUpMinutes: 35, usualWakeMinute: 7 * 60 + 10)
        XCTAssertEqual(goal?.goalMinutes, 515)
        XCTAssertEqual(goal?.catchUpMinutes, 35)
        XCTAssertEqual(goal?.wake, v6FixtureInstant(16, 7, 10))
        XCTAssertEqual(goal?.asleepBy, v6FixtureInstant(15, 22, 35))

        // After midnight, before the wake: the asleep-by time (22:35 yesterday) has passed.
        XCTAssertNil(SimpleDayPlan.tonightGoal(now: v6FixtureInstant(16, 0, 30), calendar: utcCalendar,
                                               needMinutes: 480, catchUpMinutes: 35, usualWakeMinute: 7 * 60 + 10))
        // Late evening, past the asleep-by time.
        XCTAssertNil(SimpleDayPlan.tonightGoal(now: v6FixtureInstant(15, 23, 0), calendar: utcCalendar,
                                               needMinutes: 480, catchUpMinutes: 35, usualWakeMinute: 7 * 60 + 10))

        let untimed = SimpleDayPlan.tonightGoal(now: afternoon, calendar: utcCalendar, needMinutes: 480,
                                                catchUpMinutes: 0, usualWakeMinute: nil)
        XCTAssertEqual(untimed, SimpleDayPlan.TonightGoal(goalMinutes: 480, catchUpMinutes: 0, asleepBy: nil, wake: nil))
        XCTAssertNil(SimpleDayPlan.tonightGoal(now: afternoon, calendar: utcCalendar, needMinutes: 0,
                                               catchUpMinutes: 0, usualWakeMinute: nil))
    }

    // MARK: - Activity against the usual day

    func testUsualDayIsTheMedianOfEarlierDaysWithAReading() {
        let series = (1...9).map { (day: String(format: "2026-11-%02d", $0), value: Double($0) * 1000) }
        // Days before the 8th: 1000…7000, median 4000. The 8th itself and later are left out.
        XCTAssertEqual(SimpleDayPlan.usualDailyValue(series: series, before: "2026-11-08"), 4000)
        // Fewer than `usualDayMinDays` earlier days: no usual yet.
        XCTAssertNil(SimpleDayPlan.usualDailyValue(series: series, before: "2026-11-07"))
        // A day that recorded nothing is not a usual day.
        let withGap = series + [(day: "2026-10-30", value: 0)]
        XCTAssertEqual(SimpleDayPlan.usualDailyValue(series: withGap, before: "2026-11-08"), 4000)
    }

    func testActivityBarIsFullAtTheUsualDay() {
        XCTAssertEqual(SimpleDayPlan.usualFraction(value: 4000, usual: 8000), 0.5)
        XCTAssertEqual(SimpleDayPlan.usualFraction(value: 12000, usual: 8000), 1)
        XCTAssertNil(SimpleDayPlan.usualFraction(value: 4000, usual: nil))
        XCTAssertNil(SimpleDayPlan.usualFraction(value: nil, usual: 8000))
        XCTAssertNil(SimpleDayPlan.usualFraction(value: 4000, usual: 0))
    }

    // MARK: - One sleep debt

    /// The Today card's debt goes through the Sleep tab's ledger: with the same day rows and no nap blocks,
    /// the session-list form must give the ledger the day-row form gives.
    func testTodaysDebtIsTheSleepTabsLedger() {
        let days = (1...14).map { v6FixtureDay(String(format: "2026-11-%02d", $0), sleepMin: 420) }
        let fromRows = SleepModel.debtLedger(days: days, napSleepMinByDay: [:])
        let fromSessions = SleepModel.debtLedger(days: days, sleeps: [], allSessions: [], habitualMidsleepSec: nil)
        XCTAssertEqual(fromSessions, fromRows)
        XCTAssertGreaterThan(fromSessions.magnitudeMin, 0, "seven hours a night against an eight-hour need is a debt")
    }

    /// The windowed block read reaches back to the oldest night the ledger counts, so it cannot miss one.
    func testLedgerLookbackReachesTheOldestCountedNight() {
        // Twenty nights with sleep ending 20 Nov: the ledger counts the last 14 (7–20 Nov).
        let days = (1...20).map { v6FixtureDay(String(format: "2026-11-%02d", $0), sleepMin: 400) }
        XCTAssertEqual(SleepModel.debtLedgerLookbackDays(days: days, todayKey: "2026-11-20"), 13 + 3)
        // A gap in wear: 14 counted nights spread over a longer stretch are still reached.
        let sparse = stride(from: 1, through: 29, by: 2).map {
            v6FixtureDay(String(format: "2026-10-%02d", $0), sleepMin: 400)
        }
        // Counted nights: the last 14 of 1,3,…,29 Oct = 3…29 Oct; today 2 Nov is 30 days after 3 Oct.
        XCTAssertEqual(SleepModel.debtLedgerLookbackDays(days: sparse, todayKey: "2026-11-02"), 30 + 3)
        XCTAssertEqual(SleepModel.debtLedgerLookbackDays(days: [], todayKey: "2026-11-02"), 3)
    }

    /// The same count in a time zone with a clock change between the two nights. Counted on the device's
    /// calendar, 3 Oct to 2 Nov was 29 days in Berlin or New York and 30 in Istanbul, so the test above passed
    /// or failed by where the Mac was (it failed in Central Europe on 22 Nov). Pinned here so it cannot hide.
    func testLedgerLookbackIgnoresTheDevicesClockChange() {
        let saved = NSTimeZone.default
        defer { NSTimeZone.default = saved }
        let sparse = stride(from: 1, through: 29, by: 2).map {
            v6FixtureDay(String(format: "2026-10-%02d", $0), sleepMin: 400)
        }
        for zone in ["Europe/Berlin", "America/New_York", "Europe/Istanbul"] {
            NSTimeZone.default = TimeZone(identifier: zone) ?? saved
            XCTAssertEqual(SleepModel.debtLedgerLookbackDays(days: sparse, todayKey: "2026-11-02"), 30 + 3, zone)
        }
    }

    // MARK: - Charge bars and the strap line

    func testDirectionBarLengthIsTheShareOfTheBiggestMover() {
        XCTAssertEqual(ChargeDriverDirectionBar.halfFraction(deltaPoints: 11, maxMagnitude: 11), 1)
        XCTAssertEqual(ChargeDriverDirectionBar.halfFraction(deltaPoints: -5, maxMagnitude: 10), 0.5)
        XCTAssertEqual(ChargeDriverDirectionBar.halfFraction(deltaPoints: 0, maxMagnitude: 10), 0)
        XCTAssertEqual(ChargeDriverDirectionBar.halfFraction(deltaPoints: 4, maxMagnitude: 0), 0)
    }

    /// The strap line speaks only for a WHOOP strap that is not connected, and only once the launch-time
    /// reconnect has had its moment.
    func testStrapLineStaysQuietUntilItIsTrue() {
        XCTAssertTrue(SimpleStrapStatus.showsNotConnected(activeIsWhoop: true, connected: false, settled: true))
        XCTAssertFalse(SimpleStrapStatus.showsNotConnected(activeIsWhoop: true, connected: false, settled: false))
        XCTAssertFalse(SimpleStrapStatus.showsNotConnected(activeIsWhoop: true, connected: true, settled: true))
        XCTAssertFalse(SimpleStrapStatus.showsNotConnected(activeIsWhoop: false, connected: false, settled: true))
    }
}
