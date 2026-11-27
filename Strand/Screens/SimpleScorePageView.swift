import SwiftUI
import StrandAnalytics
import StrandDesign
import WhoopStore

// MARK: - Simple mode: one score, explained
//
// The page a score ring opens in Simple mode (Design v6, "tap a score, get an answer"). One layout for
// Charge, Effort and Rest: the number with its word, how it compares with the wearer's own usual, what moved
// it, what to do, and two links (how NOOP calculates it; the full statistics page the ring opens in the full
// view). The header and the "what moved it" rows are the tapped ring's own values (`SimpleScoreSnapshot`);
// the rules for everything the page works out itself are in `SimpleScoreRules`.

/// The word that says how good a score is, one function per score, shared by every screen that prints it.
enum SimpleScoreWords {

    /// Low / Medium / High for a Charge.
    static func charge(_ pct: Double) -> String {
        switch SimpleDayPlan.chargeLevel(pct) {
        case .low: return String(localized: "Low")
        case .medium: return String(localized: "Medium")
        case .high: return String(localized: "High")
        }
    }

    /// Easy / Moderate / Hard / Very hard for a day's Effort (stored 0–100).
    static func effort(stored: Double, scale: EffortScale) -> String {
        switch SimpleDayPlan.effortLevel(stored: stored, scale: scale) {
        case .easy: return String(localized: "Easy")
        case .moderate: return String(localized: "Moderate")
        case .hard: return String(localized: "Hard")
        case .veryHard: return String(localized: "Very hard")
        }
    }

    /// The Sleep tab's own word for a Rest score.
    static func rest(_ score: Double) -> String { SleepView.sleepScoreWord(score) }

    static func word(_ kind: SimpleScoreKind, stored: Double, scale: EffortScale) -> String {
        switch kind {
        case .charge: return charge(stored)
        case .effort: return effort(stored: stored, scale: scale)
        case .rest: return rest(stored)
        }
    }
}

/// How a score is printed on the Simple screens: whole numbers for Charge and Rest, the ring's own form
/// for Effort (`SimpleDayPlan.effortText`).
enum SimpleScoreFormat {
    static func text(_ kind: SimpleScoreKind, stored: Double, scale: EffortScale) -> String {
        switch kind {
        case .effort: return SimpleDayPlan.effortText(stored: stored, scale: scale)
        case .charge, .rest: return "\(Int(stored.rounded()))"
        }
    }

    /// The top of the scale a score is printed on.
    static func scaleTop(_ kind: SimpleScoreKind, scale: EffortScale) -> Double {
        kind == .effort && scale == .whoop ? 21 : 100
    }

    /// A stored score on the scale it is printed on.
    static func shown(_ kind: SimpleScoreKind, stored: Double, scale: EffortScale) -> Double {
        kind == .effort ? UnitFormatter.effortValue(stored, scale: scale) : stored
    }

    /// "37–52": two printed figures and an en dash, the same in every language.
    static func rangeText(low: String, high: String) -> String {
        low == high ? low : [low, high].joined(separator: "–")
    }

    /// "29 min · 256 kcal" for a workout row: figures and units only, as Today's workouts card prints them.
    static func workoutSub(_ workout: SimpleScoreSnapshot.WorkoutLine) -> String {
        var parts = ["\(workout.minutes) min"]
        if let kcal = workout.kcal { parts.append("\(kcal) kcal") }
        return parts.joined(separator: " · ")
    }
}

/// The suggested Effort range with today's Effort so far and one line saying where the day stands. One view
/// for Today's "Your day" card and the Effort page, so the two can never word the same range differently.
struct SimpleEffortPlanView: View {
    let band21: ClosedRange<Int>
    /// Today's Effort as stored (0–100), nil while none is measured.
    let stored: Double?
    let scale: EffortScale
    /// Draw a hairline above (Today's card separates the plan from the verdict with one).
    var showsDivider = true

    var body: some View {
        let band = SimpleDayPlan.band(band21, on: scale)
        let progress = SimpleDayPlan.progress(stored: stored, scale: scale, band: band)
        let soFar = stored.map { SimpleDayPlan.effortText(stored: $0, scale: scale) } ?? ""
        let intensityLine: String
        switch SimpleDayPlan.intensity(of: band21) {
        case .hard: intensityLine = String(localized: "A hard day, based on your Charge")
        case .moderate: intensityLine = String(localized: "A moderate day, based on your Charge")
        case .easy: intensityLine = String(localized: "An easy day, based on your Charge")
        }
        let progressLine: String
        switch progress {
        case .notStarted: progressLine = String(localized: "No effort measured yet today.")
        case .below: progressLine = String(localized: "So far \(soFar). The range starts at \(band.lowerBound).")
        case .within: progressLine = String(localized: "So far \(soFar). You're in the range.")
        case .above: progressLine = String(localized: "So far \(soFar), past the range. Take the rest of the day easy.")
        }
        return VStack(alignment: .leading, spacing: 8) {
            if showsDivider {
                Rectangle().fill(StrandPalette.hairline).frame(height: NoopMetrics.hairlineWidth)
                    .padding(.vertical, 2)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Suggested Effort")
                    .font(StrandFont.subhead.weight(.semibold))
                    .foregroundStyle(StrandPalette.textPrimary)
                Spacer(minLength: 8)
                // Charge colour, like the range's outline on the bar: the range comes from Charge.
                Text(verbatim: SimpleDayPlan.rangeText(band))
                    .font(StrandFont.number(17))
                    .foregroundStyle(StrandPalette.chargeColor)
            }
            Text(intensityLine)
                .font(StrandFont.caption)
                .foregroundStyle(StrandPalette.textSecondary)
            SimpleEffortBar(value: stored.map { UnitFormatter.effortValue($0, scale: scale) },
                            band: band, maxValue: scale == .whoop ? 21 : 100)
            Text(progressLine)
                .font(StrandFont.caption)
                .foregroundStyle(StrandPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The Simple-mode page for one score.
struct SimpleScorePageView: View {
    let snapshot: SimpleScoreSnapshot

    @EnvironmentObject var repo: Repository
    @AppStorage(UnitPrefs.effortScaleKey) private var effortScaleRaw = EffortScale.hundred.rawValue
    private var effortScale: EffortScale { UnitPrefs.resolveEffortScale(effortScaleRaw) }

    /// The score's day-keyed history (stored 0–100), for the usual range and the last seven days.
    @State private var series: [(day: String, value: Double)] = []
    /// The technical scoring guide, opened at this score's section (nil = closed).
    @State private var scoringSection: ScoreSection?

    private var kind: SimpleScoreKind { snapshot.kind }

    private var guideTerm: PlainGuideTerm {
        switch kind {
        case .charge: return .charge
        case .effort: return .effort
        case .rest: return .rest
        }
    }

    private var title: LocalizedStringKey {
        switch kind {
        case .charge: return "Charge"
        case .effort: return "Effort"
        case .rest: return "Rest"
        }
    }

    var body: some View {
        ScreenScaffold(title: title, topBackground: liquidScaffoldSky()) {
            headerCard
            if snapshot.stored != nil { comparedCard }
            movedCard
            whatToDoCard
            linksCard
        }
        .task(id: repo.refreshSeq) { await load() }
        .sheet(item: $scoringSection) { section in
            ScoringGuideView(initialSection: section, onClose: { scoringSection = nil })
        }
    }

    // MARK: Header

    private func printed(_ stored: Double) -> String {
        SimpleScoreFormat.text(kind, stored: stored, scale: effortScale)
    }

    /// The colour of a bar that stands for a score. Charge takes the ring's own ramp (green for a high
    /// Charge through amber to red for a low one), so a bar is never green beside the word "Low"; Effort
    /// and Rest have one colour each, as their rings do.
    private func barTint(_ stored: Double) -> Color {
        kind == .charge ? StrandPalette.recoveryColor(stored) : guideTerm.tint
    }

    /// The one-line meaning: the guide's own line for the selected day's own score, and the same thing in
    /// the past tense for an earlier day's, so a page about last Tuesday never says "today".
    private var meaning: String {
        if snapshot.isToday && !snapshot.isCarried { return guideTerm.summary }
        switch kind {
        case .charge: return String(localized: "How ready your body was that day.")
        case .effort: return String(localized: "How hard your heart worked that day.")
        case .rest: return String(localized: "How well you slept that night.")
        }
    }

    /// What the page says in place of a number that is not there.
    private var emptyLine: String {
        if let nights = snapshot.calibratingNights {
            return String(localized: "Learning what's normal for you: \(nights) of \(Baselines.minNightsSeed) nights so far. Keep wearing the strap to bed and your scores fill in.")
        }
        switch kind {
        case .effort:
            return snapshot.isToday ? String(localized: "No effort measured yet today.")
                                    : String(localized: "No Effort was measured on this day.")
        case .charge, .rest:
            return String(localized: "No score for this day. It needs a night of sleep with the strap on.")
        }
    }

    private var headerCard: some View {
        NoopCard {
            // The screen's title already names the score, so the card starts with the number.
            VStack(alignment: .leading, spacing: 10) {
                if let stored = snapshot.stored {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        // The value in the normal text colour: the score's own colour stays on its icon and
                        // its bar, so colour on this page always means something (Design v6, rule 6).
                        Text(verbatim: printed(stored))
                            .font(StrandFont.number(52))
                            .foregroundStyle(StrandPalette.textPrimary)
                        if kind == .effort && effortScale == .whoop {
                            Text("of 21").font(StrandFont.subhead).foregroundStyle(StrandPalette.textTertiary)
                        } else {
                            Text("of 100").font(StrandFont.subhead).foregroundStyle(StrandPalette.textTertiary)
                        }
                        Spacer(minLength: 8)
                        Text(SimpleScoreWords.word(kind, stored: stored, scale: effortScale))
                            .font(StrandFont.rounded(19))
                            .foregroundStyle(StrandPalette.textPrimary)
                    }
                    .accessibilityElement(children: .combine)
                    SimpleScoreLevelBar(fraction: SimpleScoreFormat.shown(kind, stored: stored, scale: effortScale)
                                            / SimpleScoreFormat.scaleTop(kind, scale: effortScale),
                                        tint: barTint(stored))
                        .accessibilityHidden(true)
                    if snapshot.isCarried {
                        Text("From \(TodayView.lastChargeDateFmt(snapshot.scoreDayKey))")
                            .font(StrandFont.caption)
                            .foregroundStyle(StrandPalette.textSecondary)
                    }
                    Text(meaning)
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(emptyLine)
                        .font(StrandFont.body)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: Compared with you

    private var comparedCard: some View {
        let usual = SimpleScoreRules.usualRange(series: series, before: snapshot.scoreDayKey)
        func onScale(_ stored: Double) -> Double { SimpleScoreFormat.shown(kind, stored: stored, scale: effortScale) }
        let bars = SimpleScoreRules.weekBars(series: series, endingOn: snapshot.selectedDayKey,
                                             shownDayKey: snapshot.scoreDayKey, shownValue: snapshot.stored)
        return NoopCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Compared with you").strandOverline()
                    .foregroundStyle(StrandPalette.textSecondary)
                SimpleScoreWeekBars(
                    bars: bars.map { bar in
                        .init(id: bar.dayKey, label: Self.weekdayLabel(bar.dayKey),
                              value: bar.value.map { SimpleScoreFormat.shown(kind, stored: $0, scale: effortScale) },
                              text: bar.value.map { printed($0) },
                              tint: bar.value.map { barTint($0) } ?? guideTerm.tint,
                              highlighted: bar.dayKey == snapshot.scoreDayKey)
                    },
                    usual: usual.map { onScale($0.low)...max(onScale($0.low), onScale($0.high)) },
                    usualText: usual.map { String(localized: "usually \(usualText($0))") },
                    scaleTop: SimpleScoreFormat.scaleTop(kind, scale: effortScale))
                if let stored = snapshot.stored, let line = comparisonLine(stored: stored, usual: usual) {
                    Text(line)
                        .font(StrandFont.subhead.weight(.semibold))
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(usual != nil
                     ? String(localized: "Your usual range is where the middle half of the 30 days before this one fell.")
                     : String(localized: "NOOP needs a week of scores before it can say what is usual for you."))
                    .font(StrandFont.caption)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// The usual range as printed ("37–52").
    private func usualText(_ usual: SimpleScoreRules.UsualRange) -> String {
        SimpleScoreFormat.rangeText(low: printed(usual.low), high: printed(usual.high))
    }

    /// The sentence under the bars. Today's Effort is still climbing, so it is set beside a usual full day
    /// rather than called higher or lower than one.
    private func comparisonLine(stored: Double, usual: SimpleScoreRules.UsualRange?) -> String? {
        guard let usual else { return nil }
        let (value, range) = (printed(stored), usualText(usual))
        if kind == .effort && snapshot.isToday {
            return String(localized: "So far today \(value). Your usual full day is \(range).")
        }
        switch SimpleScoreRules.comparison(printed: value, lowPrinted: printed(usual.low),
                                           highPrinted: printed(usual.high)) {
        case .higher: return String(localized: "Higher than your usual range, \(range).")
        case .lower: return String(localized: "Lower than your usual range, \(range).")
        case .within: return String(localized: "In your usual range, \(range).")
        case nil: return nil
        }
    }

    /// A short weekday name for a day key, in the app's language ("Mon").
    private static func weekdayLabel(_ dayKey: String) -> String {
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd"
        guard let date = parser.date(from: dayKey) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.activeLocale
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter.string(from: date)
    }

    // MARK: What moved it

    @ViewBuilder
    private var movedCard: some View {
        switch kind {
        case .charge:
            if snapshot.stored != nil { chargeMovedCard }
        case .effort:
            effortMovedCard
        case .rest:
            if let stored = snapshot.stored { restMovedCard(shown: stored) }
        }
    }

    private func movedHeading() -> some View {
        Text("What moved it").strandOverline()
            .foregroundStyle(StrandPalette.textSecondary)
    }

    private var chargeMovedCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 12) {
                movedHeading()
                if snapshot.drivers.isEmpty {
                    Text("The readings behind this score aren't available for this day.")
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(SimpleScorePageView.chargeRowsIntro(carriedDayKey: snapshot.isCarried ? snapshot.scoreDayKey : nil))
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    // Every reading, in the breakdown's own order. One bar scale for all rows, as on Today.
                    let maxMagnitude = snapshot.drivers.map { abs($0.deltaPoints) }.max() ?? 1
                    ForEach(Array(snapshot.drivers.enumerated()), id: \.offset) { _, line in
                        ChargeDriverRow(driver: ChargeDriver(label: line.label, deltaPoints: line.deltaPoints,
                                                             valueText: line.valueText,
                                                             baselineText: line.baselineText,
                                                             verdict: line.verdict),
                                        maxMagnitude: maxMagnitude, twoSided: true)
                    }
                }
            }
        }
    }

    /// The line above the Charge rows: which night they describe. A carried Charge names its day, so rows
    /// from an earlier night are never introduced as last night's.
    static func chargeRowsIntro(carriedDayKey: String?) -> String {
        guard let carriedDayKey else {
            return String(localized: "How last night's readings moved your Charge, compared with your own normal. A bar to the right raised it, a bar to the left lowered it.")
        }
        let date = TodayView.lastChargeDateFmt(carriedDayKey)
        return String(localized: "How the readings from \(date) moved your Charge, compared with your own normal. A bar to the right raised it, a bar to the left lowered it.")
    }

    private var effortMovedCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 12) {
                movedHeading()
                Text("Effort adds up everything your heart did through the day: workouts and everyday movement.")
                    .font(StrandFont.caption)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                if snapshot.workouts.isEmpty {
                    Text("No workouts recorded on this day.")
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(snapshot.workouts, id: \.self) { workout in
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(WorkoutSource.displaySport(workout.sport))
                                    .font(StrandFont.subhead.weight(.semibold))
                                    .foregroundStyle(StrandPalette.textPrimary)
                                Text(verbatim: SimpleScoreFormat.workoutSub(workout))
                                    .font(StrandFont.caption)
                                    .foregroundStyle(StrandPalette.textTertiary)
                            }
                            Spacer(minLength: 8)
                            if let strain = workout.strain {
                                Text("Effort \(SimpleDayPlan.effortText(stored: strain, scale: effortScale))")
                                    .font(StrandFont.subhead)
                                    .foregroundStyle(StrandPalette.textSecondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                if let band21 = snapshot.band21 {
                    SimpleEffortPlanView(band21: band21, stored: snapshot.stored, scale: effortScale)
                }
            }
        }
    }

    private func restMovedCard(shown: Double) -> some View {
        let daily = repo.days.last(where: { $0.day == snapshot.scoreDayKey })
        let imported = repo.importedSleep[snapshot.scoreDayKey]?.performancePct
        return NoopCard {
            VStack(alignment: .leading, spacing: 14) {
                movedHeading()
                switch SimpleScoreRules.restParts(shownScore: shown, daily: daily, importedScore: imported) {
                case .success(let breakdown):
                    Text("Rest is built from four parts. Each one shows the points it earned.")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(breakdown.parts, id: \.kind) { part in
                        restPartRow(part, breakdown: breakdown)
                    }
                    Text("Your strap estimates sleep stages, so read the deep and REM part loosely.")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                case .failure(let gap):
                    Text(gap == .importedScore
                         ? String(localized: "This night's score is WHOOP's own, imported with your data, so NOOP can't show how it was built. These are the night's figures:")
                         : String(localized: "NOOP can't show the parts of this score for this night."))
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if gap == .importedScore, let daily { restFacts(daily) }
                }
            }
        }
    }

    /// One part of the Rest score: its name, its points, a bar of the points earned, and the night's figure
    /// behind it in a sentence.
    private func restPartRow(_ part: SimpleScoreRules.RestPart,
                             breakdown: SimpleScoreRules.RestBreakdown) -> some View {
        let name: String
        var lines: [String] = []
        switch part.kind {
        case .duration:
            name = String(localized: "Hours asleep")
            let asleep = SimpleDayPlan.durationText(breakdown.asleepMin)
            let full = SimpleDayPlan.durationText(breakdown.fullNightMin)
            lines.append(String(localized: "\(asleep) asleep. Full marks at \(full)."))
            // The Sleep tab's personal need can be longer than the night this score counts as full. Said
            // here, where the two figures meet, rather than leaving the wearer to find they differ.
            let personal = Int(SleepModel.debtNeedMin(days: repo.days).rounded())
            if personal != Int(breakdown.fullNightMin.rounded()) {
                let need = SimpleDayPlan.durationText(Double(personal))
                lines.append(String(localized: "Your sleep need on the Sleep tab is \(need). This score still counts \(full) as a full night."))
            }
        case .efficiency:
            name = String(localized: "Time asleep while in bed")
            lines.append(String(localized: "You were asleep for \(Int(breakdown.efficiencyPct.rounded()))% of your time in bed."))
        case .restorative:
            name = String(localized: "Deep + REM sleep")
            let amount = SimpleDayPlan.durationText(breakdown.restorativeMin)
            lines.append(String(localized: "\(amount), \(Int(breakdown.restorativeSharePct.rounded()))% of your sleep. Full marks at \(Int(breakdown.restorativeTargetPct.rounded()))%."))
            if breakdown.deepWasShort {
                lines.append(String(localized: "Deep sleep was short, which lowered this part."))
            }
        case .regularity:
            name = String(localized: "Regular bed and wake times")
            if let index = breakdown.regularityIndex {
                lines.append(String(localized: "Your regularity over the last week: \(index) of 100. Most adults score around 80; the same bed and wake times every day raise it."))
            } else {
                lines.append(String(localized: "Measured after about 5 nights in a row with the strap on. Until then every night gets half of these points, so the highest possible score is \(breakdown.highestPossible)."))
            }
        }
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(StrandFont.subhead.weight(.semibold))
                    .foregroundStyle(StrandPalette.textPrimary)
                Spacer(minLength: 8)
                Text("\(part.points) of \(part.maxPoints)")
                    .font(StrandFont.captionNumber)
                    .foregroundStyle(StrandPalette.textSecondary)
            }
            SimpleScoreLevelBar(fraction: part.maxPoints > 0 ? Double(part.points) / Double(part.maxPoints) : 0,
                                tint: guideTerm.tint)
                .accessibilityHidden(true)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// The night's own figures, without points, for a score NOOP did not build.
    @ViewBuilder
    private func restFacts(_ daily: DailyMetric) -> some View {
        if let asleep = daily.totalSleepMin, asleep > 0 {
            restFactRow(String(localized: "Hours asleep"), SimpleDayPlan.durationText(asleep))
        }
        if let eff = daily.efficiency {
            restFactRow(String(localized: "Time asleep while in bed"),
                        "\(Int((eff <= 1.0 ? eff * 100.0 : eff).rounded()))%")
        }
        if daily.deepMin != nil || daily.remMin != nil {
            restFactRow(String(localized: "Deep + REM sleep"),
                        SimpleDayPlan.durationText((daily.deepMin ?? 0) + (daily.remMin ?? 0)))
        }
    }

    private func restFactRow(_ name: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(name).font(StrandFont.subhead).foregroundStyle(StrandPalette.textPrimary)
            Spacer(minLength: 8)
            Text(verbatim: value).font(StrandFont.captionNumber).foregroundStyle(StrandPalette.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: What to do

    /// Two sentences per score. They describe what the score asks for in general and point to Today for
    /// today's advice: only "Your day" weighs every signal, so it stays the one adviser (Design v6, rule 4).
    private var advice: String {
        switch kind {
        case .charge:
            return String(localized: "A high Charge means your body can take a hard day. A low one asks for an easier day and an earlier night. How hard to go today is on Today, under Your day.")
        case .effort:
            return String(localized: "There is no perfect number. Aim higher on days your Charge is high and lower when it is low. How hard to go today is on Today, under Your day.")
        case .rest:
            return String(localized: "Most of this score is how long you slept, so an earlier bedtime is the surest way to raise it. Today gives you a time to be asleep by, under Tonight.")
        }
    }

    private var whatToDoCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("What to do").strandOverline()
                    .foregroundStyle(StrandPalette.textSecondary)
                Text(advice)
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Links

    private var linksCard: some View {
        NoopCard(padding: 0) {
            VStack(spacing: 0) {
                Button { scoringSection = guideTerm.scoringSection } label: {
                    linkRow(icon: "function", title: String(localized: "How NOOP calculates it"))
                }
                .buttonStyle(.plain)
                Rectangle().fill(StrandPalette.hairline).frame(height: NoopMetrics.hairlineWidth)
                    .padding(.leading, 52)
                // The page the ring opens in the full view: every stored value, chart and comparison. A
                // deeper link, so it is closure-based (see TabRoute.swift).
                if let metric = MetricCatalog.all.first(where: { $0.key == kind.metricKey }) {
                    NavigationLink { MetricDetailView(metric: metric) } label: {
                        linkRow(icon: "chart.xyaxis.line", title: String(localized: "All readings and statistics"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func linkRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(StrandPalette.accent)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
                .font(StrandFont.body)
                .foregroundStyle(StrandPalette.textPrimary)
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(StrandPalette.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: NoopMetrics.controlHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    // MARK: Read

    /// The score's history, from the series the ring itself reads: the day rows for Charge and Effort, the
    /// resolved Rest series for Rest.
    private func load() async {
        switch kind {
        case .charge:
            series = repo.days.compactMap { row in row.recovery.map { (day: row.day, value: $0) } }
        case .effort:
            series = repo.days.compactMap { row in row.strain.map { (day: row.day, value: $0) } }
        case .rest:
            series = await repo.exploreSeries(key: "sleep_performance", source: "my-whoop")
        }
    }
}

/// A thin bar filled to a fraction: where a score sits on its scale, or the points a part earned.
struct SimpleScoreLevelBar: View {
    let fraction: Double
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous).fill(StrandPalette.surfaceInset)
                Capsule(style: .continuous).fill(tint)
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: 6)
    }
}

/// The last seven days as bars on the score's own scale, over a band at the wearer's usual range. Drawn
/// still (no animation). A day without a score keeps its slot and shows a dash, never a zero bar.
struct SimpleScoreWeekBars: View {
    struct Bar: Identifiable {
        let id: String
        /// The weekday under the bar.
        let label: String
        /// The score on the scale it is printed on, nil for a day without one.
        let value: Double?
        /// The score as printed, nil for a day without one.
        let text: String?
        let tint: Color
        /// The day the page is about.
        let highlighted: Bool
    }

    let bars: [Bar]
    /// The wearer's usual range on the printed scale, drawn as a band behind the bars.
    let usual: ClosedRange<Double>?
    let usualText: String?
    let scaleTop: Double

    private static let barAreaHeight: CGFloat = 84

    private func height(_ value: Double) -> CGFloat {
        guard scaleTop > 0 else { return 0 }
        return CGFloat(max(0, min(1, value / scaleTop))) * Self.barAreaHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // The bars alone share the area with the usual band; each day's number sits under its bar, so
            // the band never runs through a figure.
            ZStack(alignment: .bottomLeading) {
                if let usual {
                    // The usual range, as a band across the week: a bar that ends inside it is a usual day.
                    Rectangle()
                        .fill(StrandPalette.textSecondary.opacity(0.14))
                        .frame(height: max(height(usual.upperBound) - height(usual.lowerBound), 2))
                        .offset(y: -height(usual.lowerBound))
                }
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(bars) { bar in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(bar.tint.opacity(bar.highlighted ? 1 : 0.4))
                            .frame(height: bar.value.map { max(height($0), 2) } ?? 0)
                            .frame(maxWidth: .infinity, maxHeight: Self.barAreaHeight, alignment: .bottom)
                    }
                }
            }
            .frame(height: Self.barAreaHeight)
            HStack(spacing: 8) {
                ForEach(bars) { bar in
                    VStack(spacing: 1) {
                        Text(verbatim: bar.text ?? "–")
                            .font(StrandFont.captionNumber)
                            .foregroundStyle(bar.highlighted ? StrandPalette.textPrimary : StrandPalette.textSecondary)
                        Text(verbatim: bar.label)
                            .font(StrandFont.caption)
                            .foregroundStyle(bar.highlighted ? StrandPalette.textPrimary : StrandPalette.textTertiary)
                    }
                    .lineLimit(1).minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
                }
            }
            if let usualText {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(StrandPalette.textSecondary.opacity(0.14))
                        .frame(width: 18, height: 10)
                    Text(verbatim: usualText)
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textSecondary)
                }
            }
        }
        .accessibilityHidden(true)
    }
}
