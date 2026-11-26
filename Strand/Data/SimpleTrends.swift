import Foundation
import StrandAnalytics
import WhoopStore

/// Simple mode's "Am I improving?" (Design v6, step 5): the Trends charts and the week in words, and the
/// Workouts summary measured against the health guidelines.
///
/// Presentation only. Every figure is one the full view already resolves (the Trends windows, the weekly
/// digest, the workout rows, the profile's maximum heart rate); these rules decide what may honestly be said
/// about it. The one new reading, the minutes of moderate or harder effort, is read from each workout's
/// stored average heart rate and is said to be an estimate.
enum SimpleTrendRules {

    // MARK: A chart's verdict

    /// What a chart's one line says about its window.
    enum Verdict: Equatable {
        /// Fewer than `minDays` days with a reading: no two halves to compare.
        case tooFew
        /// The later half differs from the earlier half by less than the wearer's own day-to-day ups and
        /// downs can explain.
        case aboutTheSame
        /// The later half is higher or lower by `amount`, rounded the way the chart prints its values.
        case up(amount: Double)
        case down(amount: Double)
    }

    /// The days a window needs before it is split in two halves: the full view's trend chip needs the same four.
    static let minDays = 4

    /// The smallest change worth naming, as a fraction of the wearer's own day-to-day spread. Monitoring an
    /// individual's heart rate and HRV takes a fraction of that person's own variation as the smallest
    /// worthwhile change: 0.5 (Le Meur et al. 2013) or 1 (Plews et al. 2012) times the coefficient of
    /// variation, as reviewed by Buchheit (Front Physiol 2014;5:73), who adds that no fraction is yet proven to
    /// matter in practice. The lower of the two is used, so a real change is not hidden.
    static let worthwhileFraction = 0.5

    /// How far apart the two halves' averages must also be, in typical errors of their difference. An average
    /// of n days carries 1/√n of one day's noise (Buchheit 2014), so a short window has to move further than a
    /// long one before its change is more than noise; two typical errors is the usual bar.
    static let noiseMultiple = 2.0

    /// The largest day-to-day correlation the noise allowance accepts. Neighbouring days of HRV or resting
    /// heart rate resemble each other, which makes n days worth fewer than n independent ones; the standard
    /// AR(1) allowance, n·(1 − ρ)/(1 + ρ) effective days, is applied with ρ estimated from the window itself
    /// and capped here so a short window cannot claim near-infinite noise from a chance run.
    static let maxDayToDayCorrelation = 0.9

    /// The verdict for a window's values, oldest first, on the scale the chart prints them, rounded to
    /// `decimals` places as the chart prints them. The halves are the ones the full view's chip compares: the
    /// later half's average minus the earlier half's, split by count. A change is named only when it clears
    /// both the worthwhile fraction of the wearer's own spread and the noise of the two averages, and still
    /// reads as a change once rounded.
    static func verdict(values: [Double], decimals: Int) -> Verdict {
        guard values.count >= minDays else { return .tooFew }
        let mid = values.count / 2
        let earlier = Array(values.prefix(mid)), later = Array(values.suffix(values.count - mid))
        let earlierMean = earlier.reduce(0, +) / Double(earlier.count)
        let laterMean = later.reduce(0, +) / Double(later.count)
        let delta = laterMean - earlierMean
        guard delta.isFinite else { return .aboutTheSame }

        // The spread around each half's own average, so the change itself is not counted as noise.
        let earlierResiduals = earlier.map { $0 - earlierMean }
        let laterResiduals = later.map { $0 - laterMean }
        let squares = (earlierResiduals + laterResiduals).reduce(0) { $0 + $1 * $1 }
        let pooledSD = (squares / Double(values.count - 2)).squareRoot()

        // Day-to-day correlation of the residuals, pairs taken inside each half only.
        var lagged = 0.0
        for half in [earlierResiduals, laterResiduals] where half.count > 1 {
            for i in 1..<half.count { lagged += half[i - 1] * half[i] }
        }
        let rho = squares > 0 ? min(maxDayToDayCorrelation, max(0, lagged / squares)) : 0
        let inflation = ((1 + rho) / (1 - rho)).squareRoot()
        let typicalError = pooledSD * (1 / Double(earlier.count) + 1 / Double(later.count)).squareRoot() * inflation

        let bar = max(worthwhileFraction * pooledSD, noiseMultiple * typicalError)
        let scale = pow(10, Double(max(0, decimals)))
        let amount = (abs(delta) * scale).rounded() / scale
        guard abs(delta) >= bar, amount > 0 else { return .aboutTheSame }
        return delta > 0 ? .up(amount: amount) : .down(amount: amount)
    }

    // MARK: Windows in words

    /// "Last 90 days" for a window of trailing days, "All your history" for none: the one name for a window in
    /// Simple mode (Design v6, one name per thing; never "trailing").
    static func windowName(days: Int?) -> String {
        switch days {
        case 7?:   return String(localized: "Last 7 days")
        case 30?:  return String(localized: "Last 30 days")
        case 90?:  return String(localized: "Last 90 days")
        case 180?: return String(localized: "Last 6 months")
        case 365?: return String(localized: "Last 12 months")
        case let n?: return String(localized: "Last \(n) days")
        case nil:  return String(localized: "All your history")
        }
    }

    /// The same window at the end of a sentence, with its own preposition ("in the last 90 days"), so each
    /// language can carry the case and article it needs ("in den letzten 90 Tagen", "negli ultimi 90 giorni").
    static func windowPhrase(days: Int?) -> String {
        switch days {
        case 7?:   return String(localized: "in the last 7 days")
        case 30?:  return String(localized: "in the last 30 days")
        case 90?:  return String(localized: "in the last 90 days")
        case 180?: return String(localized: "in the last 6 months")
        case 365?: return String(localized: "in the last 12 months")
        case let n?: return String(localized: "in the last \(n) days")
        case nil:  return String(localized: "in all your history")
        }
    }
}

// MARK: - The week in words

/// The Trends week card in Simple mode: its three comparisons with last week, and one or two sentences. The
/// movers and the sparse-week lines follow the engine's own rules (`WeeklyDigestEngine.focalPoints`), pinned by
/// a test; the training balance is judged day by day against the ranges Today suggests, so the week can never
/// call training "too hard" that every morning's suggestion allowed.
enum SimpleWeekRules {

    /// The engine's bar for a week-over-week move worth a sentence: half the metric's typical spread
    /// (`WeeklyDigestEngine.focusThreshold`, internal to the package). A test pins the two together.
    static let focusThreshold = 0.5

    /// The engine's bar for "Rest held even" in a steady week, in Rest points of standard deviation
    /// (internal to the package as well). Pinned by the same test.
    static let evenRestSD = 6.0

    /// Whether a metric moved enough this week, by the engine's rule: both weeks hold enough days and the move
    /// is at least half the metric's typical spread.
    static func isMover(_ s: WeeklyMetricSummary) -> Bool {
        s.weekOverWeek.current.n >= WeeklyDigestEngine.minDaysForFocus
            && s.weekOverWeek.previous.n >= WeeklyDigestEngine.minDaysForFocus
            && abs(s.normalisedMove) >= focusThreshold
    }

    /// The movers, biggest first, ranked as the engine ranks them.
    static func movers(_ digest: WeeklyDigest) -> [WeeklyMetricSummary] {
        digest.metrics.filter(isMover).sorted { abs($0.normalisedMove) > abs($1.normalisedMove) }
    }

    /// The value a week's average prints as, on the reader's scale: Effort on 0–100 or 0–21, the rest as they
    /// are. Whole numbers, or one decimal for Effort on 0–21, the way the gauges print them.
    static func printed(_ value: Double, metric: WeeklyMetric, scale: EffortScale) -> Double {
        if metric == .effort {
            let shown = UnitFormatter.effortValue(value, scale: scale)
            return scale == .whoop ? (shown * 10).rounded() / 10 : shown.rounded()
        }
        return value.rounded()
    }

    /// Whether a higher value is good, bad or neither. Effort has no good direction: a harder week is not
    /// better or worse by itself (rule 4: only "Your day" judges how hard to go).
    enum Valence: Equatable { case higherIsBetter, lowerIsBetter, neither }

    static func valence(_ metric: WeeklyMetric) -> Valence {
        switch metric {
        case .effort: return .neither
        case .rhr: return .lowerIsBetter
        case .charge, .rest, .hrv: return .higherIsBetter
        }
    }

    /// How a change is coloured: green when good, amber when worth watching, plain otherwise.
    enum Tone: Equatable { case good, worthWatching, plain }

    /// One gauge's comparison with last week.
    enum Chip: Equatable {
        /// Either week has no reading: nothing is drawn.
        case none
        /// A rough comparison (either week has fewer than three days, the engine's `isRoughComparison`).
        case tooFewDays
        case same
        case higher(amount: Double, tone: Tone)
        case lower(amount: Double, tone: Tone)
    }

    /// The comparison, judged on the two weekly averages as printed, so "2 higher" always matches the two
    /// figures the reader can see. It is coloured only when the engine also counts it as a mover; a smaller
    /// move is an ordinary week and stays plain (Design v6, rule 6: colour means something).
    static func chip(_ s: WeeklyMetricSummary, scale: EffortScale) -> Chip {
        guard s.weekOverWeek.current.n > 0, s.weekOverWeek.previous.n > 0 else { return .none }
        if s.isRoughComparison { return .tooFewDays }
        let now = printed(s.weekOverWeek.current.mean, metric: s.metric, scale: scale)
        let before = printed(s.weekOverWeek.previous.mean, metric: s.metric, scale: scale)
        let difference = ((now - before) * 10).rounded() / 10
        guard difference != 0 else { return .same }
        let tone: Tone
        switch (isMover(s), valence(s.metric)) {
        case (false, _), (_, .neither): tone = .plain
        case (true, .higherIsBetter): tone = difference > 0 ? .good : .worthWatching
        case (true, .lowerIsBetter): tone = difference < 0 ? .good : .worthWatching
        }
        return difference > 0 ? .higher(amount: difference, tone: tone) : .lower(amount: -difference, tone: tone)
    }

    // MARK: Training against Charge, day by day

    /// One finished day of the week: its morning Charge and the Effort it ended with, both as stored (0–100).
    struct DayLoad: Equatable {
        let day: String
        let charge: Double
        let effort: Double
    }

    /// How the week's Effort sat against the range each morning's Charge suggests.
    enum Adherence: Equatable {
        case allInside(days: Int)
        case above(days: Int, of: Int)
        case below(days: Int, of: Int)
    }

    /// The days a week needs before its training is summed up: the engine's minimum for a week's comparison.
    static var adherenceMinDays: Int { WeeklyDigestEngine.minDaysForFocus }

    /// The week's Effort against the range Today suggests for each day's Charge (`CoupledView
    /// .optimalStrainRange`, the one Charge → Effort mapping), judged the way Today judges "in the range": on
    /// the Effort as printed, on the reader's scale (`SimpleDayPlan.progress`). Only finished days with both a
    /// Charge and an Effort count, so today's unfinished Effort is never called "below". Nil for fewer than
    /// `adherenceMinDays` such days. Above wins a tie with below: the harder side is the one worth saying.
    static func adherence(_ days: [DayLoad], scale: EffortScale) -> Adherence? {
        var above = 0, below = 0, counted = 0
        for d in days {
            guard let band21 = CoupledView.optimalStrainRange(recovery: d.charge) else { continue }
            counted += 1
            switch SimpleDayPlan.progress(stored: d.effort, scale: scale,
                                          band: SimpleDayPlan.band(band21, on: scale)) {
            case .above: above += 1
            case .below: below += 1
            case .within, .notStarted: break
            }
        }
        guard counted >= adherenceMinDays else { return nil }
        if above == 0 && below == 0 { return .allInside(days: counted) }
        return above >= below ? .above(days: above, of: counted) : .below(days: below, of: counted)
    }

    /// The finished days of a digest's week that carry both a Charge and an Effort, from the day rows.
    static func dayLoads(days: [DailyMetric], weekStart: String, weekEnd: String, today: String) -> [DayLoad] {
        days.compactMap { d in
            guard d.day >= weekStart, d.day <= weekEnd, d.day < today,
                  let charge = d.recovery, let effort = d.strain else { return nil }
            return DayLoad(day: d.day, charge: charge, effort: effort)
        }
    }

    // MARK: The week's sentences

    /// One sentence under the week's gauges.
    enum Line: Equatable {
        /// A metric that moved enough, with this week's and last week's averages as printed.
        case mover(WeeklyMetric, up: Bool, now: Double, before: Double)
        case adherence(Adherence)
        /// Fewer than three days into the week.
        case earlyInWeek(days: Int)
        /// Last week held fewer than three days.
        case thinLastWeek(days: Int)
        /// No last week at all (the engine's steady line would claim a comparison that did not happen).
        case noLastWeek
        /// Nothing moved, and Rest held even from night to night.
        case steadyEvenRest
        /// Nothing moved.
        case steady
    }

    /// At most two sentences, most telling first: the biggest mover (or, with none, the engine's sparse or
    /// steady reason); then the week's training against Charge, or the second mover when there is no such
    /// summary. The engine's balance line is not used: it compares the week's average Effort with its average
    /// Charge, which can call a week "leaning into the red" when every day sat inside the range Today
    /// suggested for that day's Charge (finding F23).
    static func lines(_ digest: WeeklyDigest, adherence: Adherence?, scale: EffortScale) -> [Line] {
        let ranked = movers(digest)
        func moverLine(_ s: WeeklyMetricSummary) -> Line {
            .mover(s.metric, up: s.wowDelta > 0,
                   now: printed(s.weekOverWeek.current.mean, metric: s.metric, scale: scale),
                   before: printed(s.weekOverWeek.previous.mean, metric: s.metric, scale: scale))
        }
        var lines: [Line] = []
        if let top = ranked.first {
            lines.append(moverLine(top))
        } else {
            let currentDays = digest.metrics.map(\.weekOverWeek.current.n).max() ?? 0
            let previousDays = digest.metrics.map(\.weekOverWeek.previous.n).max() ?? 0
            let minimum = WeeklyDigestEngine.minDaysForFocus
            if currentDays >= 1 && currentDays < minimum {
                lines.append(.earlyInWeek(days: currentDays))
            } else if currentDays >= minimum, previousDays >= 1, previousDays < minimum {
                lines.append(.thinLastWeek(days: previousDays))
            } else if currentDays >= minimum, previousDays == 0 {
                lines.append(.noLastWeek)
            } else if let sd = digest.sleepConsistencySD, sd <= evenRestSD {
                lines.append(.steadyEvenRest)
            } else if currentDays > 0 {
                lines.append(.steady)
            }
        }
        if let adherence {
            lines.append(.adherence(adherence))
        } else if ranked.count >= 2 {
            lines.append(moverLine(ranked[1]))
        }
        return Array(lines.prefix(2))
    }
}

// MARK: - Workouts against the guidelines

/// The Workouts summary in Simple mode: the last seven days of workouts, their minutes of moderate or harder
/// effort against the WHO guideline, and the days of strength training.
enum SimpleWorkoutRules {

    /// WHO 2020 guidelines on physical activity (Bull et al., Br J Sports Med 2020;54:1451–1462), adults from
    /// 18: at least 150–300 minutes a week of moderate aerobic activity, or 75–150 of vigorous, or an
    /// equivalent mix; plus muscle-strengthening activity on two or more days a week.
    static let guidelineMinutes = 150
    static let guidelineStrengthDays = 2
    /// The guideline above is for adults; children and adolescents have their own (an hour a day on average).
    static let guidelineMinAge = 18

    /// Intensity from heart rate as a share of the maximum: moderate from 64 %, vigorous from 77 % (ACSM's
    /// Guidelines for Exercise Testing and Prescription, 10th ed., 2018: moderate 64–76 %, vigorous 77–95 %).
    static let moderateFraction = 0.64
    static let vigorousFraction = 0.77

    /// The last seven days of workouts.
    struct Week: Equatable {
        /// Workouts started today or in the six days before.
        let count: Int
        let totalSeconds: Double
        /// Workouts in the seven days before those.
        let previousCount: Int
        /// Minutes of workouts whose average heart rate was moderate, and vigorous, against `maxHR`.
        let moderateMinutes: Double
        let vigorousMinutes: Double
        /// Workouts with a duration but no average heart rate, which cannot be judged.
        let withoutHeartRate: Int
        /// Calendar days with at least one strength workout.
        let strengthDays: Int

        /// The guideline's own sum: each vigorous minute counts as two moderate ones.
        var guidelineMinutes: Double { moderateMinutes + 2 * vigorousMinutes }
    }

    /// The calendar window of `days` days ending with today, as start times: from the start of the day `days − 1`
    /// days ago to the end of today. One definition for the summary card and for Simple mode's range picker, so
    /// "the last 7 days" counts the same workouts in both places (the full view's ranges count back from the
    /// newest workout instead, which made the two disagree).
    static func window(days: Int, now: Date, calendar: Calendar) -> Range<Int>? {
        let today = calendar.startOfDay(for: now)
        guard days > 0, let start = calendar.date(byAdding: .day, value: -(days - 1), to: today),
              let end = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }
        return Int(start.timeIntervalSince1970)..<Int(end.timeIntervalSince1970)
    }

    /// The week ending today, on the reader's calendar (`window(days: 7)`), against the seven days before it.
    /// `maxHR` nil (no age and no override) leaves both effort sums at zero and counts every workout as unjudged:
    /// there is nothing to judge them against.
    static func week(rows: [WorkoutRow], now: Date, calendar: Calendar, maxHR: Double?) -> Week {
        guard let current = window(days: 7, now: now, calendar: calendar),
              let fortnight = window(days: 14, now: now, calendar: calendar) else {
            return Week(count: 0, totalSeconds: 0, previousCount: 0, moderateMinutes: 0, vigorousMinutes: 0,
                        withoutHeartRate: 0, strengthDays: 0)
        }
        let inWeek = rows.filter { current.contains($0.startTs) }
        let previousCount = rows.filter { $0.startTs >= fortnight.lowerBound && $0.startTs < current.lowerBound }.count

        var moderate = 0.0, vigorous = 0.0, unjudged = 0
        var strengthDays = Set<Date>()
        let thresholds = maxHR.flatMap { $0 > 0 ? thresholdBPM(maxHR: $0) : nil }
        for row in inWeek {
            if isStrength(row) {
                strengthDays.insert(calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(row.startTs))))
            }
            guard let seconds = row.durationS, seconds > 0 else { continue }
            guard let thresholds, let average = row.avgHr, average > 0 else { unjudged += 1; continue }
            // Judged against the very bpm the card prints, so "vigorous from 147 bpm" never sits beside a
            // 146 bpm workout counted as vigorous, or the other way round.
            if average >= thresholds.vigorous { vigorous += seconds / 60 }
            else if average >= thresholds.moderate { moderate += seconds / 60 }
        }
        return Week(count: inWeek.count,
                    totalSeconds: inWeek.compactMap(\.durationS).filter { $0 > 0 }.reduce(0, +),
                    previousCount: previousCount, moderateMinutes: moderate, vigorousMinutes: vigorous,
                    withoutHeartRate: unjudged, strengthDays: strengthDays.count)
    }

    /// Words in a sport's name that mean muscle-strengthening work, matched against the name split into words.
    static let strengthWords = ["strength", "weight", "weights", "lifting", "resistance", "functional"]
    /// Compound names matched against the name's letters run together, so "CrossFit" (split as "Cross Fit")
    /// and "Weightlifting" are both found.
    static let strengthCompounds = ["crossfit", "weightlifting", "powerlifting", "bodybuilding", "kettlebell",
                                    "calisthenics"]

    /// A strength workout: an imported lifting log, or a sport whose name says strength (the Lift Log saves its
    /// sessions as "Strength Training"; WHOOP's "TraditionalStrengthTraining" reads the same once split).
    static func isStrength(_ row: WorkoutRow) -> Bool {
        if WorkoutSource.classify(row.source) == .lifting { return true }
        let name = WorkoutSource.editableSport(row.sport).lowercased()
        let words = name.split(whereSeparator: { !$0.isLetter }).map(String.init)
        if words.contains(where: { strengthWords.contains($0) }) { return true }
        let letters = String(name.filter(\.isLetter))
        return strengthCompounds.contains { letters.contains($0) }
    }

    /// Minutes as the summary says them: to the nearest 5, since the effort behind them is an estimate.
    static func roundedMinutes(_ minutes: Double) -> Int {
        guard minutes.isFinite, minutes > 0 else { return 0 }
        return Int((minutes / 5).rounded()) * 5
    }

    /// The lowest whole heart rate at each threshold for the reader's own maximum: the first bpm at or above 64 %
    /// and 77 % of it. A workout is judged against these same two numbers, which the card prints. (The small
    /// allowance keeps an exact product, 0.64 × 200 = 128, from rounding up past itself in floating point.)
    static func thresholdBPM(maxHR: Double) -> (moderate: Int, vigorous: Int) {
        (Int((maxHR * moderateFraction - 1e-9).rounded(.up)), Int((maxHR * vigorousFraction - 1e-9).rounded(.up)))
    }
}
