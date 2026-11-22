import XCTest
import SwiftUI
import StrandAnalytics
import WhoopStore
@testable import Strand

/// Pins the rules behind Design v6's step 4, "Is my body all right?": the Health monitor judges each reading on
/// the numbers it prints against the very range its band judges by, its verdict says "still learning" or "a gap
/// in wear" for the right reason and saves the illness line for a reading outside the wearer's own normal, and
/// the Stress screen names only a reading that moved, colours only a clear change and counts calm mornings the
/// way its band does.
final class SimpleHealthV6Tests: XCTestCase {

    // MARK: Fixtures (named unlike any production function: the parity ledger pairs calls by name)

    private func healthV6Reading(key: String, value: Double?, range: ClosedRange<Double>?,
                                 basis: VitalBands.Basis = .personal, nights: Int = 30,
                                 day: String = "2026-11-20") -> BodyVitalReading {
        BodyVitalReading(key: key, label: key, unit: "u", value: value,
                         format: { String(Int($0.rounded())) },
                         banding: VitalBands.Result(band: value == nil ? .noData : .inRange, basis: basis, nights: nights),
                         metricColor: .gray, day: value == nil ? nil : day, source: .noopComputed,
                         missingCaption: "none", normalRange: range)
    }

    private func healthV6Row(_ key: String, word: SimpleHealthRules.Word?, basis: SimpleHealthRules.Basis = .personal,
                             nights: Int = 30, value: String? = "1") -> SimpleHealthRules.Row {
        SimpleHealthRules.Row(key: key, printedValue: value, printedLow: "0", printedHigh: "2", basis: basis,
                              word: word, carriedDayKey: nil, nights: nights, canBePersonal: key != "spo2")
    }

    private func healthV6Daily(day: String, restingHr: Int?, avgHrv: Double?, spo2Pct: Double? = nil) -> DailyMetric {
        DailyMetric(day: day, totalSleepMin: nil, efficiency: nil, deepMin: nil, remMin: nil, lightMin: nil,
                    disturbances: nil, restingHr: restingHr, avgHrv: avgHrv, recovery: nil, strain: nil,
                    exerciseCount: nil, spo2Pct: spo2Pct)
    }

    // MARK: - Rows

    /// The two readings that move most come first; the raw SpO₂ counts, which have no range and no meaning on
    /// their own, stay in Show everything.
    func testRowsFollowTheReadingOrderAndLeaveOutTheRawCounts() {
        let readings = ["resp", "spo2", "spo2raw", "rhr", "hrv", "skin"].map { healthV6Reading(key: $0, value: 1, range: 0...2) }
        XCTAssertEqual(SimpleHealthRules.rows(readings, todayKey: "2026-11-20").map(\.key),
                       ["rhr", "hrv", "resp", "spo2", "skin"])
    }

    /// 61.8 prints as 62, and so does the band's top of 61.6: the row must not call "62" higher than "52–62".
    func testAReadingIsJudgedOnItsPrintedNumbers() {
        let range: ClosedRange<Double> = 52.3...61.6
        let edge = SimpleHealthRules.rows([healthV6Reading(key: "rhr", value: 61.8, range: range)], todayKey: "2026-11-20").first
        XCTAssertEqual(edge?.printedValue, "62")
        XCTAssertEqual(edge?.printedHigh, "62")
        XCTAssertEqual(edge?.word, .within)
        XCTAssertEqual(SimpleHealthRules.rows([healthV6Reading(key: "rhr", value: 62.6, range: range)],
                                              todayKey: "2026-11-20").first?.word, .higher)
        XCTAssertEqual(SimpleHealthRules.rows([healthV6Reading(key: "rhr", value: 51.4, range: range)],
                                              todayKey: "2026-11-20").first?.word, .lower)
    }

    /// A reading from an earlier night says which night; tonight's own says nothing extra.
    func testACarriedReadingNamesItsNight() {
        let rows = SimpleHealthRules.rows([healthV6Reading(key: "rhr", value: 55, range: 50...60, day: "2026-11-20"),
                                           healthV6Reading(key: "hrv", value: 60, range: 40...80, day: "2026-11-18")],
                                          todayKey: "2026-11-20")
        XCTAssertNil(rows.first { $0.key == "rhr" }?.carriedDayKey)
        XCTAssertEqual(rows.first { $0.key == "hrv" }?.carriedDayKey, "2026-11-18")
    }

    func testRangeTextTrimsWholeAdultRangesAndSpacesSignedEnds() {
        XCTAssertEqual(SimpleHealthRules.rangeText(low: "12.0", high: "20.0", basis: .typical), "12–20")
        XCTAssertEqual(SimpleHealthRules.rangeText(low: "13.6", high: "16.0", basis: .personal), "13.6–16.0")
        XCTAssertEqual(SimpleHealthRules.rangeText(low: "-0.4", high: "+0.5", basis: .personal), "-0.4 – +0.5")
        XCTAssertEqual(SimpleHealthRules.rangeText(low: "55", high: "55", basis: .personal), "55")
    }

    // MARK: - The range is the band's own

    /// Every value inside the printed range is one the band calls in range, and every value outside is not: the
    /// row's word and the full view's tile come from one fold.
    func testThePrintedRangeIsTheRangeTheBandJudgesBy() throws {
        let cfg = Baselines.restingHRCfg
        let history: [Double?] = (0..<30).map { 55 + Double([0, 2, -1, 3, -2, 1, -3, 2][$0 % 8]) }
        let population: ClosedRange<Double> = 40...60
        let probe = VitalBands.band(value: 55, history: history, populationRange: population, cfg: cfg)
        XCTAssertEqual(probe.basis, .personal)
        let range = try XCTUnwrap(BodyVitalSigns.judgedRange(probe, history: history, populationRange: population, cfg: cfg))
        XCTAssertNotEqual(range, population)
        for step in 0...400 {
            let value = 40 + Double(step) * 0.1
            let band = VitalBands.band(value: value, history: history, populationRange: population, cfg: cfg)
            XCTAssertEqual(range.contains(value), band.band == .inRange, "at \(value)")
        }
    }

    /// Until the wearer's baseline is trusted the band falls back to the adult range, and so does the range.
    func testTheRangeIsTheAdultOneUntilTheBaselineIsTrusted() {
        let cfg = Baselines.restingHRCfg
        let history: [Double?] = [55, 56, 54, 57, 55]
        let band = VitalBands.band(value: 58, history: history, populationRange: 40...60, cfg: cfg)
        XCTAssertEqual(band.basis, .population)
        XCTAssertEqual(BodyVitalSigns.judgedRange(band, history: history, populationRange: 40...60, cfg: cfg), 40...60)
        XCTAssertNil(BodyVitalSigns.judgedRange(VitalBands.Result(band: .noData, basis: .population, nights: 0),
                                                history: history, populationRange: 40...60, cfg: cfg))
    }

    /// The readings the screen draws carry that range: the wearer's own for a trusted resting heart rate, the
    /// healthy range for blood oxygen, none without a value or for the raw counts.
    func testReadingsCarryTheirJudgedRange() throws {
        let today = BodyVitalSigns.logicalDayKey(Date())
        let rows: [SourcedDailyMetric] = (0...24).reversed().map { back in
            let day = Baselines.cutoffKey(todayKey: today, carryDays: back)
            return SourcedDailyMetric(metric: healthV6Daily(day: day, restingHr: 55 + [0, 2, -1, 3, -2][back % 5],
                                                            avgHrv: nil, spo2Pct: back == 0 ? 97 : nil),
                                      source: .noopComputed)
        }
        let readings = BodyVitalSigns.readings(sourceRows: rows, temperatureUnit: .celsius)
        let rhr = try XCTUnwrap(readings.first { $0.key == "rhr" })
        XCTAssertEqual(rhr.banding.basis, .personal)
        let range = try XCTUnwrap(rhr.normalRange)
        XCTAssertEqual(range.contains(try XCTUnwrap(rhr.value)), rhr.banding.band == .inRange)
        XCTAssertTrue(range.lowerBound > 40 && range.upperBound < 70, "\(range)")
        XCTAssertEqual(readings.first { $0.key == "spo2" }?.normalRange, 95...100)
        XCTAssertNil(readings.first { $0.key == "hrv" }?.normalRange)
        XCTAssertNil(readings.first { $0.key == "spo2raw" }?.normalRange)
    }

    /// A blank HRV refused for over-counted beats is told apart from a night that never happened.
    func testReadingsMarkAnHrvRefusedForOverCountedBeats() {
        let today = BodyVitalSigns.logicalDayKey(Date())
        let refused = BodyVitalSigns.readings(sourceRows: [], temperatureUnit: .celsius, hrvOverCountByDay: [today: 1])
        XCTAssertEqual(refused.first { $0.key == "hrv" }?.blankedByOverCount, true)
        let clean = BodyVitalSigns.readings(sourceRows: [], temperatureUnit: .celsius, hrvOverCountByDay: [today: 0])
        XCTAssertEqual(clean.first { $0.key == "hrv" }?.blankedByOverCount, false)
        var blank = healthV6Reading(key: "hrv", value: nil, range: nil)
        let plain = SimpleHealthWords.missingLine(blank)
        blank.blankedByOverCount = true
        XCTAssertNotEqual(SimpleHealthWords.missingLine(blank), plain)
    }

    // MARK: - Verdict

    func testTheVerdictIsAllClearAgainstTheWearersOwnNormal() {
        let rows = ["rhr", "hrv", "resp", "skin"].map { healthV6Row($0, word: .within) }
        XCTAssertEqual(SimpleHealthRules.verdict(rows), .allClear(learning: nil))
    }

    /// While some readings are still on adult ranges, the verdict says how far along the slowest one is.
    func testTheVerdictCountsTheFewestNightsWhileLearning() {
        let rows = [healthV6Row("rhr", word: .within, basis: .typical, nights: 9),
                    healthV6Row("hrv", word: .within, basis: .typical, nights: 6)]
        XCTAssertEqual(SimpleHealthRules.verdict(rows),
                       .allClear(learning: .nights(have: 6, need: Baselines.minNightsTrust)))
    }

    /// Blood oxygen has one healthy range for everyone, so it never makes the screen say "still learning".
    func testBloodOxygenNeverCountsAsLearning() {
        let rows = [healthV6Row("rhr", word: .within), healthV6Row("spo2", word: .within, basis: .typical, nights: 0)]
        XCTAssertEqual(SimpleHealthRules.verdict(rows), .allClear(learning: nil))
    }

    /// Adult ranges with the nights already there mean a gap in wear made the baseline stale.
    func testAnAdultRangeAfterTrustedNightsIsAGapNotLearning() {
        let rows = [healthV6Row("rhr", word: .within, basis: .typical, nights: 40)]
        XCTAssertEqual(SimpleHealthRules.verdict(rows), .allClear(learning: .stale))
    }

    /// The line about illness and strain is for a reading outside the wearer's own normal, or blood oxygen below
    /// its healthy range; a reading outside an adult range in the first nights is more often just the wearer.
    func testTheIllnessLineIsOnlyForTheOwnNormalOrBloodOxygen() {
        let firstNights = [healthV6Row("rhr", word: .higher, basis: .typical, nights: 5),
                           healthV6Row("hrv", word: .within, basis: .typical, nights: 5)]
        XCTAssertEqual(SimpleHealthRules.verdict(firstNights),
                       .outside(keys: ["rhr"], learning: .nights(have: 5, need: Baselines.minNightsTrust), cautious: false))
        let own = [healthV6Row("rhr", word: .within), healthV6Row("resp", word: .higher)]
        XCTAssertEqual(SimpleHealthRules.verdict(own), .outside(keys: ["resp"], learning: nil, cautious: true))
        let oxygen = [healthV6Row("rhr", word: .within, basis: .typical, nights: 5),
                      healthV6Row("spo2", word: .lower, basis: .typical, nights: 0)]
        XCTAssertEqual(SimpleHealthRules.verdict(oxygen),
                       .outside(keys: ["spo2"], learning: .nights(have: 5, need: Baselines.minNightsTrust), cautious: true))
        XCTAssertEqual(SimpleHealthWords.lines(.outside(keys: ["resp"], learning: nil, cautious: true)).count, 2)
        XCTAssertEqual(SimpleHealthWords.lines(.outside(keys: ["rhr"], learning: .stale, cautious: false)).count, 2)
    }

    func testNoValuesMeansNoReadingsYet() {
        let rows = ["rhr", "hrv", "resp"].map { healthV6Row($0, word: nil, value: nil) }
        XCTAssertEqual(SimpleHealthRules.verdict(rows), .noReadings)
    }

    // MARK: - Stress

    /// The sentence names only a reading that moved the band's way, by the full view's threshold. A calm morning
    /// carried by a resting heart rate well down, with HRV a few ms down, is the heart rate's: the full view's
    /// "at or below baseline" was untrue of the HRV.
    func testTheStressSentenceNamesOnlyAReadingThatMoved() {
        XCTAssertEqual(SimpleStressRules.sentence(band: .low, rhrDelta: -6, hrvDelta: -3), .lowRHR)
        XCTAssertEqual(SimpleStressRules.sentence(band: .low, rhrDelta: -6, hrvDelta: 4), .lowBoth)
        XCTAssertEqual(SimpleStressRules.sentence(band: .low, rhrDelta: 0, hrvDelta: 4), .lowHRV)
        XCTAssertEqual(SimpleStressRules.sentence(band: .low, rhrDelta: nil, hrvDelta: nil), .lowOther)
        XCTAssertEqual(SimpleStressRules.sentence(band: .medium, rhrDelta: 2, hrvDelta: -2), .mediumRHR)
        XCTAssertEqual(SimpleStressRules.sentence(band: .medium, rhrDelta: 0.5, hrvDelta: -2), .mediumHRV)
        XCTAssertEqual(SimpleStressRules.sentence(band: .medium, rhrDelta: -3, hrvDelta: 3), .mediumOther)
        XCTAssertEqual(SimpleStressRules.sentence(band: .high, rhrDelta: 3, hrvDelta: -5), .highBoth)
        XCTAssertEqual(SimpleStressRules.sentence(band: .high, rhrDelta: -2, hrvDelta: -5), .highHRV)
        XCTAssertEqual(SimpleStressRules.sentence(band: .high, rhrDelta: 3, hrvDelta: 2), .highRHR)
        XCTAssertEqual(SimpleStressRules.sentence(band: .high, rhrDelta: 1.0, hrvDelta: -1.0), .highOther)
    }

    /// Green or amber only for a change of at least one of the wearer's own spreads; a 1 ms dip stays plain.
    func testAMarkerIsColouredOnlyForAClearChange() {
        typealias M = SimpleStressRules.Marker
        XCTAssertEqual(SimpleStressRules.marker(delta: -1.2, spread: 8, higherIsStress: false),
                       M(amount: 1, direction: .lower, tone: .neutral))
        XCTAssertEqual(SimpleStressRules.marker(delta: -9, spread: 8, higherIsStress: false),
                       M(amount: 9, direction: .lower, tone: .strained))
        XCTAssertEqual(SimpleStressRules.marker(delta: 3, spread: 2, higherIsStress: true),
                       M(amount: 3, direction: .higher, tone: .strained))
        XCTAssertEqual(SimpleStressRules.marker(delta: -3, spread: 2, higherIsStress: true),
                       M(amount: 3, direction: .lower, tone: .calm))
        XCTAssertEqual(SimpleStressRules.marker(delta: 0.4, spread: 2, higherIsStress: true),
                       M(amount: 0, direction: .same, tone: .neutral))
        XCTAssertEqual(SimpleStressRules.marker(delta: 5, spread: 0, higherIsStress: true)?.tone, .neutral)
        XCTAssertNil(SimpleStressRules.marker(delta: nil, spread: 2, higherIsStress: true))
    }

    /// One range picker everywhere: Stress offers the six ranges Trends offers.
    func testStressOffersTheRangesTrendsOffers() {
        XCTAssertEqual(SimpleStressRules.ranges.map(\.rawValue), TrendsView.Range.allCases.map(\.rawValue))
        XCTAssertEqual(SimpleStressRules.shownRange(.twoWeeks), .month)
        XCTAssertEqual(SimpleStressRules.shownRange(.quarter), .quarter)
    }

    /// The calm days are the LOW mornings among the last up-to-30 charted, by the band's own threshold, and the
    /// score names the night it was worked out from when today has no reading yet (#543).
    func testStressModelCountsCalmMorningsAndKeepsTheScoredNight() throws {
        let start = "2026-10-01"
        var days: [DailyMetric] = (0..<40).map { i in
            healthV6Daily(day: SimpleScoreRules.dayKey(start, addingDays: i) ?? start,
                          restingHr: 55 + [0, 3, -2, 4, -3, 1][i % 6],
                          avgHrv: 60 + [0, -6, 5, -8, 7, -1][i % 6])
        }
        days.append(healthV6Daily(day: SimpleScoreRules.dayKey(start, addingDays: 40) ?? start, restingHr: nil, avgHrv: nil))
        let model = try XCTUnwrap(StressModel(days: days, stored: []))
        XCTAssertEqual(model.dayKey, SimpleScoreRules.dayKey(start, addingDays: 39))
        let recent = model.fullTrend.suffix(30)
        XCTAssertEqual(model.calmWindow, recent.count)
        XCTAssertEqual(model.calmDays, recent.filter { StressBand(score: $0.value) == .low }.count)
        XCTAssertGreaterThan(recent.filter { StressBand(score: $0.value) == .medium }.count, 0, "the fixture needs medium days")
        XCTAssertGreaterThan(model.rhrSpread, 0)
        XCTAssertGreaterThan(model.hrvSpread, 0)
    }
}
