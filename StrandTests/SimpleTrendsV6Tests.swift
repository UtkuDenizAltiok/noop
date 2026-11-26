import XCTest
import StrandAnalytics
import WhoopStore
@testable import Strand

/// Pins the rules behind Design v6's step 5, "Am I improving?": a Trends chart calls a change only when it is
/// bigger than the wearer's own day-to-day ups and downs (and short or self-similar windows need more), the
/// week card follows the engine's own movers and never calls training "too hard" that every morning's
/// suggested range allowed, and the Workouts summary judges each workout against the very heart rates it
/// prints, counts strength days, and keeps its two seven-day windows apart.
final class SimpleTrendsV6Tests: XCTestCase {

    // MARK: Fixtures (named unlike any production function: the parity ledger pairs calls by name)

    /// Alternating values around a mean: no day-to-day correlation, a known spread.
    private func trendsV6Alternating(mean: Double, swing: Double, count: Int) -> [Double] {
        (0..<count).map { mean + ($0 % 2 == 0 ? -swing : swing) }
    }

    private func trendsV6Row(_ start: Date, seconds: Double, avgHr: Int?, sport: String = "Running",
                             source: String = "manual") -> WorkoutRow {
        let ts = Int(start.timeIntervalSince1970)
        return WorkoutRow(startTs: ts, endTs: ts + Int(seconds), sport: sport, source: source,
                          durationS: seconds, energyKcal: nil, avgHr: avgHr, maxHr: nil, strain: nil,
                          distanceM: nil, zonesJSON: nil, notes: nil, steps: nil)
    }

    private func trendsV6Calendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return calendar
    }

    private func trendsV6Date(_ calendar: Calendar, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    /// A deterministic pseudo-random sequence (LCG), so the oracle walk is the same on every run.
    private struct TrendsV6Random {
        var state: UInt64
        mutating func next() -> Double {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Double(state >> 11) / Double(UInt64(1) << 53)
        }
        mutating func int(_ range: ClosedRange<Int>) -> Int {
            range.lowerBound + Int(next() * Double(range.count)) % range.count
        }
    }

    // MARK: - A chart's verdict

    /// Three days cannot be split in two halves; four can (the full view's chip needs the same four).
    func testVerdictNeedsFourDays() {
        XCTAssertEqual(SimpleTrendRules.verdict(values: [50, 60, 70], decimals: 0), .tooFew)
        XCTAssertEqual(SimpleTrendRules.verdict(values: [50, 50, 70, 70], decimals: 0), .up(amount: 20))
    }

    /// In a long window the bar is half the wearer's own spread: with days swinging ±10 around their average,
    /// a 4-point shift is ordinary and a 6-point one is a change (Buchheit 2014's smallest worthwhile change).
    func testLongWindowNeedsHalfTheOwnSpread() {
        let earlier = trendsV6Alternating(mean: 50, swing: 10, count: 44)
        XCTAssertEqual(SimpleTrendRules.verdict(values: earlier + trendsV6Alternating(mean: 54, swing: 10, count: 44),
                                                decimals: 0), .aboutTheSame)
        XCTAssertEqual(SimpleTrendRules.verdict(values: earlier + trendsV6Alternating(mean: 56, swing: 10, count: 44),
                                                decimals: 0), .up(amount: 6))
        XCTAssertEqual(SimpleTrendRules.verdict(values: earlier + trendsV6Alternating(mean: 44, swing: 10, count: 44),
                                                decimals: 0), .down(amount: 6))
    }

    /// A short window has to move further: eight days swinging ±10 leave a 14-point shift inside the noise of
    /// two four-day averages, while 18 points clears it.
    func testShortWindowNeedsToClearTheNoise() {
        let earlier = trendsV6Alternating(mean: 50, swing: 10, count: 4)
        XCTAssertEqual(SimpleTrendRules.verdict(values: earlier + trendsV6Alternating(mean: 64, swing: 10, count: 4),
                                                decimals: 0), .aboutTheSame)
        XCTAssertEqual(SimpleTrendRules.verdict(values: earlier + trendsV6Alternating(mean: 68, swing: 10, count: 4),
                                                decimals: 0), .up(amount: 18))
    }

    /// Neighbouring days that resemble each other count as fewer days: the same values in a slow wave (each
    /// day like the one before) leave a 6-point shift unproven, while the same values shuffled call it.
    func testSelfSimilarDaysNeedMore() {
        let wave = (0..<15).map { 50 + 10 * sin(2 * Double.pi * Double($0) / 15) }
        XCTAssertEqual(SimpleTrendRules.verdict(values: wave + wave.map { $0 + 6 }, decimals: 0), .aboutTheSame)
        // The same fifteen values, ordered high, low, high, low: no day resembles the one before.
        let sorted = wave.sorted()
        var shuffled: [Double] = []
        for i in 0..<8 {
            shuffled.append(sorted[sorted.count - 1 - i])
            if i < 7 { shuffled.append(sorted[i]) }
        }
        XCTAssertEqual(SimpleTrendRules.verdict(values: shuffled + shuffled.map { $0 + 6 }, decimals: 0), .up(amount: 6))
    }

    /// A change is named as printed: 0.4 rounds to nothing on a whole-number chart and stays on a one-decimal one.
    func testVerdictRoundsAsPrinted() {
        let values: [Double] = [50, 50, 50, 50, 50.4, 50.4, 50.4, 50.4]
        XCTAssertEqual(SimpleTrendRules.verdict(values: values, decimals: 0), .aboutTheSame)
        XCTAssertEqual(SimpleTrendRules.verdict(values: values, decimals: 1), .up(amount: 0.4))
    }

    /// Every range Trends offers is one the window names spell out (six months and a year by name, not as a
    /// count of days), so a range added to Trends without a name fails here.
    func testEveryTrendsRangeHasAName() {
        XCTAssertEqual(Set(TrendsView.Range.allCases.map(\.days)), [7, 30, 90, 180, 365, nil])
        XCTAssertEqual(SimpleTrendRules.windowName(days: 180), String(localized: "Last 6 months"))
        XCTAssertEqual(SimpleTrendRules.windowName(days: 365), String(localized: "Last 12 months"))
        XCTAssertEqual(SimpleTrendRules.windowName(days: nil), String(localized: "All your history"))
        XCTAssertEqual(SimpleTrendRules.windowPhrase(days: 180), String(localized: "in the last 6 months"))
    }

    // MARK: - The week in words

    /// The week's movers are the engine's own: over a spread of weeks, the first sentence the full view writes
    /// names the same metric, the same way, as Simple mode's first mover, and a week whose first sentence is not
    /// about a mover has none. The sparse and steady reasons match too, except that a week with no last week is
    /// said to have nothing to compare with (the engine calls it "a steady week").
    func testWeekFollowsTheEnginesMovers() {
        var random = TrendsV6Random(state: 20261126)
        let thisWeek = (23...29).map { String(format: "2026-11-%02d", $0) }
        let lastWeek = (16...22).map { String(format: "2026-11-%02d", $0) }
        var moversSeen = 0, steadySeen = 0
        for trial in 0..<800 {
            var data: [WeeklyMetric: [String: Double]] = [:]
            let thisDays = random.int(0...7), lastDays = random.int(0...7)
            // Half the weeks move by under 0.8 typical spreads, so many land near the 0.5 bar the test pins.
            let reach = trial % 2 == 0 ? 0.8 : 2.0
            for metric in WeeklyMetric.allCases {
                let base = metric == .rhr ? 55.0 : (metric == .hrv ? 60.0 : 55.0)
                let shift = (random.next() * 2 - 1) * reach * metric.typicalSpread
                var series: [String: Double] = [:]
                for day in thisWeek.prefix(thisDays) { series[day] = base + shift + (random.next() - 0.5) * 8 }
                for day in lastWeek.prefix(lastDays) { series[day] = base + (random.next() - 0.5) * 8 }
                data[metric] = series
            }
            let digest = WeeklyDigestEngine.build(byMetric: data, anchorDay: "2026-11-29")
            guard !digest.isEmpty, let first = digest.focalPoints.first else { continue }
            let movers = SimpleWeekRules.movers(digest)
            if let metric = WeeklyMetric.allCases.first(where: { first.hasPrefix("\($0.label) is ") }) {
                moversSeen += 1
                XCTAssertEqual(movers.first?.metric, metric, first)
                XCTAssertEqual(movers.first.map { $0.wowDelta > 0 }, first.contains(" is up "), first)
                // With no balance line, the engine's second sentence is its second mover, if it has one.
                if digest.balance != .overreaching && digest.balance != .underloaded {
                    let second = digest.focalPoints.dropFirst().first
                    let secondMetric = second.flatMap { line in
                        WeeklyMetric.allCases.first(where: { line.hasPrefix("\($0.label) is ") })
                    }
                    XCTAssertEqual(movers.count >= 2 ? movers[1].metric : nil, secondMetric, second ?? "none")
                }
                continue
            }
            XCTAssertTrue(movers.isEmpty, first)
            // The engine's balance line stands first when nothing moved; Simple mode does not use it.
            guard first != digest.balance.sentence else { continue }
            steadySeen += 1
            let previous = digest.metrics.map(\.weekOverWeek.previous.n).max() ?? 0
            let current = digest.metrics.map(\.weekOverWeek.current.n).max() ?? 0
            let line = SimpleWeekRules.lines(digest, adherence: nil, scale: .hundred).first
            if first.hasPrefix("Only ") {
                XCTAssertEqual(line, .earlyInWeek(days: current), first)
            } else if first.hasPrefix("Last week only had") {
                XCTAssertEqual(line, .thinLastWeek(days: previous), first)
            } else if first.hasPrefix("A steady week: Rest held even") {
                XCTAssertEqual(line, previous == 0 ? .noLastWeek : .steadyEvenRest, first)
            } else if first.hasPrefix("A steady week") {
                XCTAssertEqual(line, previous == 0 ? .noLastWeek : .steady, first)
            } else {
                XCTFail("an engine sentence this test does not know: \(first)")
            }
        }
        // The walk must have reached both kinds of week, or it pinned nothing.
        XCTAssertGreaterThan(moversSeen, 50)
        XCTAssertGreaterThan(steadySeen, 50)
    }

    /// The comparison with last week is judged on the two printed averages, coloured only when the engine also
    /// counts it as a mover, never coloured for Effort, and a thin week says so instead of giving a number.
    func testWeekChipsInWords() {
        func summary(_ metric: WeeklyMetric, now: [Double], before: [Double]) -> WeeklyMetricSummary {
            WeeklyMetricSummary(metric: metric, thisWeek: ComparisonEngine.stat(now),
                                weekOverWeek: ComparisonEngine.compare(current: now, previous: before),
                                baselineMean: nil, vsBaseline: nil)
        }
        // Charge 62 against 58: a 4-point move is under half of its typical 12-point spread, so plain.
        XCTAssertEqual(SimpleWeekRules.chip(summary(.charge, now: [62, 62, 62], before: [58, 58, 58]), scale: .hundred),
                       .higher(amount: 4, tone: .plain))
        // 66 against 58 is a mover, and good for Charge.
        XCTAssertEqual(SimpleWeekRules.chip(summary(.charge, now: [66, 66, 66], before: [58, 58, 58]), scale: .hundred),
                       .higher(amount: 8, tone: .good))
        // A resting heart rate 3 bpm lower is a mover (typical spread 4), and lower is good.
        XCTAssertEqual(SimpleWeekRules.chip(summary(.rhr, now: [52, 52, 52], before: [55, 55, 55]), scale: .hundred),
                       .lower(amount: 3, tone: .good))
        // Effort never takes a colour, however far it moves.
        XCTAssertEqual(SimpleWeekRules.chip(summary(.effort, now: [80, 80, 80], before: [40, 40, 40]), scale: .hundred),
                       .higher(amount: 40, tone: .plain))
        // Averages that print alike are the same, whatever the decimals behind them.
        XCTAssertEqual(SimpleWeekRules.chip(summary(.charge, now: [62.4, 62.4, 62.4], before: [61.6, 61.6, 61.6]),
                                            scale: .hundred), .same)
        // Two days this week: too few to compare. No last week: nothing drawn.
        XCTAssertEqual(SimpleWeekRules.chip(summary(.charge, now: [70, 70], before: [50, 50, 50]), scale: .hundred),
                       .tooFewDays)
        XCTAssertEqual(SimpleWeekRules.chip(summary(.charge, now: [70, 70, 70], before: []), scale: .hundred), .none)
    }

    /// The F23 case: a week of medium Charge (50) and Effort 65 is inside the range Today suggests every day
    /// (48–67 on the 0–100 scale), so Simple mode says so, although the engine's average-against-average
    /// balance calls the same week "leaning into the red".
    func testTrainingIsJudgedAgainstEachDaysRange() {
        let week = (23...28).map { String(format: "2026-11-%02d", $0) }
        var charge: [String: Double] = [:], effort: [String: Double] = [:]
        for day in week { charge[day] = 50; effort[day] = 65 }
        let digest = WeeklyDigestEngine.build(byMetric: [.charge: charge, .effort: effort], anchorDay: "2026-11-29")
        XCTAssertEqual(digest.balance, .overreaching)

        let days = week.map { DailyMetric(day: $0, totalSleepMin: nil, efficiency: nil, deepMin: nil, remMin: nil,
                                          lightMin: nil, disturbances: nil, restingHr: nil, avgHrv: nil,
                                          recovery: 50, strain: 65, exerciseCount: nil) }
        let loads = SimpleWeekRules.dayLoads(days: days, weekStart: digest.weekStart, weekEnd: digest.weekEnd,
                                             today: "2026-11-29")
        XCTAssertEqual(SimpleWeekRules.adherence(loads, scale: .hundred), .allInside(days: 6))
        XCTAssertEqual(SimpleWeekRules.adherence(loads, scale: .whoop), .allInside(days: 6))
        XCTAssertEqual(SimpleWeekRules.lines(digest, adherence: .allInside(days: 6), scale: .hundred).last,
                       .adherence(.allInside(days: 6)))
    }

    /// Today's unfinished Effort is left out; above wins a tie with below; fewer than three days say nothing.
    func testAdherenceCountsFinishedDays() {
        let rows = [("2026-11-23", 80.0, 95.0), ("2026-11-24", 80.0, 40.0), ("2026-11-25", 80.0, 75.0),
                    ("2026-11-26", 20.0, 5.0)].map {
            DailyMetric(day: $0.0, totalSleepMin: nil, efficiency: nil, deepMin: nil, remMin: nil, lightMin: nil,
                        disturbances: nil, restingHr: nil, avgHrv: nil, recovery: $0.1, strain: $0.2,
                        exerciseCount: nil)
        }
        let loads = SimpleWeekRules.dayLoads(days: rows, weekStart: "2026-11-23", weekEnd: "2026-11-29",
                                             today: "2026-11-26")
        XCTAssertEqual(loads.map(\.day), ["2026-11-23", "2026-11-24", "2026-11-25"])
        // Charge 80 suggests 67–86: 95 is above, 40 below, 75 inside. One each way: above is said.
        XCTAssertEqual(SimpleWeekRules.adherence(loads, scale: .hundred), .above(days: 1, of: 3))
        XCTAssertNil(SimpleWeekRules.adherence(Array(loads.prefix(2)), scale: .hundred))
        XCTAssertEqual(SimpleWeekRules.adherence([loads[1], loads[1], loads[2]], scale: .hundred),
                       .below(days: 2, of: 3))
    }

    // MARK: - Workouts against the guidelines

    /// Seven calendar days ending today, against the seven before; minutes judged from the average heart rate,
    /// vigorous counted twice; a workout without heart rate is counted as unjudged; two strength workouts on one
    /// day are one strength day.
    func testWorkoutWeek() {
        let calendar = trendsV6Calendar()
        let now = trendsV6Date(calendar, 26, 15)
        let rows = [
            trendsV6Row(trendsV6Date(calendar, 26, 7), seconds: 3600, avgHr: 150, sport: "CrossFit"),
            trendsV6Row(trendsV6Date(calendar, 24, 18), seconds: 1800, avgHr: 125, sport: "Strength Training"),
            trendsV6Row(trendsV6Date(calendar, 24, 19), seconds: 900, avgHr: 100, sport: "Weightlifting"),
            trendsV6Row(trendsV6Date(calendar, 22, 10), seconds: 2400, avgHr: 110, sport: "Walking"),
            trendsV6Row(trendsV6Date(calendar, 20, 0, 30), seconds: 1200, avgHr: nil),
            trendsV6Row(trendsV6Date(calendar, 19, 23, 30), seconds: 3600, avgHr: 140),
            trendsV6Row(trendsV6Date(calendar, 13, 9), seconds: 3600, avgHr: 140),
            trendsV6Row(trendsV6Date(calendar, 12, 23), seconds: 3600, avgHr: 140),
        ]
        let week = SimpleWorkoutRules.week(rows: rows, now: now, calendar: calendar, maxHR: 190)
        XCTAssertEqual(week.count, 5)
        XCTAssertEqual(week.previousCount, 2)
        XCTAssertEqual(week.totalSeconds, 3600 + 1800 + 900 + 2400 + 1200)
        XCTAssertEqual(week.vigorousMinutes, 60)
        XCTAssertEqual(week.moderateMinutes, 30)
        XCTAssertEqual(week.guidelineMinutes, 150)
        XCTAssertEqual(week.withoutHeartRate, 1)
        XCTAssertEqual(week.strengthDays, 2)

        // Without a maximum heart rate nothing can be judged.
        let unjudged = SimpleWorkoutRules.week(rows: rows, now: now, calendar: calendar, maxHR: nil)
        XCTAssertEqual(unjudged.guidelineMinutes, 0)
        XCTAssertEqual(unjudged.withoutHeartRate, 5)
    }

    /// The card's "last 7 days" is the very window Simple mode's range picker uses: calendar days ending with
    /// today, later today included (the demo seeds a workout this evening), so the card and the list can never
    /// count different workouts, as they did when the list counted back from the newest workout.
    func testCardAndListShareOneWindow() {
        let calendar = trendsV6Calendar()
        let now = trendsV6Date(calendar, 26, 12, 47)
        let rows = [trendsV6Row(trendsV6Date(calendar, 26, 18), seconds: 600, avgHr: nil),
                    trendsV6Row(trendsV6Date(calendar, 20, 7), seconds: 600, avgHr: nil),
                    trendsV6Row(trendsV6Date(calendar, 19, 23, 59), seconds: 600, avgHr: nil),
                    trendsV6Row(trendsV6Date(calendar, 27, 0, 1), seconds: 600, avgHr: nil)]
        guard let window = SimpleWorkoutRules.window(days: 7, now: now, calendar: calendar) else {
            return XCTFail("no window")
        }
        XCTAssertEqual(rows.filter { window.contains($0.startTs) }.count, 2)
        let week = SimpleWorkoutRules.week(rows: rows, now: now, calendar: calendar, maxHR: 190)
        XCTAssertEqual(week.count, 2)
        XCTAssertEqual(week.previousCount, 1)
    }

    /// A workout is judged against the very bpm the card prints: for a maximum of 190, moderate from 122 and
    /// vigorous from 147 (64 % and 77 %, the first whole bpm at or above each), and an exact product stays put.
    func testWorkoutThresholdsMatchWhatIsPrinted() {
        XCTAssertTrue(SimpleWorkoutRules.thresholdBPM(maxHR: 190) == (122, 147))
        XCTAssertTrue(SimpleWorkoutRules.thresholdBPM(maxHR: 200) == (128, 154))
        let calendar = trendsV6Calendar()
        let now = trendsV6Date(calendar, 26, 15)
        func minutes(_ bpm: Int) -> (Double, Double) {
            let w = SimpleWorkoutRules.week(rows: [trendsV6Row(trendsV6Date(calendar, 26, 8), seconds: 600, avgHr: bpm)],
                                            now: now, calendar: calendar, maxHR: 190)
            return (w.moderateMinutes, w.vigorousMinutes)
        }
        XCTAssertTrue(minutes(121) == (0, 0))
        XCTAssertTrue(minutes(122) == (10, 0))
        XCTAssertTrue(minutes(146) == (10, 0))
        XCTAssertTrue(minutes(147) == (0, 10))
    }

    /// Strength is found in the Lift Log's own name, WHOOP's run-together names and lifting imports, and not in
    /// a word that merely contains "weight".
    func testStrengthWorkouts() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        func strength(_ sport: String, source: String = "manual") -> Bool {
            SimpleWorkoutRules.isStrength(trendsV6Row(start, seconds: 60, avgHr: nil, sport: sport, source: source))
        }
        XCTAssertTrue(strength(LiftSessionView.sport))
        XCTAssertTrue(strength("TraditionalStrengthTraining", source: "whoop"))
        XCTAssertTrue(strength("FunctionalFitness", source: "whoop"))
        XCTAssertTrue(strength("CrossFit"))
        XCTAssertTrue(strength("Weightlifting"))
        XCTAssertTrue(strength("Bench day", source: "lifting"))
        for sport in ["Running", "Walking", "Yoga", "Cycling", "detected", "Lightweight run"] {
            XCTAssertFalse(strength(sport), sport)
        }
    }

    /// The minutes the card states are rounded to the nearest five, the guideline is the WHO's 150 and two
    /// strength days, and it is for adults.
    func testGuidelineFigures() {
        XCTAssertEqual(SimpleWorkoutRules.roundedMinutes(147.4), 145)
        XCTAssertEqual(SimpleWorkoutRules.roundedMinutes(147.5), 150)
        XCTAssertEqual(SimpleWorkoutRules.roundedMinutes(0), 0)
        XCTAssertEqual(SimpleWorkoutRules.guidelineMinutes, 150)
        XCTAssertEqual(SimpleWorkoutRules.guidelineStrengthDays, 2)
        XCTAssertEqual(SimpleWorkoutRules.guidelineMinAge, 18)
    }
}
