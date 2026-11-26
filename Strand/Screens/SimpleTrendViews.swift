import SwiftUI
import StrandDesign
import StrandAnalytics
import WhoopStore

// Simple mode's "Am I improving?" (Design v6, step 5): the pieces Trends and Workouts draw in their simple
// layout. The rules behind every sentence are in `SimpleTrendRules`, `SimpleWeekRules` and
// `SimpleWorkoutRules` (Strand/Data/SimpleTrends.swift); these views only say them.

// MARK: - A Trends chart's footer

/// Which Trends chart a footer belongs to, so its change can say what it means.
enum SimpleTrendMetric: Equatable {
    case charge, hrv, rhr, rest, effort

    /// Whether a rise is good, bad or neither for this reading.
    var valence: SimpleWeekRules.Valence {
        switch self {
        case .effort: return .neither
        case .rhr: return .lowerIsBetter
        case .charge, .hrv, .rest: return .higherIsBetter
        }
    }
}

/// The words under a Simple Trends chart: one verdict line, what it means, then the window's average, lowest
/// and highest.
struct SimpleTrendFooter: View {
    let metric: SimpleTrendMetric
    let verdict: SimpleTrendRules.Verdict
    /// A change's size as printed, with its unit ("4 ms").
    let amountText: (Double) -> String
    let average: String
    let lowest: String
    let highest: String

    var body: some View {
        VStack(alignment: .leading, spacing: NoopMetrics.space2) {
            HStack(alignment: .firstTextBaseline, spacing: NoopMetrics.space2) {
                Image(systemName: symbol)
                    .font(StrandFont.footnote.weight(.semibold))
                    .foregroundStyle(toneColour)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: NoopMetrics.spaceHalf) {
                    Text(verdictLine)
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let meaning {
                        Text(meaning)
                            .font(StrandFont.footnote)
                            .foregroundStyle(StrandPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            ChartFooter([("Average", average), ("Lowest", lowest), ("Highest", highest)])
        }
    }

    private enum Tone { case good, worthWatching, plain }

    private var tone: Tone {
        switch (verdict, metric.valence) {
        case (.up, .higherIsBetter), (.down, .lowerIsBetter): return .good
        case (.down, .higherIsBetter), (.up, .lowerIsBetter): return .worthWatching
        default: return .plain
        }
    }

    private var toneColour: Color {
        switch tone {
        case .good: return StrandPalette.statusPositive
        case .worthWatching: return StrandPalette.statusWarning
        case .plain: return StrandPalette.textTertiary
        }
    }

    private var symbol: String {
        switch verdict {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .aboutTheSame, .tooFew: return "equal"
        }
    }

    private var verdictLine: String {
        switch verdict {
        case .tooFew: return String(localized: "Too few days in this period to see a change.")
        case .aboutTheSame: return String(localized: "About the same across this period.")
        case .up(let amount): return String(localized: "Up \(amountText(amount)) across this period.")
        case .down(let amount): return String(localized: "Down \(amountText(amount)) across this period.")
        }
    }

    private var meaning: String? {
        switch (verdict, metric) {
        case (.tooFew, _): return nil
        case (.aboutTheSame, _):
            return String(localized: "The ups and downs are your normal day-to-day variation.")
        case (.up, .charge): return String(localized: "Higher is better: you have been more recovered.")
        case (.down, .charge):
            return String(localized: "Higher is better, so this is worth watching. It often follows harder training, shorter sleep, stress or illness.")
        case (.up, .hrv): return String(localized: "Higher is better: often a sign of rising fitness or better recovery.")
        case (.down, .hrv):
            return String(localized: "Higher is better, so this is worth watching. It can follow less exercise, hard training, poor sleep, stress, alcohol or illness.")
        case (.down, .rhr): return String(localized: "Lower is better: often a sign of rising fitness or better recovery.")
        case (.up, .rhr):
            return String(localized: "Lower is better, so this is worth watching. It can follow less exercise, hard training, poor sleep, stress, alcohol or illness.")
        case (.up, .rest): return String(localized: "Higher is better: you have been sleeping better.")
        case (.down, .rest):
            return String(localized: "Higher is better, so this is worth watching: your nights have been shorter or more broken.")
        case (.up, .effort): return String(localized: "Your days have been harder.")
        case (.down, .effort): return String(localized: "Your days have been lighter.")
        }
    }
}

// MARK: - The week in words

/// The texts of the Trends week card in Simple mode.
enum SimpleWeekTexts {

    /// A gauge's comparison with last week, and its colour; nil draws nothing.
    static func chip(_ chip: SimpleWeekRules.Chip, metric: WeeklyMetric, scale: EffortScale) -> (text: String, colour: Color)? {
        switch chip {
        case .none: return nil
        case .tooFewDays: return (String(localized: "Too few days to compare"), StrandPalette.textTertiary)
        case .same: return (String(localized: "Same as last week"), StrandPalette.textTertiary)
        case let .higher(amount, tone):
            return (String(localized: "\(number(amount, metric: metric, scale: scale)) higher than last week"), colour(tone))
        case let .lower(amount, tone):
            return (String(localized: "\(number(amount, metric: metric, scale: scale)) lower than last week"), colour(tone))
        }
    }

    private static func colour(_ tone: SimpleWeekRules.Tone) -> Color {
        switch tone {
        case .good: return StrandPalette.statusPositive
        case .worthWatching: return StrandPalette.statusWarning
        case .plain: return StrandPalette.textTertiary
        }
    }

    /// A weekly figure as the gauges print it: one decimal for Effort on 0–21, whole numbers otherwise.
    static func number(_ value: Double, metric: WeeklyMetric, scale: EffortScale) -> String {
        metric == .effort && scale == .whoop ? String(format: "%.1f", value) : "\(Int(value.rounded()))"
    }

    static func line(_ line: SimpleWeekRules.Line, scale: EffortScale) -> String {
        switch line {
        case let .mover(metric, up, now, before):
            let a = number(now, metric: metric, scale: scale), b = number(before, metric: metric, scale: scale)
            switch (metric, up) {
            case (.charge, true):
                return String(localized: "Your Charge averaged \(a) this week, up from \(b) last week: your body has been more recovered.")
            case (.charge, false):
                return String(localized: "Your Charge averaged \(a) this week, down from \(b) last week. A lower week often follows harder training, shorter sleep, stress or illness.")
            case (.rest, true):
                return String(localized: "Your Rest averaged \(a) this week, up from \(b) last week: you slept better.")
            case (.rest, false):
                return String(localized: "Your Rest averaged \(a) this week, down from \(b) last week: your nights were shorter or more broken.")
            case (.effort, true):
                return String(localized: "Your days were harder this week: Effort averaged \(a), up from \(b) last week.")
            case (.effort, false):
                return String(localized: "Your days were lighter this week: Effort averaged \(a), down from \(b) last week.")
            case (.hrv, true):
                return String(localized: "Your HRV averaged \(a) ms this week, up from \(b) ms last week: a sign of good recovery.")
            case (.hrv, false):
                return String(localized: "Your HRV averaged \(a) ms this week, down from \(b) ms last week. That often follows hard training, poor sleep, stress, alcohol or the start of an illness.")
            case (.rhr, false):
                return String(localized: "Your resting heart rate averaged \(a) bpm this week, down from \(b) bpm last week: a sign of good recovery.")
            case (.rhr, true):
                return String(localized: "Your resting heart rate averaged \(a) bpm this week, up from \(b) bpm last week. That often follows hard training, poor sleep, stress, alcohol or the start of an illness.")
            }
        case .adherence(let adherence):
            switch adherence {
            case .allInside(let days):
                return String(localized: "Your Effort stayed inside the range suggested for each day's Charge on all \(days) days. Your day on Today suggests the range each morning.")
            case let .above(days, of):
                return String(localized: "On \(days) of \(of) days your Effort went above the range suggested for that day's Charge. Your day on Today suggests the range each morning.")
            case let .below(days, of):
                return String(localized: "On \(days) of \(of) days your Effort stayed below the range suggested for that day's Charge: energy to spare. Your day on Today suggests the range each morning.")
            }
        case .earlyInWeek(let days):
            return days == 1
                ? String(localized: "Only 1 day into this week so far: too early to compare it with last week.")
                : String(localized: "Only \(days) days into this week so far: too early to compare it with last week.")
        case .thinLastWeek(let days):
            return days == 1
                ? String(localized: "Last week had only 1 day with readings, so comparisons with it are rough.")
                : String(localized: "Last week had only \(days) days with readings, so comparisons with it are rough.")
        case .noLastWeek:
            return String(localized: "No readings last week, so there is nothing to compare this week with yet.")
        case .steadyEvenRest:
            return String(localized: "A steady week: your scores were about the same as last week, and your Rest stayed even from night to night.")
        case .steady:
            return String(localized: "A steady week: your scores were about the same as last week.")
        }
    }
}

// MARK: - Workouts: the last seven days against the guidelines

/// The first card of Simple mode's Workouts: the last seven days of workouts, measured against the WHO
/// guideline for adults, and the days of strength training.
struct SimpleWorkoutWeekCard: View {
    let week: SimpleWorkoutRules.Week
    /// The maximum heart rate the workouts are judged against (`ProfileStore.effortHRmax`); nil without an age.
    let maxHR: Double?
    let age: Int

    var body: some View {
        NoopCard(tint: StrandPalette.effortColor) {
            VStack(alignment: .leading, spacing: NoopMetrics.space3) {
                SectionHeader("Last 7 days")
                Text(headline)
                    .font(StrandFont.headline)
                    .foregroundStyle(StrandPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let comparison {
                    Text(comparison)
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if age >= SimpleWorkoutRules.guidelineMinAge {
                    Divider().overlay(StrandPalette.hairline)
                    guideline
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var guideline: some View {
        VStack(alignment: .leading, spacing: NoopMetrics.space2) {
            Text("Health guidelines suggest at least 150 minutes of moderate activity a week, or 75 minutes of vigorous activity.")
                .font(StrandFont.subhead)
                .foregroundStyle(StrandPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if let maxHR, maxHR > 0 {
                let reached = SimpleWorkoutRules.roundedMinutes(week.guidelineMinutes)
                let met = reached >= SimpleWorkoutRules.guidelineMinutes
                HStack(alignment: .firstTextBaseline, spacing: NoopMetrics.space2) {
                    Image(systemName: met ? "checkmark.circle.fill" : "circle.dashed")
                        .font(StrandFont.footnote.weight(.semibold))
                        .foregroundStyle(met ? StrandPalette.statusPositive : StrandPalette.textTertiary)
                        .accessibilityHidden(true)
                    Text(met
                         ? String(localized: "Your workouts reached about \(reached) minutes, counting each vigorous minute twice: you met the guideline.")
                         : String(localized: "Your workouts reached about \(reached) minutes, counting each vigorous minute twice: \(SimpleWorkoutRules.guidelineMinutes - reached) to go. Brisk walking outside workouts counts too."))
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                let bpm = SimpleWorkoutRules.thresholdBPM(maxHR: maxHR)
                Text("Judged from each workout's average heart rate: moderate from \(bpm.moderate) bpm, vigorous from \(bpm.vigorous) bpm, for your maximum of \(Int(maxHR.rounded())).")
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                if week.withoutHeartRate > 0 {
                    Text(week.withoutHeartRate == 1
                         ? String(localized: "1 workout had no heart rate and is not counted.")
                         : String(localized: "\(week.withoutHeartRate) workouts had no heart rate and are not counted."))
                        .font(StrandFont.footnote)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Add your date of birth in Settings, under Profile, so NOOP can judge how hard each workout was.")
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(strengthLine)
                .font(StrandFont.subhead)
                .foregroundStyle(StrandPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var headline: String {
        let total = SimpleDayPlan.durationText(week.totalSeconds / 60)
        switch week.count {
        case 0: return String(localized: "No workouts in the last 7 days.")
        case 1: return String(localized: "1 workout, \(total) in total.")
        default: return String(localized: "\(week.count) workouts, \(total) in total.")
        }
    }

    private var comparison: String? {
        guard week.count > 0 || week.previousCount > 0 else { return nil }
        let difference = week.count - week.previousCount
        if difference > 0 { return String(localized: "\(difference) more than the 7 days before.") }
        if difference < 0 { return String(localized: "\(-difference) fewer than the 7 days before.") }
        return String(localized: "The same number as the 7 days before.")
    }

    private var strengthLine: String {
        switch week.strengthDays {
        case 0: return String(localized: "No strength training in the last 7 days. Guidelines also suggest muscle-strengthening activity on 2 or more days a week.")
        case 1: return String(localized: "Strength training on 1 day. Guidelines also suggest muscle-strengthening activity on 2 or more days a week.")
        default: return String(localized: "Strength training on \(week.strengthDays) days. Guidelines also suggest muscle-strengthening activity on 2 or more days a week.")
        }
    }
}
