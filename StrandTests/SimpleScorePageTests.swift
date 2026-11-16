import XCTest
import StrandAnalytics
import WhoopStore
@testable import Strand

/// Pins the rules behind Design v6's score pages ("tap a score, get an answer"): the parts of a Rest score
/// always add up to the number on the ring and are shown only for the night that number belongs to, the
/// usual range a score is compared with is the middle half of the days before it, the comparison is judged
/// on the numbers as printed, the last seven days end on the selected day, and the Charge rows describe one
/// night.
final class SimpleScorePageTests: XCTestCase {

    private func scorePageFixtureNight(_ day: String = "2026-11-16", asleep: Double?, efficiency: Double?,
                                       deep: Double?, rem: Double?) -> DailyMetric {
        DailyMetric(day: day, totalSleepMin: asleep, efficiency: efficiency, deepMin: deep, remMin: rem,
                    lightMin: nil, disturbances: nil, restingHr: nil, avgHrv: nil, recovery: nil, strain: nil,
                    exerciseCount: nil)
    }

    private func scorePageFixtureSeries(_ values: [(Int, Double)]) -> [(day: String, value: Double)] {
        values.map { (day: String(format: "2026-11-%02d", $0.0), value: $0.1) }
    }

    // MARK: - The parts of the Rest score

    /// The four parts, as printed, must add up to the score as the ring prints it, for every night: a list
    /// of parts that sums to another number than the one above it is two readouts that disagree.
    func testRestPartsAlwaysAddUpToTheScoreTheRingPrints() {
        var nights = 0
        for asleep in stride(from: 45.0, through: 615.0, by: 19.0) {
            for efficiency in [0.55, 0.71, 0.86, 0.93, 0.975, 1.0] {
                for deep in [0.0, 12.0, 41.0, 77.0, 118.0] {
                    for rem in [0.0, 33.0, 96.0, 141.0] where deep + rem <= asleep {
                        let night = scorePageFixtureNight(asleep: asleep, efficiency: efficiency, deep: deep, rem: rem)
                        guard let score = AnalyticsEngine.Rest.composite(daily: night),
                              let breakdown = SimpleScoreRules.restBreakdown(daily: night) else {
                            return XCTFail("no score for \(asleep) min asleep")
                        }
                        nights += 1
                        XCTAssertEqual(breakdown.printedScore, Int(score.rounded()))
                        XCTAssertEqual(breakdown.parts.map(\.points).reduce(0, +), Int(score.rounded()),
                                       "parts of a \(asleep)-minute night do not add up to its score")
                        XCTAssertEqual(breakdown.parts.map(\.kind),
                                       [.duration, .efficiency, .restorative, .regularity])
                        XCTAssertEqual(breakdown.parts.map(\.maxPoints), [50, 20, 20, 10])
                        for part in breakdown.parts {
                            XCTAssertTrue((0...part.maxPoints).contains(part.points),
                                          "\(part.kind) has \(part.points) of \(part.maxPoints)")
                        }
                    }
                }
            }
        }
        XCTAssertGreaterThan(nights, 1000)
    }

    /// The regularity part is not measured for the score shown: it is the neutral half for every night, so
    /// the page may say so, and the highest score it names is the score a perfect night really gets.
    func testRestRegularityIsTheNeutralHalfAndCapsTheScore() {
        let perfect = scorePageFixtureNight(asleep: 600, efficiency: 1.0, deep: 150, rem: 150)
        guard let breakdown = SimpleScoreRules.restBreakdown(daily: perfect) else { return XCTFail("no breakdown") }
        XCTAssertEqual(breakdown.parts.last?.kind, .regularity)
        XCTAssertEqual(breakdown.parts.last?.points, 5)
        XCTAssertEqual(breakdown.highestPossible, 95)
        XCTAssertEqual(AnalyticsEngine.Rest.composite(daily: perfect), 95)
        XCTAssertEqual(breakdown.printedScore, breakdown.highestPossible)
        // A full night is the hours the score function counts, whatever the Sleep tab's personal need says.
        XCTAssertEqual(breakdown.fullNightMin, AnalyticsEngine.Rest.defaultNeedHours * 60)
        let short = scorePageFixtureNight(asleep: 300, efficiency: 0.8, deep: 10, rem: 60)
        XCTAssertEqual(SimpleScoreRules.restBreakdown(daily: short)?.parts.last?.points, 5)
        XCTAssertEqual(SimpleScoreRules.restBreakdown(daily: short)?.deepWasShort, true)
        XCTAssertEqual(breakdown.deepWasShort, false)
    }

    /// A night with no sleep has no score and so no parts.
    func testRestBreakdownNeedsANightToScore() {
        XCTAssertNil(SimpleScoreRules.restBreakdown(daily: scorePageFixtureNight(asleep: nil, efficiency: 0.9, deep: 1, rem: 1)))
        XCTAssertNil(SimpleScoreRules.restBreakdown(daily: scorePageFixtureNight(asleep: 0, efficiency: 0.9, deep: 1, rem: 1)))
        XCTAssertNil(SimpleScoreRules.restBreakdown(daily: scorePageFixtureNight(asleep: 420, efficiency: nil, deep: 1, rem: 1)))
    }

    /// The parts are listed only when they are the shown number's own: never for a score WHOOP provided,
    /// and never when the night's totals score differently from the number on the ring.
    func testRestPartsAreShownOnlyForTheShownScoresOwnNight() {
        let night = scorePageFixtureNight(asleep: 459, efficiency: 0.93, deep: 62, rem: 94)
        guard let own = AnalyticsEngine.Rest.composite(daily: night) else { return XCTFail("no score") }
        guard case .success(let breakdown) = SimpleScoreRules.restParts(shownScore: own, daily: night, importedScore: nil) else {
            return XCTFail("a night's own score must show its parts")
        }
        XCTAssertEqual(breakdown.printedScore, Int(own.rounded()))
        XCTAssertEqual(SimpleScoreRules.restParts(shownScore: own, daily: night, importedScore: 91),
                       .failure(.importedScore))
        XCTAssertEqual(SimpleScoreRules.restParts(shownScore: own + 4, daily: night, importedScore: nil),
                       .failure(.notFromTheseTotals))
        XCTAssertEqual(SimpleScoreRules.restParts(shownScore: own, daily: nil, importedScore: nil),
                       .failure(.notFromTheseTotals))
    }

    func testWholePointsAddUpToTheTotal() {
        // 47 + 18 + 13 + 5 is 83: the two points still missing go to the largest remainders (.9, then .8).
        XCTAssertEqual(SimpleScoreRules.wholePoints([47.8, 18.6, 13.9, 5.0], total: 85), [48, 18, 14, 5])
        XCTAssertEqual(SimpleScoreRules.wholePoints([50, 20, 20, 5], total: 95), [50, 20, 20, 5])
        XCTAssertEqual(SimpleScoreRules.wholePoints([10.5, 10.5], total: 21), [11, 10])
        XCTAssertEqual(SimpleScoreRules.wholePoints([0.4, 0.4], total: 1).reduce(0, +), 1)
        XCTAssertEqual(SimpleScoreRules.wholePoints([3.0, 2.0], total: 4).reduce(0, +), 4)
        XCTAssertEqual(SimpleScoreRules.wholePoints([], total: 3), [])
    }

    // MARK: - Compared with you

    /// The usual range is the quartiles of the scored days in the 30 days before the day itself: never the
    /// day, never older days, and nothing until a week of days exists.
    func testUsualRangeIsTheMiddleHalfOfTheEarlierDaysInTheWindow() {
        let week = scorePageFixtureSeries([(9, 40), (10, 90), (11, 46), (12, 52), (13, 44), (14, 48), (15, 10)])
        // Sorted: 10 40 44 46 48 52 90. Quartiles by interpolation: 42, 46, 50.
        XCTAssertEqual(SimpleScoreRules.usualRange(series: week, before: "2026-11-16"),
                       .init(low: 42, middle: 46, high: 50))
        // The day itself does not count toward its own usual.
        XCTAssertEqual(SimpleScoreRules.usualRange(series: week + scorePageFixtureSeries([(16, 99)]),
                                                   before: "2026-11-16")?.middle, 46)
        // Six days are not a week.
        XCTAssertNil(SimpleScoreRules.usualRange(series: Array(week.dropFirst()), before: "2026-11-16"))
        // A zero is a real score and counts.
        let withZero = scorePageFixtureSeries([(9, 0), (10, 0), (11, 0), (12, 0), (13, 44), (14, 48), (15, 10)])
        XCTAssertEqual(SimpleScoreRules.usualRange(series: withZero, before: "2026-11-16"),
                       .init(low: 0, middle: 0, high: 27))
        // Days older than the window are left out: the same week read 31 days later is no longer usual.
        XCTAssertNil(SimpleScoreRules.usualRange(series: week, before: "2026-12-16"))
        XCTAssertEqual(SimpleScoreRules.usualRange(series: week, before: "2026-12-09")?.middle, 46)
        XCTAssertNil(SimpleScoreRules.usualRange(series: week, before: "not a day"))
        // The range never turns over, whatever the days hold.
        for values in [[5.0, 5, 5, 5, 5, 5, 5], [1, 2, 3, 4, 5, 6, 7, 8], [100, 0, 100, 0, 100, 0, 100, 0, 50]] {
            let series = values.enumerated().map { (day: String(format: "2026-11-%02d", $0.offset + 1), value: $0.element) }
            guard let range = SimpleScoreRules.usualRange(series: series, before: "2026-11-16") else {
                return XCTFail("no range for \(values)")
            }
            XCTAssertLessThanOrEqual(range.low, range.middle)
            XCTAssertLessThanOrEqual(range.middle, range.high)
        }
    }

    func testQuantileInterpolatesBetweenTheNearestValues() {
        XCTAssertEqual(SimpleScoreRules.quantile([10, 20, 30, 40], 0.5), 25)
        XCTAssertEqual(SimpleScoreRules.quantile([10, 20, 30, 40], 0.25), 17.5)
        XCTAssertEqual(SimpleScoreRules.quantile([10, 20, 30, 40], 0), 10)
        XCTAssertEqual(SimpleScoreRules.quantile([10, 20, 30, 40], 1), 40)
        XCTAssertEqual(SimpleScoreRules.quantile([7], 0.75), 7)
        XCTAssertTrue(SimpleScoreRules.quantile([], 0.5).isNaN)
    }

    /// Higher or lower is said only when the printed score leaves the printed range; a score that reads as
    /// the edge of the range is inside it.
    func testComparisonIsJudgedOnThePrintedNumbersAgainstTheRange() {
        XCTAssertEqual(SimpleScoreRules.comparison(printed: "53", lowPrinted: "37", highPrinted: "52"), .higher)
        XCTAssertEqual(SimpleScoreRules.comparison(printed: "36", lowPrinted: "37", highPrinted: "52"), .lower)
        XCTAssertEqual(SimpleScoreRules.comparison(printed: "49", lowPrinted: "37", highPrinted: "52"), .within)
        XCTAssertEqual(SimpleScoreRules.comparison(printed: "52", lowPrinted: "37", highPrinted: "52"), .within)
        XCTAssertEqual(SimpleScoreRules.comparison(printed: "37", lowPrinted: "37", highPrinted: "52"), .within)
        XCTAssertEqual(SimpleScoreRules.comparison(printed: "12.7", lowPrinted: "9.4", highPrinted: "12.6"), .higher)
        XCTAssertNil(SimpleScoreRules.comparison(printed: "–", lowPrinted: "37", highPrinted: "52"))
        // 52.4 against a range ending at 51.6: both print 52, so the score is in the range, not above it.
        let (score, top) = (SimpleScoreFormat.text(.charge, stored: 52.4, scale: .hundred),
                            SimpleScoreFormat.text(.charge, stored: 51.6, scale: .hundred))
        XCTAssertEqual(SimpleScoreRules.comparison(printed: score, lowPrinted: "37", highPrinted: top), .within)
        XCTAssertEqual(SimpleScoreFormat.rangeText(low: "37", high: "52"), "37–52")
        XCTAssertEqual(SimpleScoreFormat.rangeText(low: "44", high: "44"), "44")
    }

    func testDayKeyArithmeticCrossesMonthsAndYears() {
        XCTAssertEqual(SimpleScoreRules.dayKey("2026-03-01", addingDays: -1), "2026-02-28")
        XCTAssertEqual(SimpleScoreRules.dayKey("2028-03-01", addingDays: -1), "2028-02-29")
        XCTAssertEqual(SimpleScoreRules.dayKey("2026-01-01", addingDays: -1), "2025-12-31")
        XCTAssertEqual(SimpleScoreRules.dayKey("2026-11-16", addingDays: 0), "2026-11-16")
        XCTAssertEqual(SimpleScoreRules.dayKey("2026-10-25", addingDays: 1), "2026-10-26")
        XCTAssertNil(SimpleScoreRules.dayKey("2026-11", addingDays: 1))
        XCTAssertEqual(SimpleScoreRules.dayKeys(endingOn: "2026-11-02"),
                       ["2026-10-27", "2026-10-28", "2026-10-29", "2026-10-30", "2026-10-31", "2026-11-01", "2026-11-02"])
    }

    /// Seven calendar days ending on the selected day; a day without a score keeps its slot with no value;
    /// the shown score's own day carries the number in the page's header.
    func testWeekBarsEndOnTheSelectedDayAndCarryTheShownValue() {
        let series = scorePageFixtureSeries([(10, 61), (12, 48), (15, 70), (16, 20)])
        let today = SimpleScoreRules.weekBars(series: series, endingOn: "2026-11-16",
                                              shownDayKey: "2026-11-16", shownValue: 23.4)
        XCTAssertEqual(today.map(\.dayKey), SimpleScoreRules.dayKeys(endingOn: "2026-11-16"))
        XCTAssertEqual(today.map(\.value), [61, nil, 48, nil, nil, 70, 23.4])
        // A carried score: the selected day has none, the earlier day shows the ring's value.
        let carried = SimpleScoreRules.weekBars(series: scorePageFixtureSeries([(10, 61), (15, 70)]),
                                                endingOn: "2026-11-16", shownDayKey: "2026-11-15", shownValue: 70)
        XCTAssertEqual(carried.last?.value, nil)
        XCTAssertEqual(carried.dropLast().last, .init(dayKey: "2026-11-15", value: 70))
        // No shown value: the day falls back to its stored one.
        let stored = SimpleScoreRules.weekBars(series: series, endingOn: "2026-11-16",
                                               shownDayKey: "2026-11-16", shownValue: nil)
        XCTAssertEqual(stored.last?.value, 20)
    }

    // MARK: - One night, one page

    /// The Charge rows are about one night: the row's own Rest, and none when that night has none, never
    /// the Rest of another night that happens to be on the ring.
    func testChargeRowsUseTheRowsOwnNightOfRest() {
        let rest = ["2026-11-14": 71.0, "2026-11-16": 88.0]
        XCTAssertEqual(SimpleScoreRules.chargeRowRest(rowDayKey: "2026-11-16", restByDay: rest), 88)
        XCTAssertEqual(SimpleScoreRules.chargeRowRest(rowDayKey: "2026-11-14", restByDay: rest), 71)
        XCTAssertNil(SimpleScoreRules.chargeRowRest(rowDayKey: "2026-11-15", restByDay: rest))
    }

    /// A snapshot knows when its score is an earlier day's, and hands over the suggested range only whole.
    func testSnapshotKnowsACarriedScoreAndItsRange() {
        func scorePageFixtureSnapshot(stored: Double?, scoreDay: String, low: Int?, high: Int?) -> SimpleScoreSnapshot {
            SimpleScoreSnapshot(kind: .effort, selectedDayKey: "2026-11-16", isToday: true, stored: stored,
                                scoreDayKey: scoreDay, calibratingNights: nil, drivers: [],
                                bandLow: low, bandHigh: high, workouts: [])
        }
        XCTAssertFalse(scorePageFixtureSnapshot(stored: 40, scoreDay: "2026-11-16", low: 10, high: 14).isCarried)
        XCTAssertTrue(scorePageFixtureSnapshot(stored: 40, scoreDay: "2026-11-15", low: nil, high: nil).isCarried)
        // A dash is not a carried score, whatever day it names.
        XCTAssertFalse(scorePageFixtureSnapshot(stored: nil, scoreDay: "2026-11-15", low: nil, high: nil).isCarried)
        XCTAssertEqual(scorePageFixtureSnapshot(stored: 40, scoreDay: "2026-11-16", low: 10, high: 14).band21, 10...14)
        XCTAssertNil(scorePageFixtureSnapshot(stored: 40, scoreDay: "2026-11-16", low: 10, high: nil).band21)
        XCTAssertNil(scorePageFixtureSnapshot(stored: 40, scoreDay: "2026-11-16", low: 14, high: 10).band21)
    }

    /// The page's last link opens the statistics page the ring opens in the full view, so its key must be
    /// the ring's own and must resolve in the catalogue.
    func testEachScorePageLinksToItsRingsStatisticsPage() {
        XCTAssertEqual(SimpleScoreKind.allCases.map(\.metricKey), HeroRingMetric.all)
        for kind in SimpleScoreKind.allCases {
            XCTAssertEqual(MetricCatalog.all.filter { $0.key == kind.metricKey }.count, 1,
                           "\(kind) has no single statistics page")
        }
    }

    /// A score is printed the way its ring prints it, on the scale the reader chose.
    func testScoresArePrintedTheRingsWay() {
        XCTAssertEqual(SimpleScoreFormat.text(.charge, stored: 50.6, scale: .hundred), "51")
        XCTAssertEqual(SimpleScoreFormat.text(.rest, stored: 86.49, scale: .whoop), "86")
        XCTAssertEqual(SimpleScoreFormat.text(.effort, stored: 66.6, scale: .hundred), "67")
        XCTAssertEqual(SimpleScoreFormat.text(.effort, stored: 60, scale: .whoop),
                       SimpleDayPlan.effortText(stored: 60, scale: .whoop))
        XCTAssertEqual(SimpleScoreFormat.scaleTop(.effort, scale: .whoop), 21)
        XCTAssertEqual(SimpleScoreFormat.scaleTop(.effort, scale: .hundred), 100)
        XCTAssertEqual(SimpleScoreFormat.scaleTop(.charge, scale: .whoop), 100)
        XCTAssertEqual(SimpleScoreFormat.shown(.effort, stored: 100, scale: .whoop), 21, accuracy: 0.0001)
        XCTAssertEqual(SimpleScoreFormat.shown(.rest, stored: 86, scale: .whoop), 86)
        XCTAssertEqual(SimpleScoreFormat.workoutSub(.init(startTs: 0, sport: "walking", minutes: 29, kcal: 256, strain: 40)),
                       "29 min · 256 kcal")
        XCTAssertEqual(SimpleScoreFormat.workoutSub(.init(startTs: 0, sport: "walking", minutes: 29, kcal: nil, strain: nil)),
                       "29 min")
    }
}
