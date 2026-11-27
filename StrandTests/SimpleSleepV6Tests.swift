import XCTest
import StrandAnalytics
import WhoopStore
@testable import Strand

/// Pins the rules behind Design v6's Sleep tab ("how much sleep, and why"): where the sleep need comes from
/// follows the rule that sets it, a night is compared with the usual one in printed minutes, the debt's
/// advice changes at the same hour tonight's catch-up is capped at, the trend's change and average describe
/// the nights shown, and "Tonight" is one answer for Today and for the Sleep tab.
final class SimpleSleepV6Tests: XCTestCase {

    private let reminderKeys = [SimpleDayPlan.ReminderKeys.enabled, SimpleDayPlan.ReminderKeys.wake,
                                SimpleDayPlan.ReminderKeys.need, SimpleDayPlan.ReminderKeys.perDayWake]
    private var savedReminder: [String: Any] = [:]

    override func setUp() {
        super.setUp()
        for key in reminderKeys { if let v = UserDefaults.standard.object(forKey: key) { savedReminder[key] = v } }
    }

    override func tearDown() {
        for key in reminderKeys {
            if let v = savedReminder[key] { UserDefaults.standard.set(v, forKey: key) } else { UserDefaults.standard.removeObject(forKey: key) }
        }
        super.tearDown()
    }

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    // MARK: - Where the need comes from

    /// The card says "the usual target" or "raised" by the same floor the need rule applies, for whatever
    /// that rule returns: a need above the floor was raised, anything else is the target itself.
    func testSleepNeedOriginFollowsTheRuleThatSetsTheNeed() {
        let floorMin = AnalyticsEngine.Rest.populationNeedFloorHours(age: nil) * 60
        XCTAssertEqual(SimpleDayPlan.standardSleepNeedMinutes(age: nil), Int(floorMin.rounded()))
        XCTAssertEqual(SimpleDayPlan.standardSleepNeedMinutes(age: 70), 450)
        func origin(_ need: Double, chosen: Int = 0, age: Int? = nil) -> SimpleDayPlan.SleepNeedOrigin {
            SimpleDayPlan.sleepNeedOrigin(needMin: need, chosenMinutes: chosen, age: age)
        }
        XCTAssertEqual(origin(floorMin), .standard)
        XCTAssertEqual(origin(floorMin + 0.4), .standard)
        XCTAssertEqual(origin(floorMin + 1), .raised)
        XCTAssertEqual(origin(480, age: 70), .raised, "8 h is above the 7.5 h target from 65")
        // A need the wearer chose says so, whatever its size.
        XCTAssertEqual(origin(450, chosen: 450), .chosen)
        XCTAssertEqual(origin(540, chosen: 540), .chosen)
        // A short sleeper's need stays the target; a long sleeper's is raised; too few nights is the target.
        let short = AnalyticsEngine.Rest.personalizedNeedHours(nightlyHours: Array(repeating: 6.2, count: 14), age: nil) * 60
        let long = AnalyticsEngine.Rest.personalizedNeedHours(nightlyHours: Array(repeating: 8.9, count: 14), age: nil) * 60
        let few = AnalyticsEngine.Rest.personalizedNeedHours(nightlyHours: [9.2, 9.1, 9.3], age: nil) * 60
        XCTAssertEqual(origin(short), .standard)
        XCTAssertEqual(origin(long), .raised)
        XCTAssertEqual(origin(few), .standard)
    }

    /// The night's line names WHOOP as the source of its need only when there is an imported need and it
    /// reads differently from NOOP's.
    func testNeedIsCalledImportedOnlyWhenItReadsDifferently() {
        XCTAssertFalse(SimpleDayPlan.needIsImported(importedNeedMin: nil, normativeNeedMin: 480))
        XCTAssertFalse(SimpleDayPlan.needIsImported(importedNeedMin: 0, normativeNeedMin: 480))
        XCTAssertFalse(SimpleDayPlan.needIsImported(importedNeedMin: 480.4, normativeNeedMin: 480))
        XCTAssertTrue(SimpleDayPlan.needIsImported(importedNeedMin: 464, normativeNeedMin: 480))
        XCTAssertTrue(SimpleDayPlan.needIsImported(importedNeedMin: 530, normativeNeedMin: 480))
    }

    // MARK: - A night against the usual one

    func testANightIsComparedWithTheUsualInPrintedMinutes() {
        XCTAssertEqual(SimpleDayPlan.versusUsual(valueMin: 431, usualMin: 436), .less(minutes: 5))
        XCTAssertEqual(SimpleDayPlan.versusUsual(valueMin: 186, usualMin: 183), .more(minutes: 3))
        // 183.4 and 182.6 both print 3h 3m: the same, not "1m more".
        XCTAssertEqual(SimpleDayPlan.versusUsual(valueMin: 183.4, usualMin: 182.6), .same)
        XCTAssertEqual(SimpleDayPlan.versusUsual(valueMin: 183.6, usualMin: 183.4), .more(minutes: 1))
    }

    // MARK: - Debt advice by size

    /// Nothing to do inside the ledger's own on-target band; tonight can clear a debt under the catch-up
    /// cap; from the cap on it takes several nights. The cap is the one tonight's goal uses, so the advice
    /// never asks for more tonight than the goal adds.
    func testDebtAdviceChangesWhereTonightsCatchUpIsCapped() {
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: 72, isDebt: false), .caughtUp)
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: SleepDebt.onTargetBandMin - 0.1, isDebt: true), .caughtUp)
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: 37, isDebt: true), .tonight(minutes: 37))
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: 59.4, isDebt: true), .tonight(minutes: 59))
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: 59.6, isDebt: true), .severalNights)
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: 72, isDebt: true), .severalNights)
        XCTAssertEqual(SimpleDayPlan.debtAdvice(debtMinutes: .nan, isDebt: true), .caughtUp)
        for debt in stride(from: 0.0, through: 240.0, by: 0.5) {
            switch SimpleDayPlan.debtAdvice(debtMinutes: debt, isDebt: true) {
            case .tonight(let minutes):
                XCTAssertLessThan(minutes, SimpleDayPlan.catchUpCapMinutes, "debt \(debt)")
                XCTAssertGreaterThanOrEqual(debt, SleepDebt.onTargetBandMin)
            case .severalNights:
                XCTAssertEqual(SimpleDayPlan.catchUpMinutes(debtMinutes: debt), SimpleDayPlan.catchUpCapMinutes,
                               "a debt of \(debt) is called too much for one night while tonight's goal adds less than the cap")
            case .caughtUp:
                XCTAssertLessThan(debt, SleepDebt.onTargetBandMin)
            }
        }
    }

    // MARK: - The trend in words

    /// The change is the later half's mean minus the earlier half's, in whole minutes a night, and a change
    /// that rounds to nothing is no change.
    func testNightlyChangeComparesTheLaterHalfWithTheEarlier() {
        XCTAssertEqual(SimpleDayPlan.nightlyChange(hours: [7, 7, 8, 8]), .more(minutes: 60))
        XCTAssertEqual(SimpleDayPlan.nightlyChange(hours: [8, 8, 7, 7]), .less(minutes: 60))
        XCTAssertEqual(SimpleDayPlan.nightlyChange(hours: [7, 7, 7, 7]), SimpleDayPlan.NightlyChange.none)
        XCTAssertEqual(SimpleDayPlan.nightlyChange(hours: [7, 7, 7.004, 7.004]), SimpleDayPlan.NightlyChange.none)
        XCTAssertNil(SimpleDayPlan.nightlyChange(hours: [7, 8, 9]))
        // Five nights: the earlier two against the later three.
        XCTAssertEqual(SimpleDayPlan.nightlyChange(hours: [6, 6, 7, 7, 7]), .more(minutes: 60))
        XCTAssertEqual(SimpleDayPlan.nightlyChange(hours: [7.5, 7.3, 7.1, 7.2, 7.0, 7.1]), .less(minutes: 12))
    }

    /// The average is the mean of the nights the chart shows, in minutes.
    func testAverageIsOfTheNightsShown() {
        XCTAssertEqual(SimpleDayPlan.averageMinutes(hours: [7, 8]), 450)
        XCTAssertEqual(SimpleDayPlan.averageMinutes(hours: [7.25]), 435)
        XCTAssertNil(SimpleDayPlan.averageMinutes(hours: []))
    }

    // MARK: - Tonight, one answer for two screens

    /// With the reminder off: a goal from the need, the catch-up and the usual wake; no goal while last
    /// night's line states another need; nothing without a need. Today and the Sleep tab both call this.
    @MainActor
    func testTonightIsResolvedOnceForTodayAndSleep() {
        UserDefaults.standard.set(false, forKey: SimpleDayPlan.ReminderKeys.enabled)
        let evening = utcCalendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 18))!
        let tonight = SimpleTonight.resolve(now: evening, calendar: utcCalendar, needMin: 480, debtMin: 37,
                                            usualWakeMinute: 7 * 60 + 10, lastNightNeedMin: nil)
        XCTAssertNil(tonight.plan)
        XCTAssertEqual(tonight.catchUp, 35)
        XCTAssertEqual(tonight.goal?.goalMinutes, 515)
        XCTAssertEqual(tonight.goal?.catchUpMinutes, 35)
        // Asleep by 22:35 for a 07:10 wake with 8h 35m of sleep.
        XCTAssertEqual(tonight.goal?.asleepBy,
                       utcCalendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 22, minute: 35)))
        XCTAssertTrue(tonight.hasSomethingToSay)
        // Last night's line states the same need: the goal stands. Another need: no second need beside it.
        XCTAssertNotNil(SimpleTonight.resolve(now: evening, calendar: utcCalendar, needMin: 480, debtMin: 37,
                                              usualWakeMinute: 430, lastNightNeedMin: 480).goal)
        let underWhoopsNeed = SimpleTonight.resolve(now: evening, calendar: utcCalendar, needMin: 480, debtMin: 37,
                                                    usualWakeMinute: 430, lastNightNeedMin: 464)
        XCTAssertNil(underWhoopsNeed.goal)
        XCTAssertFalse(underWhoopsNeed.hasSomethingToSay)
        XCTAssertFalse(SimpleTonight.resolve(now: evening, calendar: utcCalendar, needMin: nil, debtMin: 37,
                                             usualWakeMinute: 430, lastNightNeedMin: nil).hasSomethingToSay)
        XCTAssertFalse(SimpleTonight.silent.hasSomethingToSay)
    }

    /// With the reminder on, its own plan is the row and no goal is built beside it.
    @MainActor
    func testTheRemindersPlanReplacesTheGoal() {
        UserDefaults.standard.set(true, forKey: SimpleDayPlan.ReminderKeys.enabled)
        UserDefaults.standard.set(7 * 60, forKey: SimpleDayPlan.ReminderKeys.wake)
        UserDefaults.standard.set(8 * 60, forKey: SimpleDayPlan.ReminderKeys.need)
        UserDefaults.standard.removeObject(forKey: SimpleDayPlan.ReminderKeys.perDayWake)
        let evening = utcCalendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 18))!
        let tonight = SimpleTonight.resolve(now: evening, calendar: utcCalendar, needMin: 480, debtMin: 37,
                                            usualWakeMinute: 430, lastNightNeedMin: 464)
        XCTAssertNotNil(tonight.plan)
        XCTAssertNil(tonight.goal)
        XCTAssertEqual(tonight.plan?.needMinutes, 480)
        XCTAssertEqual(tonight.catchUp, 35)
        // Last night's line shows another need (464), so the reminder's row does not state its own.
        XCTAssertFalse(tonight.planStatesNeed)
        XCTAssertTrue(SimpleTonight.resolve(now: evening, calendar: utcCalendar, needMin: 480, debtMin: 0,
                                            usualWakeMinute: 430, lastNightNeedMin: 480).planStatesNeed)
    }
}
