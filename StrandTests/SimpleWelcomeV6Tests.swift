import XCTest
import StrandAnalytics
import WhoopStore
@testable import Strand

/// Pins the rules behind Design v6's step 6, "Welcome": the night counts "Getting to know you" and the guide
/// print are the gates the engines read (a test fails if one moves), the card counts nights the way the Charge
/// does and leaves once the baseline is trusted, "How to read NOOP" waits for every condition, the strap's
/// low-battery line and More's "My strap" read the header ring's funnel and the notification's threshold, and
/// the guide carries its new entries without the label nothing shows any more.
final class SimpleWelcomeV6Tests: XCTestCase {

    // MARK: Fixtures (named unlike any production function: the parity ledger pairs calls by name)

    private func welcomeV6Night(_ day: String, hrv: Double?) -> DailyMetric {
        DailyMetric(day: day, totalSleepMin: nil, efficiency: nil, deepMin: nil, remMin: nil, lightMin: nil,
                    disturbances: nil, restingHr: 55, avgHrv: hrv, recovery: nil, strain: nil,
                    exerciseCount: nil, spo2Pct: nil)
    }

    /// `count` consecutive day keys ending on 2026-11-20, oldest first.
    private func welcomeV6DayKeys(_ count: Int) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let end = calendar.date(from: DateComponents(year: 2026, month: 11, day: 20))!
        return (0..<count).reversed().map { back in
            formatter.string(from: calendar.date(byAdding: .day, value: -back, to: end)!)
        }
    }

    // MARK: - The night counts are the gates'

    func testEachMilestoneArrivesAtItsOwnGate() {
        XCTAssertEqual(SimpleWelcome.Milestone.rest.nights, 1)
        XCTAssertEqual(SimpleWelcome.Milestone.charge.nights, Baselines.minNightsSeed)
        XCTAssertEqual(SimpleWelcome.Milestone.advice.nights, SimpleWelcome.adviceNights)
        XCTAssertEqual(SimpleWelcome.Milestone.ownNormal.nights, Baselines.minNightsTrust)
        XCTAssertEqual(SimpleWelcome.Milestone.allCases, [.rest, .charge, .advice, .ownNormal],
                       "The card lists what arrives in the order a new wearer meets it.")
    }

    /// "After 7 nights: advice for your day" is only true while the readiness engine needs exactly that many
    /// nights of history: with one fewer it has no verdict, with that many it has one. Its minimum is private,
    /// so this pins the copy to the engine's behaviour.
    func testAdviceArrivesExactlyWhenTheReadinessEngineCanJudge() {
        let need = SimpleWelcome.adviceNights
        for history in [need - 1, need] {
            let keys = welcomeV6DayKeys(history + 1)
            let days = keys.enumerated().map { index, key in
                welcomeV6Night(key, hrv: 60 + Double(index % 3))
            }
            let readiness = ReadinessEngine.evaluate(days: days, today: keys.last)
            if history < need {
                XCTAssertEqual(readiness.level, .insufficient, "\(history) nights of history gave a verdict.")
            } else {
                XCTAssertNotEqual(readiness.level, .insufficient, "\(history) nights of history gave no verdict.")
            }
        }
    }

    // MARK: - The card

    func testEachStepIsTickedAtItsGate() {
        let seed = Baselines.minNightsSeed, advice = SimpleWelcome.adviceNights, trust = Baselines.minNightsTrust
        func reached(_ nights: Int, rest: Bool = false) -> [SimpleWelcome.Milestone] {
            SimpleWelcome.steps(learnedNights: nights, hasRest: rest).filter(\.reached).map(\.milestone)
        }
        XCTAssertEqual(reached(0), [])
        XCTAssertEqual(reached(0, rest: true), [.rest], "A night scored for Rest ticks Rest before its HRV counts.")
        XCTAssertEqual(reached(1), [.rest])
        XCTAssertEqual(reached(seed - 1), [.rest])
        XCTAssertEqual(reached(seed), [.rest, .charge])
        XCTAssertEqual(reached(advice - 1), [.rest, .charge])
        XCTAssertEqual(reached(advice), [.rest, .charge, .advice])
        XCTAssertEqual(reached(trust - 1), [.rest, .charge, .advice])
        XCTAssertEqual(reached(trust), [.rest, .charge, .advice, .ownNormal])
    }

    func testTheCardShowsOnTodayUntilTheBaselineIsTrusted() {
        let trust = Baselines.minNightsTrust
        XCTAssertTrue(SimpleWelcome.showsCard(learnedNights: 0, isToday: true))
        XCTAssertTrue(SimpleWelcome.showsCard(learnedNights: trust - 1, isToday: true))
        XCTAssertFalse(SimpleWelcome.showsCard(learnedNights: trust, isToday: true))
        XCTAssertFalse(SimpleWelcome.showsCard(learnedNights: 3, isToday: false), "Only today's page carries it.")
        XCTAssertFalse(SimpleWelcome.showsCard(learnedNights: nil, isToday: true),
                       "Before the baselines load, nothing is claimed.")
    }

    /// The card's count is the Charge gate's count: while Charge is calibrating they are the same number, and
    /// Charge stops calibrating exactly when the card's count reaches the seed. A night the baseline cannot use
    /// (no HRV, or outside the plausible range) counts for neither.
    func testTheCardCountsNightsTheWayTheChargeDoes() {
        let tooHigh = Baselines.hrvCfg.maxVal + 50
        let seed = Baselines.minNightsSeed
        let series: [[Double?]] = [
            [], [62], [62, nil, 58], [62, tooHigh, 58, nil, 60],
            Array(repeating: 60, count: seed - 1), Array(repeating: 60, count: seed),
            Array(repeating: 60, count: seed + 3) + [tooHigh],
        ]
        for values in series {
            let keys = welcomeV6DayKeys(values.count)
            let learned = SimpleWelcome.learnedNights(hrv: values, dayKeys: keys)
            let calibrating = RecoveryScorer.calibrationNights(nightlyHrv: values, dayKeys: keys, hasRecovery: false)
            if learned < seed {
                XCTAssertEqual(calibrating, learned, "\(values): the card and the Charge count differently.")
            } else {
                XCTAssertNil(calibrating, "\(values): the card says Charge has arrived while Charge still calibrates.")
            }
            XCTAssertLessThanOrEqual(learned, values.compactMap { $0 }.filter { $0 < tooHigh }.count,
                                     "\(values): a night the baseline cannot use was counted.")
        }
    }

    // MARK: - "How to read NOOP"

    func testTheWelcomeWaitsForEveryCondition() {
        XCTAssertTrue(SimpleWelcome.shouldOffer(simpleMode: true, seen: false, firstRunDone: true, todaySelected: true,
                                                appActive: true, anotherSheetUp: false))
        XCTAssertFalse(SimpleWelcome.shouldOffer(simpleMode: false, seen: false, firstRunDone: true, todaySelected: true,
                                                 appActive: true, anotherSheetUp: false), "Simple mode only.")
        XCTAssertFalse(SimpleWelcome.shouldOffer(simpleMode: true, seen: true, firstRunDone: true, todaySelected: true,
                                                 appActive: true, anotherSheetUp: false), "Once.")
        XCTAssertFalse(SimpleWelcome.shouldOffer(simpleMode: true, seen: false, firstRunDone: false, todaySelected: true,
                                                 appActive: true, anotherSheetUp: false),
                       "Not under the terms, the setup wizard or What's New.")
        XCTAssertFalse(SimpleWelcome.shouldOffer(simpleMode: true, seen: false, firstRunDone: true, todaySelected: false,
                                                 appActive: true, anotherSheetUp: false), "Over Today only.")
        XCTAssertFalse(SimpleWelcome.shouldOffer(simpleMode: true, seen: false, firstRunDone: true, todaySelected: true,
                                                 appActive: false, anotherSheetUp: false),
                       "Not during a background launch, where nobody would see it.")
        XCTAssertFalse(SimpleWelcome.shouldOffer(simpleMode: true, seen: false, firstRunDone: true, todaySelected: true,
                                                 appActive: true, anotherSheetUp: true),
                       "Never on top of another sheet, where it would be dropped.")
    }

    // MARK: - The strap

    func testTheLowBatteryLineUsesTheNotificationsThreshold() {
        let low = BatteryNotifier.BatteryAlertPolicy.lowThreshold
        typealias Display = LiquidTodayView.StrapBatteryDisplay
        XCTAssertEqual(SimpleStrapStatus.lowBattery(Display.charge(pct: Double(low), charging: false, isRing: false)), low)
        XCTAssertNil(SimpleStrapStatus.lowBattery(Display.charge(pct: Double(low + 1), charging: false, isRing: false)))
        XCTAssertEqual(SimpleStrapStatus.lowBattery(Display.charge(pct: Double(low) + 0.4, charging: false, isRing: false)),
                       low, "Judged on the number the header ring prints.")
        XCTAssertNil(SimpleStrapStatus.lowBattery(Display.charge(pct: Double(low) + 0.5, charging: false, isRing: false)))
        XCTAssertEqual(SimpleStrapStatus.lowBattery(Display.charge(pct: 3, charging: false, isRing: false)), 3)
        XCTAssertNil(SimpleStrapStatus.lowBattery(Display.charge(pct: 8, charging: true, isRing: false)),
                     "A strap on its charger needs no reminder.")
        XCTAssertNil(SimpleStrapStatus.lowBattery(Display.charge(pct: 8, charging: false, isRing: true)),
                     "A ring's charge is not the strap's.")
        XCTAssertNil(SimpleStrapStatus.lowBattery(.offline))
        XCTAssertNil(SimpleStrapStatus.lowBattery(.pending(charging: false)))
        XCTAssertNil(SimpleStrapStatus.lowBattery(.notActiveDevice))
    }

    func testMyStrapSaysWhatTheHeaderRingShows() {
        typealias Display = LiquidTodayView.StrapBatteryDisplay
        XCTAssertEqual(SimpleStrapStatus.caption(.offline), .notConnected)
        XCTAssertEqual(SimpleStrapStatus.caption(.pending(charging: true)), .connected)
        XCTAssertEqual(SimpleStrapStatus.caption(Display.charge(pct: 82.4, charging: false, isRing: false)),
                       .battery(percent: 82, charging: false))
        XCTAssertEqual(SimpleStrapStatus.caption(Display.charge(pct: 82.5, charging: true, isRing: false)),
                       .battery(percent: 83, charging: true), "The header ring rounds the same way.")
        XCTAssertNil(SimpleStrapStatus.caption(Display.charge(pct: 50, charging: false, isRing: true)))
        XCTAssertNil(SimpleStrapStatus.caption(.notActiveDevice))
    }

    func testMoreStartsWithTheStrap() {
        XCTAssertEqual(SimpleMoreGroup.allCases.first, .strap)
        XCTAssertEqual(SimpleMoreEntry.myStrap.group, .strap)
        for showsCoach in [false, true] {
            let entries = SimpleModePrefs.moreEntries(showsCoachRow: showsCoach)
            XCTAssertEqual(entries.first, .myStrap)
            XCTAssertEqual(entries.filter { $0.group == .strap }, [.myStrap], "The strap's group holds the strap alone.")
        }
    }

    // MARK: - The guide

    func testTheGuideCarriesTheNewEntriesWhereAWearerLooks() {
        XCTAssertEqual(PlainGuideGroup.sleep.terms, [.sleepNeed, .tonightGoal, .sleepStages])
        XCTAssertEqual(PlainGuideGroup.other.terms, [.dayPlan, .activity, .stress, .heartRateZones, .estimates])
        XCTAssertEqual(PlainGuideGroup.goodToKnow.terms, [.confidence, .normalRange, .whoopDifference])
    }

    /// The entry on how sure NOOP is names the night counts from the gates and no longer describes the "Earlier
    /// score" label, which no screen shows any more.
    func testTheSurenessEntryTellsTheFirstTwoWeeksFromTheGates() {
        let detail = PlainGuideTerm.confidence.detail
        XCTAssertFalse(detail.contains("Earlier score"))
        XCTAssertTrue(detail.contains("after \(Baselines.minNightsSeed) nights"), detail)
        XCTAssertTrue(detail.contains("after \(SimpleWelcome.adviceNights)."), detail)
        XCTAssertTrue(detail.contains("After \(Baselines.minNightsTrust) nights"), detail)
        XCTAssertTrue(PlainGuideTerm.tonightGoal.detail.contains("at most \(SimpleDayPlan.catchUpCapMinutes) minutes"),
                      "Tonight's catch-up cap is the one tonight's goal uses.")
    }

    /// "How to read NOOP" names WHOOP's words through the guide's "also called", so the two cannot disagree;
    /// Rest's is WHOOP's own term (its export calls the column "Sleep performance %").
    func testWhoopsWordsAreTheGuides() {
        XCTAssertEqual(PlainGuideTerm.charge.alsoCalled, "Recovery")
        XCTAssertEqual(PlainGuideTerm.effort.alsoCalled, "Strain")
        XCTAssertEqual(PlainGuideTerm.rest.alsoCalled, "Sleep performance")
    }
}
