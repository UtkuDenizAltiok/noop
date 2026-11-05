import XCTest
@testable import StrandAnalytics
@testable import Strand

/// Pins Simple mode's everyday wording of the Charge driver rows (`PlainChargeWording`): every verdict the
/// analytics can produce has a plain sentence, each sentence says what the printed points say, the figures
/// are the analytics' own, and skin temperature follows the reader's unit. Assertions compare against the
/// catalogue lookups, so they hold in any test-host language.
final class PlainChargeWordingTests: XCTestCase {

    // The plain sentences grouped by what they claim the reading did to Charge.
    private let raisedSentences: Set<String> = [
        String(localized: "Higher than your normal, which raised your Charge."),
        String(localized: "Lower than your normal, which raised your Charge."),
        String(localized: "Just above your normal, which raised your Charge a little."),
        String(localized: "Just below your normal, which raised your Charge a little."),
        String(localized: "A good night's sleep, which raised your Charge."),
    ]
    private let loweredSentences: Set<String> = [
        String(localized: "Higher than your normal, which lowered your Charge."),
        String(localized: "Lower than your normal, which lowered your Charge."),
        String(localized: "Just above your normal, which lowered your Charge a little."),
        String(localized: "Just below your normal, which lowered your Charge a little."),
        String(localized: "Lower than your normal, which lowered your Charge. Your resting heart rate is unusually low too: in fit people, that mix can mean a very rested body rather than a tired one."),
        String(localized: "Not quite a good night's sleep, which lowered your Charge."),
        String(localized: "Warmer than your normal, which lowered your Charge."),
        String(localized: "Cooler than your normal, which lowered your Charge."),
    ]
    private let unchangedSentences: Set<String> = [
        String(localized: "The same as your normal, so it didn't change your Charge."),
        String(localized: "Higher than your normal, but not by enough to change your Charge."),
        String(localized: "Lower than your normal, but not by enough to change your Charge."),
        String(localized: "A typical good night, so it didn't change your Charge."),
        String(localized: "Close to your normal, so it didn't change your Charge."),
    ]

    /// Every (verdict, points) pair the analytics can hand the row, from the analytics' own verdict
    /// functions over a spread of values, baselines and points. A value exactly at its baseline is worth
    /// 0 points by construction (`chargeDrivers` neutralises the term at the baseline mean), so that
    /// impossible pairing is left out.
    private func emittedVerdictPairs() -> [(verdict: String, points: Int)] {
        var pairs: [(String, Int)] = []
        for digits in [0, 1] {
            for step in -40...40 {
                let value = 60.0 + Double(step) * (digits == 0 ? 0.25 : 0.025)
                for points in -3...3 where !(value == 60.0 && points != 0) {
                    pairs.append((RecoveryScorer.baselineVerdict(value: value, baseline: 60, deltaPoints: points,
                                                                 fractionDigits: digits), points))
                    pairs.append((RecoveryScorer.hrvVerdict(value: value, baseline: 60, deltaPoints: points,
                                                            saturationDetected: true), points))
                }
            }
        }
        for perf in [0.40, 0.84, RecoveryScorer.sleepPerfCenter, 0.86, 0.97] {
            for points in -3...3 { pairs.append((RecoveryScorer.sleepVerdict(sleepPerf: perf), points)) }
        }
        for dev in [-0.6, -0.04, 0.04, 0.6] {
            for points in [-4, -1, 0] { pairs.append((RecoveryScorer.skinTempVerdict(dev, deltaPoints: points), points)) }
        }
        return pairs
    }

    func testEveryVerdictTheAnalyticsCanEmitHasAPlainSentence() {
        for (verdict, points) in emittedVerdictPairs() {
            XCTAssertNotNil(PlainChargeWording.verdict(verdict, deltaPoints: points),
                            "No plain sentence for the analytics verdict \"\(verdict)\"")
        }
    }

    func testEachSentenceSaysWhatThePrintedPointsSay() {
        for (verdict, points) in emittedVerdictPairs() {
            guard let plain = PlainChargeWording.verdict(verdict, deltaPoints: points) else { continue }
            if points > 0 {
                XCTAssertTrue(raisedSentences.contains(plain), "\(points) pts beside \"\(plain)\" (\(verdict))")
            } else if points < 0 {
                XCTAssertTrue(loweredSentences.contains(plain), "\(points) pts beside \"\(plain)\" (\(verdict))")
            } else {
                XCTAssertTrue(unchangedSentences.contains(plain), "0 pts beside \"\(plain)\" (\(verdict))")
            }
        }
    }

    /// The same check over rows the real driver builder produced, so the points are the real ones.
    func testRealDriverRowsReadConsistently() {
        func learned(_ mean: Double, _ spread: Double) -> BaselineState {
            BaselineState(baseline: mean, spread: spread, nValid: 30, nightsSinceUpdate: 0, status: .trusted)
        }
        var rows = 0
        for hrv in stride(from: 40.0, through: 90.0, by: 5) {
            for rhr in stride(from: 50.0, through: 66.0, by: 2) {
                for perf in [0.6, 0.85, 0.95] {
                    for dev in [-0.5, 0.0, 0.03, 0.6] {
                        let drivers = RecoveryScorer.chargeDrivers(
                            hrv: hrv, rhr: rhr, resp: 14 + (hrv - 65) / 50,
                            hrvBaseline: learned(65, 12), rhrBaseline: learned(58, 3),
                            respBaseline: learned(14.5, 0.8), sleepPerf: perf, skinTempDev: dev)
                        for d in drivers {
                            rows += 1
                            guard let plain = PlainChargeWording.verdict(d.verdict, deltaPoints: d.deltaPoints) else {
                                XCTFail("No plain sentence for \"\(d.verdict)\""); continue
                            }
                            let expected = d.deltaPoints > 0 ? raisedSentences
                                : d.deltaPoints < 0 ? loweredSentences : unchangedSentences
                            XCTAssertTrue(expected.contains(plain), "\(d.label) \(d.deltaPoints) pts: \"\(plain)\"")
                        }
                    }
                }
            }
        }
        XCTAssertGreaterThan(rows, 1000, "The sweep must actually produce rows")
    }

    func testFiguresAreTheAnalyticsOwn() {
        let hrv = ChargeDriver(label: "Heart rate variability", deltaPoints: 8, valueText: "89 ms",
                               baselineText: "85 ms baseline", verdict: "above baseline, supporting recovery")
        let plainHrv = PlainChargeWording.driver(hrv, skinTempDevC: nil, temperatureUnit: .celsius)
        XCTAssertEqual(plainHrv.deltaPoints, 8)
        XCTAssertEqual(plainHrv.valueText, "89 ms")
        XCTAssertEqual(plainHrv.baselineText, String(localized: "usually \("85 ms")"))
        XCTAssertEqual(plainHrv.label, String(localized: "Heart-rate variability"))

        let rest = ChargeDriver(label: "Sleep quality", deltaPoints: 3, valueText: "92%",
                                baselineText: "", verdict: "a strong night, supporting recovery")
        let plainRest = PlainChargeWording.driver(rest, skinTempDevC: nil, temperatureUnit: .celsius)
        XCTAssertEqual(plainRest.label, String(localized: "Rest"), "The row is the Rest score and carries its name")
        XCTAssertEqual(plainRest.valueText, "92", "Reads like the Rest ring")
        XCTAssertEqual(plainRest.baselineText, "")

        let breathing = ChargeDriver(label: "Respiratory rate", deltaPoints: 1, valueText: "14.2 br/min",
                                     baselineText: "14.6 br/min baseline", verdict: "below baseline, supporting recovery")
        let plainBreathing = PlainChargeWording.driver(breathing, skinTempDevC: nil, temperatureUnit: .celsius)
        let unit = String(localized: "breaths/min")
        XCTAssertEqual(plainBreathing.label, String(localized: "Breathing rate"))
        XCTAssertEqual(plainBreathing.valueText, "14.2 " + unit)
        XCTAssertEqual(plainBreathing.baselineText, String(localized: "usually \("14.6 " + unit)"))
    }

    func testSkinTemperatureFollowsTheReadersUnit() {
        let skin = ChargeDriver(label: "Skin temperature", deltaPoints: -2, valueText: "+0.4 C vs baseline",
                                baselineText: "", verdict: "warmer than baseline, limiting recovery")
        XCTAssertEqual(PlainChargeWording.driver(skin, skinTempDevC: 0.4, temperatureUnit: .celsius).valueText, "+0.4 °C")
        // A difference converts by 9/5 with no +32 offset, from the unrounded deviation: 0.44 °C is 0.792 °F.
        XCTAssertEqual(PlainChargeWording.driver(skin, skinTempDevC: 0.44, temperatureUnit: .fahrenheit).valueText, "+0.8 °F")
        XCTAssertEqual(PlainChargeWording.skinTempDeviation(-0.3, unit: .fahrenheit), "-0.5 °F")
        // Without the raw figure the analytics' own text is kept rather than guessed at.
        XCTAssertEqual(PlainChargeWording.driver(skin, skinTempDevC: nil, temperatureUnit: .fahrenheit).valueText,
                       "+0.4 C vs baseline")
    }

    func testAnUnknownVerdictKeepsTheOriginalText() {
        XCTAssertNil(PlainChargeWording.verdict("a verdict added later", deltaPoints: 1))
        let future = ChargeDriver(label: "Something new", deltaPoints: 1, valueText: "1",
                                  baselineText: "", verdict: "a verdict added later")
        let plain = PlainChargeWording.driver(future, skinTempDevC: nil, temperatureUnit: .celsius)
        XCTAssertEqual(plain.verdict, String(localized: String.LocalizationValue("a verdict added later")))
        XCTAssertEqual(plain.label, String(localized: String.LocalizationValue("Something new")))
    }
}
