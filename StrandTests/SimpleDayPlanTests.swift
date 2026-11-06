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
