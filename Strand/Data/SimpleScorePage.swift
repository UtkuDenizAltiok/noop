import Foundation
import StrandAnalytics
import WhoopStore

// MARK: - Simple mode: the score pages ("tap a score, get an answer")
//
// In Simple mode a score ring opens a plain page about that one score: the number and its word, how it
// compares with the wearer's own usual, what moved it, and what to do. The statistics page the ring opens
// in the full view stays one tap further, as the page's last link.
//
// Presentation only. The page never resolves a score itself: Today hands it a snapshot of exactly what the
// ring and the cards under it showed when the ring was tapped, so a page can never state a different number
// than the ring it was opened from (AGENTS.md: two readouts of one fact must not be able to disagree). What
// the page works out itself is only what Today does not show: the wearer's usual value, the last seven
// days, and the parts of the Rest score. The rules for those live here, pure, so they can be tested.

/// One of the three scores a Simple-mode page explains.
enum SimpleScoreKind: String, Hashable, CaseIterable {
    case charge, effort, rest

    /// The catalogue key of the score's statistics page (`MetricDetailView`), the same key the ring routes
    /// to in the full view.
    var metricKey: String {
        switch self {
        case .charge: return HeroRingMetric.charge
        case .effort: return HeroRingMetric.effort
        case .rest: return HeroRingMetric.rest
        }
    }
}

/// What Today showed for one score when its ring was tapped. Carried by the route, so the page it opens
/// prints the ring's own value, the day that value belongs to, and the same rows Today's cards listed.
struct SimpleScoreSnapshot: Hashable {

    /// One "What's behind your Charge" row as Today worded it (`PlainChargeWording`).
    struct DriverLine: Hashable {
        let label: String
        let deltaPoints: Int
        let valueText: String
        let baselineText: String
        let verdict: String
    }

    /// One workout of the selected day, as Today's workouts card listed it.
    struct WorkoutLine: Hashable {
        let startTs: Int
        let sport: String
        let minutes: Int
        let kcal: Int?
        /// The workout's own Effort, stored 0–100; nil when it carries none.
        let strain: Double?
    }

    let kind: SimpleScoreKind
    /// The day Today had selected.
    let selectedDayKey: String
    /// Whether that day is today.
    let isToday: Bool
    /// The score as stored (0–100), or nil when the ring showed a dash.
    let stored: Double?
    /// The day the shown score belongs to: the selected day, or the earlier day a carried score comes from.
    let scoreDayKey: String
    /// Charge only: the nights learned so far while the baseline is still calibrating; nil otherwise.
    let calibratingNights: Int?
    /// Charge only: every reading behind the score, in Today's wording and order.
    let drivers: [DriverLine]
    /// Effort only: the suggested range on the 0–21 axis that "Your day" showed, or nil when it showed none.
    let bandLow: Int?
    let bandHigh: Int?
    /// Effort only: the selected day's workouts, newest first.
    let workouts: [WorkoutLine]

    /// Whether the shown score is an earlier day's, carried onto the selected day.
    var isCarried: Bool { stored != nil && scoreDayKey != selectedDayKey }

    /// The suggested Effort range on the 0–21 axis, when "Your day" showed one.
    var band21: ClosedRange<Int>? {
        guard let bandLow, let bandHigh, bandLow <= bandHigh else { return nil }
        return bandLow...bandHigh
    }
}

/// Pure rules for the Simple-mode score pages.
enum SimpleScoreRules {

    // MARK: Compared with you

    /// How many days the "Compared with you" bars show.
    static let weekDays = 7
    /// How far back a "usual" value looks, and how many scored days it needs.
    static let usualWindowDays = 30
    static let usualMinDays = 7

    /// A day key ("2026-11-16") moved by whole days, or nil for a key that is not a date. Day keys are the
    /// Gregorian calendar dates `Repository.localDayKey` writes, so the arithmetic is on the date alone.
    static func dayKey(_ key: String, addingDays delta: Int) -> String? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        guard let date = calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])),
              let moved = calendar.date(byAdding: .day, value: delta, to: date) else { return nil }
        let out = calendar.dateComponents([.year, .month, .day], from: moved)
        guard let y = out.year, let m = out.month, let d = out.day else { return nil }
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    /// The calendar days ending on `dayKey`, oldest first: the slots of the "Compared with you" bars.
    static func dayKeys(endingOn dayKey: String, count: Int = weekDays) -> [String] {
        (0..<max(0, count)).reversed().compactMap { Self.dayKey(dayKey, addingDays: -$0) }
    }

    /// Where a score usually sits for this wearer: the middle half of their recent days.
    struct UsualRange: Equatable {
        /// The value a quarter of the days fall below.
        let low: Double
        /// The middle value (the median).
        let middle: Double
        /// The value a quarter of the days rise above.
        let high: Double
    }

    /// The wearer's usual range of a score: the quartiles of the scored days in the `usualWindowDays` before
    /// `dayKey`, or nil with fewer than `usualMinDays` of them. The day itself is left out, so a score is
    /// compared with the days before it. The middle half rather than one middle value, because a score a few
    /// points from the median is an ordinary day, not a change: the page calls a score higher or lower only
    /// when it leaves the range half of the wearer's own days fall in. Zero is a real score and counts (a
    /// day of no Effort is a day), unlike a step count of zero.
    static func usualRange(series: [(day: String, value: Double)], before dayKey: String) -> UsualRange? {
        guard let from = Self.dayKey(dayKey, addingDays: -usualWindowDays) else { return nil }
        let values = series.filter { $0.day >= from && $0.day < dayKey && $0.value.isFinite }
            .map(\.value).sorted()
        guard values.count >= usualMinDays else { return nil }
        return UsualRange(low: quantile(values, 0.25), middle: quantile(values, 0.5), high: quantile(values, 0.75))
    }

    /// The `q` quantile of sorted values by linear interpolation between the two nearest (the rule
    /// `Rest.personalizedNeedHours` uses for its upper quartile).
    static func quantile(_ sorted: [Double], _ q: Double) -> Double {
        guard let last = sorted.last else { return .nan }
        let position = max(0, min(1, q)) * Double(sorted.count - 1)
        let lower = Int(position)
        guard lower + 1 < sorted.count else { return last }
        return sorted[lower] + (position - Double(lower)) * (sorted[lower + 1] - sorted[lower])
    }

    /// How a score stands against the usual range.
    enum Comparison: Equatable {
        case higher, lower, within
    }

    /// The comparison, judged on the numbers as they are printed, so the sentence can never say "higher"
    /// beside a figure that reads as the top of the range. Nil when a text is not a number.
    static func comparison(printed: String, lowPrinted: String, highPrinted: String) -> Comparison? {
        guard let value = Double(printed), let low = Double(lowPrinted), let high = Double(highPrinted) else {
            return nil
        }
        if value > high { return .higher }
        if value < low { return .lower }
        return .within
    }

    /// One bar of the "Compared with you" row: a calendar day and that day's score, nil when it has none.
    struct DayBar: Equatable {
        let dayKey: String
        let value: Double?
    }

    /// The bars for the days ending on the selected day. The shown score's own day takes the snapshot's
    /// value rather than the stored series', so its bar is the number in the page's header (today's Effort
    /// is scored live and can be ahead of the stored row).
    static func weekBars(series: [(day: String, value: Double)], endingOn selectedDayKey: String,
                         shownDayKey: String, shownValue: Double?) -> [DayBar] {
        let byDay = Dictionary(series.filter { $0.value.isFinite }.map { ($0.day, $0.value) },
                               uniquingKeysWith: { _, last in last })
        return dayKeys(endingOn: selectedDayKey).map { key in
            DayBar(dayKey: key, value: key == shownDayKey ? (shownValue ?? byDay[key]) : byDay[key])
        }
    }

    // MARK: The parts of the Rest score

    /// One of the four parts the Rest score is built from.
    enum RestPartKind: Equatable, CaseIterable {
        /// Hours asleep against the hours the score counts as a full night.
        case duration
        /// The share of the time in bed spent asleep.
        case efficiency
        /// Deep and REM sleep as a share of the sleep.
        case restorative
        /// Regular bed and wake times: the last week's Sleep Regularity Index (`SleepRegularity`), neutral until
        /// there is one.
        case regularity
    }

    /// One part with its points as printed.
    struct RestPart: Equatable {
        let kind: RestPartKind
        let points: Int
        let maxPoints: Int
    }

    /// The Rest score shown for a night, taken apart: the four parts with whole-number points that add up to
    /// the score as the ring prints it, and the night's own figures behind them.
    ///
    /// It follows `AnalyticsEngine.Rest.composite(daily:)`, the function every screen's Rest score comes
    /// from, with that function's own inputs: a full night is the one sleep need the Sleep tab states
    /// (`SleepNeed`, v6 step 7), and the regularity part is the last week's Sleep Regularity Index
    /// (`SleepRegularity`), or the neutral half (`neutralConsistency`) until about five nights in a row exist.
    /// The page says which; a test pins that the parts always add up to that function's score.
    struct RestBreakdown: Equatable {
        let parts: [RestPart]
        /// The score the parts add up to, as the ring prints it.
        let printedScore: Int
        let asleepMin: Double
        /// The hours the score counts as a full night, in minutes.
        let fullNightMin: Double
        /// Time asleep while in bed, 0–100.
        let efficiencyPct: Double
        /// Deep + REM minutes, and their share of the sleep, 0–100.
        let restorativeMin: Double
        let restorativeSharePct: Double
        /// The share of sleep in deep or REM that earns the whole restorative part, 0–100.
        let restorativeTargetPct: Double
        /// Whether short deep sleep scaled the restorative part down.
        let deepWasShort: Bool
        /// The highest score a night can reach: 100, or less while regularity is not measured.
        let highestPossible: Int
        /// The Sleep Regularity Index the regularity part comes from, rounded, or nil while it is not measured.
        let regularityIndex: Int?
    }

    /// The breakdown of a day row's Rest score, or nil when the row has no sleep to score (the same rows
    /// `Rest.composite(daily:)` returns nil for).
    static func restBreakdown(daily d: DailyMetric, needHours: Double = SleepNeed.currentHours(),
                              regularityIndex: Double? = SleepRegularity.index) -> RestBreakdown? {
        typealias Rest = AnalyticsEngine.Rest
        let consistency = SleepRegularityIndex.consistency(regularityIndex)
        guard let tstMin = d.totalSleepMin, tstMin > 0, let eff = d.efficiency,
              let score = Rest.composite(daily: d, needHours: needHours, consistency: consistency) else { return nil }
        func clamp01(_ x: Double) -> Double { max(0.0, min(1.0, x)) }
        let needMin = max(needHours, 0.1) * 60.0
        let deepMin = d.deepMin ?? 0
        let restorativeMin = deepMin + (d.remMin ?? 0)
        let deepFactor = Rest.deepShareTarget > 0
            ? Rest.deepFloorFactor + (1.0 - Rest.deepFloorFactor) * clamp01((deepMin / tstMin) / Rest.deepShareTarget)
            : 1.0
        let exact: [(RestPartKind, Double, Double)] = [
            (.duration, Rest.wDuration * clamp01(tstMin / needMin), Rest.wDuration),
            (.efficiency, Rest.wEfficiency * clamp01(eff), Rest.wEfficiency),
            (.restorative, Rest.wRestorative * clamp01((restorativeMin / tstMin) / Rest.restorativeTarget) * deepFactor,
             Rest.wRestorative),
            (.regularity, Rest.wConsistency * clamp01(consistency ?? Rest.neutralConsistency), Rest.wConsistency),
        ]
        let printedScore = Int(score.rounded())
        let points = wholePoints(exact.map { $0.1 * 100.0 }, total: printedScore)
        let parts = zip(exact, points).map { part, whole in
            RestPart(kind: part.0, points: whole, maxPoints: Int((part.2 * 100.0).rounded()))
        }
        let neutralPoints = Rest.wConsistency * clamp01(Rest.neutralConsistency) * 100.0
        return RestBreakdown(
            parts: parts, printedScore: printedScore, asleepMin: tstMin, fullNightMin: needMin,
            efficiencyPct: (eff <= 1.0 ? eff * 100.0 : eff),
            restorativeMin: restorativeMin, restorativeSharePct: restorativeMin / tstMin * 100.0,
            restorativeTargetPct: Rest.restorativeTarget * 100.0,
            deepWasShort: d.deepMin != nil && deepFactor < 1.0,
            highestPossible: consistency == nil ? Int((100.0 - Rest.wConsistency * 100.0 + neutralPoints).rounded()) : 100,
            regularityIndex: regularityIndex.map { Int($0.rounded()) })
    }

    /// Whole-number points for `exact` that add up to `total`: each part rounded down, then the points still
    /// missing given to the parts that lost most by rounding down (the largest-remainder rule), so a list of
    /// parts never adds up to a different number than the score printed above it.
    static func wholePoints(_ exact: [Double], total: Int) -> [Int] {
        var whole = exact.map { Int(max(0, $0).rounded(.down)) }
        var missing = total - whole.reduce(0, +)
        let byRemainder = exact.enumerated().sorted { a, b in
            let (ra, rb) = (a.element - a.element.rounded(.down), b.element - b.element.rounded(.down))
            return ra != rb ? ra > rb : a.offset < b.offset
        }.map(\.offset)
        var turn = 0
        while missing > 0, !byRemainder.isEmpty {
            whole[byRemainder[turn % byRemainder.count]] += 1
            missing -= 1
            turn += 1
        }
        // A total below the rounded-down parts cannot come from the score function; never print a negative.
        while missing < 0, let index = whole.indices.last(where: { whole[$0] > 0 }) {
            whole[index] -= 1
            missing += 1
        }
        return whole
    }

    /// Why a Rest page cannot show the score's parts, when it cannot.
    enum RestPartsGap: Equatable {
        /// The score shown is WHOOP's own imported figure for the night, not NOOP's calculation.
        case importedScore
        /// The score shown does not come from the night's stored totals (another source, or no totals).
        case notFromTheseTotals
    }

    /// The parts of the shown Rest score, or the reason they cannot be shown. The parts are listed only
    /// when they are the shown number's own: not for a score WHOOP provided, and not when the night's totals
    /// score differently from the number on the ring.
    static func restParts(shownScore: Double, daily: DailyMetric?,
                          importedScore: Double?) -> Result<RestBreakdown, RestPartsGap> {
        if importedScore != nil { return .failure(.importedScore) }
        guard let daily, let breakdown = restBreakdown(daily: daily),
              breakdown.printedScore == Int(shownScore.rounded()) else { return .failure(.notFromTheseTotals) }
        return .success(breakdown)
    }

    // MARK: One night for the Charge rows

    /// The Rest score to hand the Charge breakdown for the row it describes: that row's own night, and
    /// nothing when that night has none (the breakdown then scores the row without a Rest term, as the
    /// engine did). Never the Rest now on the ring when it belongs to another night, which is what a
    /// carried Charge or a carried Rest would otherwise mix into one list of readings.
    static func chargeRowRest(rowDayKey: String, restByDay: [String: Double]) -> Double? {
        restByDay[rowDayKey]
    }
}

extension SimpleScoreRules.RestPartsGap: Error {}
