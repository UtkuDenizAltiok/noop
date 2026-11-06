import XCTest
import StrandAnalytics
@testable import Strand

/// Pins the Simple Today's "Your day" rules: the suggested Effort range only ever appears beside a verdict
/// that says the same thing, its words follow upstream's approved Charge → Effort mapping, it converts to
/// the 0–100 scale through the one shared rule, today's progress is judged on the number the ring prints,
/// and the sleep line resolves one night and one need.
final class SimpleDayPlanTests: XCTestCase {

    // MARK: - When the range is shown

    /// Charge 80 is a hard-day band, 50 a moderate one, 20 an easy one (CoupledView's approved mapping).
    func testRangeAppearsOnlyBesideAVerdictThatAgrees() {
        let hardBand = CoupledView.optimalStrainRange(recovery: 80)
        let moderateBand = CoupledView.optimalStrainRange(recovery: 50)
        let easyBand = CoupledView.optimalStrainRange(recovery: 20)
        let expectations: [(ReadinessEngine.Level, Double, ClosedRange<Int>?)] = [
            (.primed, 80, hardBand), (.primed, 50, nil), (.primed, 20, nil),
            (.balanced, 80, hardBand), (.balanced, 50, moderateBand), (.balanced, 20, nil),
            (.strained, 80, nil), (.strained, 50, nil), (.strained, 20, easyBand),
            (.rundown, 80, nil), (.rundown, 50, nil), (.rundown, 20, easyBand),
            // No verdict yet: Charge is the only source, so there is nothing to contradict.
            (.insufficient, 80, hardBand), (.insufficient, 50, moderateBand), (.insufficient, 20, easyBand),
        ]
        for (level, charge, expected) in expectations {
            XCTAssertEqual(SimpleDayPlan.suggestedBand(todaysCharge: charge, readiness: level), expected,
                           "readiness \(level) with Charge \(charge)")
        }
    }

    /// A carried, calibrating or past-day Charge is passed as nil and never yields advice for today.
    func testNoChargeOfTodaysOwnSuggestsNothing() {
        for level in [ReadinessEngine.Level.primed, .balanced, .strained, .rundown, .insufficient] {
            XCTAssertNil(SimpleDayPlan.suggestedBand(todaysCharge: nil, readiness: level))
        }
    }

    /// The words "easy / moderate / hard" must describe the band the approved mapping actually returns, at
    /// every Charge, so a change to `CoupledView.optimalStrainRange` cannot leave them behind.
    func testIntensityWordsFollowTheApprovedMapping() {
        var charge = 0.0
        while charge <= 100 {
            guard let band = CoupledView.optimalStrainRange(recovery: charge) else {
                return XCTFail("The mapping returned no band for Charge \(charge)")
            }
            let expected: SimpleDayPlan.Intensity = charge >= 67 ? .hard : charge >= 34 ? .moderate : .easy
            XCTAssertEqual(SimpleDayPlan.intensity(of: band), expected, "Charge \(charge)")
            charge += 0.25
        }
    }

    // MARK: - Scale and progress

    func testRangeConvertsToTheHundredScaleThroughTheSharedRule() {
        XCTAssertEqual(SimpleDayPlan.band(14...18, on: .hundred), 67...86)
        XCTAssertEqual(SimpleDayPlan.band(10...14, on: .hundred), 48...67)
        XCTAssertEqual(SimpleDayPlan.band(4...10, on: .hundred), 19...48)
        XCTAssertEqual(SimpleDayPlan.band(14...18, on: .whoop), 14...18)
        XCTAssertEqual(SimpleDayPlan.rangeText(67...86), "67–86")
    }

    /// The same two expressions as the Effort ring: a whole number on 0–100, one decimal on 0–21.
    func testEffortTextIsWhatTheRingPrints() {
        XCTAssertEqual(SimpleDayPlan.effortText(stored: 23.4, scale: .hundred), "23")
        XCTAssertEqual(SimpleDayPlan.effortText(stored: 23.5, scale: .hundred), "24")
        XCTAssertEqual(SimpleDayPlan.effortText(stored: 60, scale: .whoop), "12.6")
        XCTAssertEqual(SimpleDayPlan.effortText(stored: 0, scale: .whoop), "0.0")
    }

    /// Progress is judged on the printed number, so "So far 14.0" is never called below a range starting at 14.
    func testProgressIsJudgedOnThePrintedNumber() {
        // 66.476… on 0–100 is 13.96 on 0–21, printed "14.0".
        XCTAssertEqual(SimpleDayPlan.progress(stored: 13.96 / 0.21, scale: .whoop, band: 14...18), .within)
        XCTAssertEqual(SimpleDayPlan.progress(stored: 60, scale: .whoop, band: 14...18), .below)
        XCTAssertEqual(SimpleDayPlan.progress(stored: 86.2, scale: .whoop, band: 14...18), .above)
        // 66.6 prints "67" on 0–100: inside 67–86.
        XCTAssertEqual(SimpleDayPlan.progress(stored: 66.6, scale: .hundred, band: 67...86), .within)
        XCTAssertEqual(SimpleDayPlan.progress(stored: 66.4, scale: .hundred, band: 67...86), .below)
        XCTAssertEqual(SimpleDayPlan.progress(stored: 86.4, scale: .hundred, band: 67...86), .within)
        XCTAssertEqual(SimpleDayPlan.progress(stored: 86.5, scale: .hundred, band: 67...86), .above)
        XCTAssertEqual(SimpleDayPlan.progress(stored: nil, scale: .hundred, band: 67...86), .notStarted)
    }

    // MARK: - Sleep line

    func testSleepLineStatesOneNightAndOneNeed() {
        XCTAssertNil(SimpleDayPlan.sleepVersusNeed(asleepMin: nil, importedNeedMin: 480, normativeNeedMin: 500))
        XCTAssertNil(SimpleDayPlan.sleepVersusNeed(asleepMin: 0, importedNeedMin: nil, normativeNeedMin: 500),
                     "A night with no sleep recorded makes no claim.")
        let imported = SimpleDayPlan.sleepVersusNeed(asleepMin: 402, importedNeedMin: 470, normativeNeedMin: 500)
        XCTAssertEqual(imported?.asleep, 402)
        XCTAssertEqual(imported?.need, 470, "WHOOP's own need for the night wins, as on the Sleep tab.")
        let computed = SimpleDayPlan.sleepVersusNeed(asleepMin: 402, importedNeedMin: 0, normativeNeedMin: 500)
        XCTAssertEqual(computed?.need, 500, "A zero imported need is no need: fall back to the normative one.")
    }

    func testSleepDurationPrintsLikeTheSleepTab() {
        XCTAssertEqual(SimpleDayPlan.durationText(402.4), "6h 42m")
        XCTAssertEqual(SimpleDayPlan.durationText(45), "45m")
        XCTAssertEqual(SimpleDayPlan.durationText(-3), "0m")
    }

    /// The Rest ring names its day only when it shows an earlier night's score.
    func testCarriedRestRingNamesItsDayOnlyWhenCarried() {
        XCTAssertEqual(SimpleDayPlan.carriedRestDay(selectedDayValue: nil, shownScore: 92, tailDay: "2026-11-04"),
                       "2026-11-04")
        XCTAssertNil(SimpleDayPlan.carriedRestDay(selectedDayValue: 88, shownScore: 88, tailDay: "2026-11-06"),
                     "Today's own score needs no date.")
        XCTAssertNil(SimpleDayPlan.carriedRestDay(selectedDayValue: nil, shownScore: nil, tailDay: "2026-10-20"),
                     "A stale tail the ring does not show gets no date either.")
    }

    // MARK: - Charge readings

    func testChargeReadingsLeadWithTheBiggestMovers() {
        func reading(_ label: String, _ points: Int) -> ChargeDriver {
            ChargeDriver(label: label, deltaPoints: points, valueText: "", baselineText: "", verdict: "")
        }
        let breakdown = [reading("HRV", 4), reading("Rest", -9), reading("RHR", 4), reading("Breathing", 1),
                         reading("Skin", -6)]
        XCTAssertEqual(SimpleDayPlan.driversByImpact(breakdown).map(\.label),
                       ["Rest", "Skin", "HRV", "RHR", "Breathing"],
                       "Largest points either way first; equal ones keep the breakdown's order.")
        XCTAssertEqual(SimpleDayPlan.leadingDriverCount, 3)
    }
}

/// Tonight's plan on the Simple Today: built from the wind-down reminder's own inputs and arithmetic, shown
/// only while the reminder is on and the fall-asleep time is still ahead.
final class SimpleTonightPlanTests: XCTestCase {

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    /// 2026-11-06 is a Friday (weekday 6).
    private func tonightFixtureInstant(_ day: Int, _ hour: Int, _ minute: Int) -> Date {
        utcCalendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    private func tonightFixturePlan(_ now: Date, on: Bool = true, need: Int = 520, lead: Int = 30,
                        wake: @escaping (Int) -> Int = { _ in 7 * 60 }) -> SimpleDayPlan.TonightPlan? {
        SimpleDayPlan.tonightPlan(now: now, calendar: utcCalendar, reminderOn: on, needMinutes: need,
                                  leadMinutes: lead, wakeMinutesForWeekday: wake)
    }

    func testAfternoonPlanForTomorrowsWake() {
        let plan = tonightFixturePlan(tonightFixtureInstant(6, 15, 0))
        XCTAssertEqual(plan?.wake, tonightFixtureInstant(7, 7, 0))
        XCTAssertEqual(plan?.asleepBy, tonightFixtureInstant(6, 22, 20), "07:00 − 8h 40m")
        XCTAssertEqual(plan?.windDown, tonightFixtureInstant(6, 21, 50), "and the 30-minute lead before it")
        XCTAssertEqual(plan?.needMinutes, 520)
    }

    func testNothingWhileTheReminderIsOff() {
        XCTAssertNil(tonightFixturePlan(tonightFixtureInstant(6, 15, 0), on: false), "Its wake time is an unused setting then.")
    }

    func testNothingOnceTheFallAsleepTimeHasPassed() {
        XCTAssertNil(tonightFixturePlan(tonightFixtureInstant(6, 22, 30)), "Late evening, past 22:20.")
        XCTAssertNil(tonightFixturePlan(tonightFixtureInstant(7, 2, 0)), "After midnight: this morning's wake, its night already under way.")
        XCTAssertNil(tonightFixturePlan(tonightFixtureInstant(7, 6, 30)))
        XCTAssertNotNil(tonightFixturePlan(tonightFixtureInstant(7, 7, 30)), "After this morning's wake: tonight is the next night.")
    }

    /// Each night uses the wake time of the day being woken on, as the reminder's per-day triggers do.
    func testPerDayWakeTimeOfTheNextMorning() {
        // Friday afternoon; Saturday (7) wakes at 09:00, every other day at 07:00.
        let plan = tonightFixturePlan(tonightFixtureInstant(6, 15, 0), wake: { $0 == 7 ? 9 * 60 : 7 * 60 })
        XCTAssertEqual(plan?.wake, tonightFixtureInstant(7, 9, 0))
        XCTAssertEqual(plan?.asleepBy, tonightFixtureInstant(7, 0, 20), "past midnight, on Saturday")
        XCTAssertEqual(plan?.windDown, tonightFixtureInstant(6, 23, 50), "the reminder still fires on Friday evening")
    }

    /// Tonight's line states its need only when it cannot contradict last night's on the same card.
    func testTonightStatesItsNeedOnlyWhenItAgreesWithLastNight() {
        XCTAssertTrue(SimpleDayPlan.tonightStatesNeed(lastNightNeedMin: nil, tonightNeedMin: 520))
        XCTAssertTrue(SimpleDayPlan.tonightStatesNeed(lastNightNeedMin: 519.6, tonightNeedMin: 520))
        XCTAssertFalse(SimpleDayPlan.tonightStatesNeed(lastNightNeedMin: 436, tonightNeedMin: 480),
                       "WHOOP's imported need for last night differs from NOOP's: say no number tonight.")
    }

    /// An early wake puts the reminder on the previous evening (#1863's 03:30 example: 19:00).
    func testEarlyWakeMovesTheReminderToTheEveningBefore() {
        let plan = tonightFixturePlan(tonightFixtureInstant(6, 12, 0), need: 480, lead: 30, wake: { _ in 3 * 60 + 30 })
        XCTAssertEqual(plan?.wake, tonightFixtureInstant(7, 3, 30))
        XCTAssertEqual(plan?.windDown, tonightFixtureInstant(6, 19, 0))
    }

    /// The "wind down at" time is the minute the reminder fires: wake − need − lead, wrapped like
    /// `WindDownNudge.nudgeMinuteOfDay` / `nudgeDayShift`, over a spread of wakes and needs.
    func testWindDownTimeIsTheReminderMinute() {
        for wake in stride(from: 0, through: 1439, by: 97) {
            for need in [300, 480, 517, 570, 660] {
                let raw = wake - need - 30
                let minuteOfDay = ((raw % 1440) + 1440) % 1440
                let dayShift = raw < 0 ? -(((-raw - 1) / 1440) + 1) : raw / 1440
                // A "now" early enough that tomorrow's wake is the next one and its night is still ahead.
                let now = tonightFixtureInstant(6, 0, 0).addingTimeInterval(TimeInterval(min(wake, 1439) * 60 + 60))
                guard let plan = tonightFixturePlan(now, need: need, wake: { _ in wake }) else { continue }
                let wakeDay = utcCalendar.startOfDay(for: plan.wake)
                let expected = utcCalendar.date(byAdding: .minute, value: minuteOfDay,
                                                to: utcCalendar.date(byAdding: .day, value: dayShift, to: wakeDay)!)!
                XCTAssertEqual(plan.windDown, expected, "wake \(wake) need \(need)")
            }
        }
    }
}

/// The Simple Today observes the wind-down reminder's settings under these keys; each must be the key the
/// reminder itself reads, or Today would miss a change made on the Alarms screen.
@MainActor
final class WindDownMirrorKeyTests: XCTestCase {
    private let keys = [SimpleDayPlan.ReminderKeys.enabled, SimpleDayPlan.ReminderKeys.wake,
                        SimpleDayPlan.ReminderKeys.need, SimpleDayPlan.ReminderKeys.perDayWake]
    private var saved: [String: Any] = [:]

    override func setUp() {
        super.setUp()
        for key in keys { if let v = UserDefaults.standard.object(forKey: key) { saved[key] = v } }
    }

    override func tearDown() {
        for key in keys {
            if let v = saved[key] { UserDefaults.standard.set(v, forKey: key) } else { UserDefaults.standard.removeObject(forKey: key) }
        }
        super.tearDown()
    }

    func testMirrorKeysAreTheReminderKeys() throws {
        UserDefaults.standard.set(true, forKey: SimpleDayPlan.ReminderKeys.enabled)
        XCTAssertTrue(WindDownNudge.isEnabled)
        UserDefaults.standard.set(false, forKey: SimpleDayPlan.ReminderKeys.enabled)
        XCTAssertFalse(WindDownNudge.isEnabled)
        UserDefaults.standard.set(401, forKey: SimpleDayPlan.ReminderKeys.wake)
        XCTAssertEqual(WindDownNudge.wakeMinutes, 401)
        UserDefaults.standard.set(503, forKey: SimpleDayPlan.ReminderKeys.need)
        XCTAssertEqual(WindDownNudge.sleepNeedMinutes, 503)
        UserDefaults.standard.set(try JSONEncoder().encode(["2": 365]), forKey: SimpleDayPlan.ReminderKeys.perDayWake)
        XCTAssertEqual(WindDownNudge.perDayWakeOverrides[2], 365)
    }
}
