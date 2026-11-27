import SwiftUI
import StrandAnalytics
import StrandDesign

// MARK: - What the numbers mean
//
// The plain-language layer in front of `ScoringGuideView`. Every score and reading NOOP shows gets a
// one-line meaning a first-time wearer can act on, and a short paragraph behind a tap. The technical
// method (heart-rate-reserve zones, baselines, weightings) keeps its single home in `ScoringGuideView`;
// each score entry here links to it rather than repeating it.
//
// Reached from Simple mode's Today and More, from the full More list, and as a sheet from the score
// labels on the Simple Today. Copy is deliberately general: it explains what a number means and what to
// do with it, and never types in a threshold the analytics might change; a night count it does name is read
// from the gate itself (`Baselines`, `SimpleWelcome`), so the words move with the code.
//
// "Start here" (Design v6, step 6) opens "How to read NOOP" (`SimpleWelcomeSheet`), the guide's first row.

/// A group of entries in the guide, in display order.
enum PlainGuideGroup: String, CaseIterable, Identifiable {
    case scores
    case behindCharge
    case sleep
    case other
    case goodToKnow

    var id: String { rawValue }

    /// The group's overline label (rendered upper-case by `strandOverline`).
    var title: String {
        switch self {
        case .scores:       return String(localized: "Your three scores")
        case .behindCharge: return String(localized: "What's behind your Charge")
        case .sleep:        return String(localized: "Sleep")
        case .other:        return String(localized: "Other numbers")
        case .goodToKnow:   return String(localized: "Good to know")
        }
    }

    /// The entries in this group, in display order.
    var terms: [PlainGuideTerm] { PlainGuideTerm.allCases.filter { $0.group == self } }
}

/// One explained term. The raw value is a stable identifier used for deep links and tests.
enum PlainGuideTerm: String, CaseIterable, Identifiable {
    case charge
    case effort
    case rest
    case hrv
    case restingHeartRate
    case breathingRate
    case skinTemperature
    case bloodOxygen
    case sleepNeed
    /// Tonight's goal: the need plus catch-up, counted back from the wake time (`SimpleTonight`).
    case tonightGoal
    case sleepStages
    /// What the "Your day" card's verdict and suggested Effort range mean.
    case dayPlan
    /// Steps and active calories, each against the wearer's usual day.
    case activity
    case stress
    case heartRateZones
    case estimates
    case confidence
    /// What "normal for you", "usually" and "higher or lower than usual" mean.
    case normalRange
    case whoopDifference

    var id: String { rawValue }

    var group: PlainGuideGroup {
        switch self {
        case .charge, .effort, .rest:
            return .scores
        case .hrv, .restingHeartRate, .breathingRate, .skinTemperature, .bloodOxygen:
            return .behindCharge
        case .sleepNeed, .tonightGoal, .sleepStages:
            return .sleep
        case .dayPlan, .activity, .stress, .heartRateZones, .estimates:
            return .other
        case .confidence, .normalRange, .whoopDifference:
            return .goodToKnow
        }
    }

    /// The matching section of the technical scoring guide, for the three scores only.
    var scoringSection: ScoreSection? {
        switch self {
        case .charge: return .charge
        case .effort: return .effort
        case .rest:   return .rest
        default:      return nil
        }
    }

    /// SF Symbol, matching the icon the same metric uses elsewhere in the app.
    var icon: String {
        switch self {
        case .charge:           return "heart.circle.fill"
        case .effort:           return "flame.fill"
        case .rest:             return "moon.stars.fill"
        case .hrv:              return "waveform.path.ecg"
        case .restingHeartRate: return "heart.fill"
        case .breathingRate:    return "lungs.fill"
        case .skinTemperature:  return "thermometer.medium"
        case .bloodOxygen:      return "drop.fill"
        case .sleepNeed:        return "bed.double.fill"
        case .tonightGoal:      return "moon.fill"
        case .sleepStages:      return "moon.zzz.fill"
        case .dayPlan:          return "figure.run"
        case .activity:         return "shoeprints.fill"
        case .stress:           return "bolt.heart.fill"
        case .heartRateZones:   return "speedometer"
        case .estimates:        return "figure.walk"
        case .confidence:       return "checkmark.seal.fill"
        case .normalRange:      return "arrow.up.arrow.down"
        case .whoopDifference:  return "arrow.left.arrow.right"
        }
    }

    /// The tint the same metric uses on Today, so an entry reads as "that number".
    var tint: Color {
        switch self {
        case .charge:           return StrandPalette.chargeColor
        case .effort:           return StrandPalette.effortColor
        case .rest:             return StrandPalette.restColor
        case .hrv:              return StrandPalette.metricCyan
        case .restingHeartRate: return StrandPalette.metricRose
        case .breathingRate:    return StrandPalette.accent
        case .skinTemperature:  return StrandPalette.metricAmber
        case .bloodOxygen:      return StrandPalette.metricCyan
        case .sleepNeed:        return StrandPalette.restColor
        case .tonightGoal:      return StrandPalette.restColor
        case .sleepStages:      return StrandPalette.restColor
        case .dayPlan:          return StrandPalette.chargeColor
        case .activity:         return StrandPalette.chargeColor
        case .stress:           return StrandPalette.metricAmber
        case .heartRateZones:   return StrandPalette.effortColor
        case .estimates:        return StrandPalette.chargeColor
        case .confidence:       return StrandPalette.accent
        case .normalRange:      return StrandPalette.accent
        case .whoopDifference:  return StrandPalette.textSecondary
        }
    }

    var title: String {
        switch self {
        case .charge:           return String(localized: "Charge")
        case .effort:           return String(localized: "Effort")
        case .rest:             return String(localized: "Rest")
        case .hrv:              return String(localized: "Heart-rate variability (HRV)")
        case .restingHeartRate: return String(localized: "Resting heart rate")
        case .breathingRate:    return String(localized: "Breathing rate")
        case .skinTemperature:  return String(localized: "Skin temperature")
        case .bloodOxygen:      return String(localized: "Blood oxygen (SpO₂)")
        case .sleepNeed:        return String(localized: "Sleep need and sleep debt")
        case .tonightGoal:      return String(localized: "Tonight's goal")
        case .sleepStages:      return String(localized: "Sleep stages")
        case .dayPlan:          return String(localized: "Your day and suggested Effort")
        case .activity:         return String(localized: "Steps and active calories")
        case .stress:           return String(localized: "Stress")
        case .heartRateZones:   return String(localized: "Heart-rate zones")
        case .estimates:        return String(localized: "Estimates")
        case .confidence:       return String(localized: "How sure NOOP is")
        case .normalRange:      return String(localized: "Normal, higher or lower than usual")
        case .whoopDifference:  return String(localized: "Why NOOP doesn't match the WHOOP app")
        }
    }

    /// The name a wearer may already know the number by, or nil.
    var alsoCalled: String? {
        switch self {
        case .charge:        return String(localized: "Recovery")
        case .effort:        return String(localized: "Strain")
        case .rest:          return String(localized: "Sleep performance")
        case .breathingRate: return String(localized: "Respiratory rate")
        default:             return nil
        }
    }

    /// The one-line meaning shown while the entry is collapsed.
    var summary: String {
        switch self {
        case .charge:
            return String(localized: "How ready your body is today.")
        case .effort:
            return String(localized: "How hard your heart has worked today.")
        case .rest:
            return String(localized: "How well you slept last night.")
        case .hrv:
            return String(localized: "Tiny changes in the time between heartbeats. Higher than your normal is good.")
        case .restingHeartRate:
            return String(localized: "Your heart rate at rest, measured while you sleep. Lower than your normal is good.")
        case .breathingRate:
            return String(localized: "Breaths per minute while you sleep. It barely changes from night to night.")
        case .skinTemperature:
            return String(localized: "How warm your skin is overnight.")
        case .bloodOxygen:
            return String(localized: "How much oxygen your blood carries, estimated while you sleep.")
        case .sleepNeed:
            return String(localized: "How much sleep you need, and how far behind you are.")
        case .tonightGoal:
            return String(localized: "When to be asleep tonight, and how much sleep to aim for.")
        case .sleepStages:
            return String(localized: "Light, deep and REM sleep, plus short wake-ups.")
        case .dayPlan:
            return String(localized: "What today's numbers suggest you do, and how hard to go.")
        case .activity:
            return String(localized: "How much you've moved today, compared with your usual day.")
        case .stress:
            return String(localized: "How strained your body looks, from 0 to 3, judged from your heart readings.")
        case .heartRateZones:
            return String(localized: "Five bands of effort, from easy (zone 1) to all-out (zone 5).")
        case .estimates:
            return String(localized: "Steps, calories, fitness age, VO₂ max and Vitality are helpful guesses, not exact measurements.")
        case .confidence:
            return String(localized: "Why you see dashes or an early estimate in your first two weeks.")
        case .normalRange:
            return String(localized: "How NOOP decides whether a reading is normal for you.")
        case .whoopDifference:
            return String(localized: "Same ideas, different maths.")
        }
    }

    /// The short paragraph shown once the entry is expanded: what it is, what is good, what to do.
    var detail: String {
        switch self {
        case .charge:
            return String(localized: "A score from 0 to 100, worked out while you sleep. It mostly compares your heart-rate variability and resting heart rate with your own normal, and also looks at your sleep, breathing and skin temperature. Higher means more ready. On a low day, take it easier and get to bed earlier.")
        case .effort:
            return String(localized: "Counts workouts and everyday activity, from 0 to 100 (or 0 to 21 if you chose that scale in Settings). It only goes up during the day and starts fresh each day. There's no perfect number: aim higher when your Charge is good, and lower when it's low. A score near 100 is rare.")
        case .rest:
            return String(localized: "A score from 0 to 100. The biggest part is how long you slept compared with a full night. It also looks at how much of your time in bed was sleep, and how much was deep and REM sleep. A last small part, for regular bed and wake times, is not measured yet: every night gets half of it. Higher is better.")
        case .hrv:
            return String(localized: "Measured in milliseconds (ms) while you sleep. Everyone's normal is different, so only compare it with your own. Alcohol, late meals, stress, illness and hard training usually push it down for a night or two.")
        case .restingHeartRate:
            return String(localized: "Measured in beats per minute (bpm). A few beats above your normal can come from a hard day, alcohol, heat, stress or an illness starting. It usually drops slowly as your fitness improves.")
        case .breathingRate:
            return String(localized: "Most adults breathe about 12 to 20 times a minute at rest. Because it is so steady, a clear jump above your normal is worth noticing: it can be an early sign of illness.")
        case .skinTemperature:
            return String(localized: "NOOP shows it either as a temperature or as the change from your own normal. Small changes are normal. A rise that lasts a few nights can come with illness, heat or a hormonal cycle.")
        case .bloodOxygen:
            return String(localized: "Most healthy people read 95 percent or higher. Not every strap can measure it. A reading marked “strap estimate (unverified)” is a rough guide only. This is not a medical test.")
        case .sleepNeed:
            return String(localized: "Sleep need is the sleep NOOP aims for each night. It starts at the usual target for adults (experts recommend 7 to 9 hours a night) and goes up if you regularly sleep longer when you can. Sleep debt is sleep you've missed recently compared with that need. Paying it back takes a few longer or earlier nights, not one huge sleep.")
        case .tonightGoal:
            return String(localized: "Tonight's goal is your sleep need, plus a little extra when you're behind on sleep: at most \(SimpleDayPlan.catchUpCapMinutes) minutes a night, because built-up sleep debt is repaid over several nights, not in one. NOOP counts back from your wake time: the one your wind-down reminder uses if it's on, otherwise your usual wake time from your recent nights. Until it knows your wake time, it says how long to sleep instead. Get into bed a little earlier: falling asleep usually takes 10 to 20 minutes.")
        case .sleepStages:
            return String(localized: "Light sleep fills most of the night. Deep sleep is the most physically restoring and comes mostly early in the night. REM is dreaming sleep and comes more toward morning. Short wake-ups are normal. The strap estimates stages from heart rate and movement, so treat them as a guide, not a lab result.")
        case .dayPlan:
            return String(localized: "The headline of Your day and the sentence under it weigh your heart-rate variability, resting heart rate and breathing against your normal, plus how quickly your training has built up. The suggested Effort range comes from your Charge: a high Charge suggests a hard day, a middle one a moderate day, and a low one an easy day. The bar shows the range and how far today's Effort has got. It's a rule of thumb, not a target you must hit. The range is left out when today's Charge isn't ready yet, or when your Charge and your other signals point different ways; then go by the sentence.")
        case .activity:
            return String(localized: "Steps come from your strap or, if connected, Apple Health. Active calories are the energy you burn by moving, on top of what your body uses at rest, so they are far fewer than a whole day's calories. Both are estimates. Each bar is full at your usual day, the middle of your last 30 days, so a full bar means an ordinary day for you, not a goal. For health, more steps help up to about 8,000 to 10,000 a day for adults under 60, and 6,000 to 8,000 from 60; past that the benefit levels off.")
        case .stress:
            return String(localized: "The morning number compares the night's resting heart rate and HRV with the 30 days before: 1.5 is your normal, lower is calmer and higher is more strained. These are the readings behind your Charge too, so a high Charge usually comes with low stress. The line through the day is the part measured while you're awake; exercise raises your heart rate as well, so NOOP tries to leave workout time out. One high morning is common; several in a row are a sign to slow down.")
        case .heartRateZones:
            return String(localized: "They're worked out from your profile, such as your age. Time in higher zones adds more to your Effort.")
        case .estimates:
            return String(localized: "Steps and calories come from your strap or, if connected, from Apple Health. Fitness age, VO₂ max and Vitality are long-term fitness estimates that change slowly over weeks. Watch the direction, not the exact number.")
        case .confidence:
            return String(localized: "NOOP compares you with yourself, so it first needs nights of sleep with the strap. Your Rest score comes after your first night, your Charge after \(Baselines.minNightsSeed) nights and advice for your day after \(SimpleWelcome.adviceNights). After \(Baselines.minNightsTrust) nights NOOP knows your normal well; until then Today shows Getting to know you, and your Charge is an early estimate. If NOOP can't work out a score honestly, it shows a dash instead of guessing. When today's score isn't ready yet, you see the most recent one, with its date under the ring; it updates once your strap has synced last night's sleep. With Simple mode off, the same stages are called Calibrating, Building and Solid.")
        case .normalRange:
            return String(localized: "NOOP compares each reading with your own nights, not with other people, because healthy people differ a lot. Your normal range is where most of your own nights fall, weighted toward recent weeks, and “usually” gives your typical value. On a score's page, your usual range is the middle half of your last 30 days. Until NOOP has \(Baselines.minNightsTrust) nights of yours, it uses typical ranges for adults, which don't fit everyone. Higher or lower than usual isn't good or bad on its own, and one night outside your range is common. Several readings off together, or one off for a few nights in a row, is worth noticing: illness, poor sleep, alcohol, heat or hard training can all do it.")
        case .whoopDifference:
            return String(localized: "NOOP works everything out on your device using published science. WHOOP's own formulas are private, so NOOP's scores usually move the same way as WHOOP's but won't match exactly. Both are estimates from a wrist strap, not medical advice.")
        }
    }
}

/// The guide screen. Pushed (More, Today) it relies on the host's navigation bar; presented as a sheet,
/// pass `onClose` for a Done button. `initialTerm` opens with that entry already expanded.
struct PlainGuideView: View {
    var initialTerm: PlainGuideTerm? = nil
    var onClose: (() -> Void)? = nil

    @State private var expanded: Set<PlainGuideTerm>
    /// The technical scoring guide section presented from a score entry (nil = closed).
    @State private var scoringSection: ScoreSection?
    /// "How to read NOOP", presented from the "Start here" row.
    @State private var showsWelcome = false

    init(initialTerm: PlainGuideTerm? = nil, onClose: (() -> Void)? = nil) {
        self.initialTerm = initialTerm
        self.onClose = onClose
        _expanded = State(initialValue: initialTerm.map { [$0] } ?? [])
    }

    var body: some View {
        if let onClose {
            NavigationStack {
                content
                    .toolbar {
                        #if os(iOS)
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done", action: onClose)
                                .foregroundStyle(StrandPalette.accent)
                        }
                        #else
                        ToolbarItem {
                            Button("Done", action: onClose)
                                .foregroundStyle(StrandPalette.accent)
                        }
                        #endif
                    }
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    #endif
            }
            #if os(macOS)
            .frame(width: 560, height: 640)
            #endif
        } else {
            content
        }
    }

    private var content: some View {
        // Opened at one entry (a tapped label or pill), the guide also scrolls to it: the entries further
        // down would otherwise open expanded but off screen.
        ScrollViewReader { proxy in
            ScreenScaffold(title: "What the numbers mean",
                           subtitle: "Plain explanations of every score and reading. Tap one to learn more.",
                           topBackground: liquidScaffoldSky()) {
                startHere
                ForEach(PlainGuideGroup.allCases) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(group.title).strandOverline()
                        NoopCard(padding: 0) {
                            VStack(spacing: 0) {
                                ForEach(Array(group.terms.enumerated()), id: \.element) { index, term in
                                    entry(term).id(term)
                                    if index < group.terms.count - 1 {
                                        Rectangle()
                                            .fill(StrandPalette.hairline)
                                            .frame(height: NoopMetrics.hairlineWidth)
                                            .padding(.leading, 56)
                                    }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: NoopMetrics.cardRadius, style: .continuous))
                        }
                    }
                }
                Text("NOOP is not a medical device. If a reading worries you or you feel unwell, talk to a doctor.")
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
            .background(StrandPalette.surfaceBase.ignoresSafeArea())
            .sheet(item: $scoringSection) { section in
                ScoringGuideView(initialSection: section, onClose: { scoringSection = nil })
            }
            .onAppear {
                guard let term = initialTerm else { return }
                DispatchQueue.main.async { proxy.scrollTo(term, anchor: .top) }
            }
        }
    }

    /// The guide's first row: "How to read NOOP", the same sheet Today shows once in Simple mode.
    private var startHere: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Start here").strandOverline()
            NoopCard(padding: 0) {
                Button { showsWelcome = true } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(StrandPalette.accent)
                            .frame(width: 28, height: 28)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("How to read NOOP")
                                .font(StrandFont.headline)
                                .foregroundStyle(StrandPalette.textPrimary)
                            Text("The three scores, where to look each day, and your first two weeks.")
                                .font(StrandFont.subhead)
                                .foregroundStyle(StrandPalette.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(StrandPalette.textTertiary)
                            .padding(.top, 6)
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
            }
        }
        // On the row's own stack, not beside the scoring-guide sheet, so the two presentations never share a view.
        .sheet(isPresented: $showsWelcome) {
            SimpleWelcomeSheet(onClose: { showsWelcome = false })
        }
    }

    /// One collapsible entry: the icon, the name and its one-line meaning; tap to read the paragraph.
    private func entry(_ term: PlainGuideTerm) -> some View {
        let isOpen = expanded.contains(term)
        return VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.24)) {
                    if isOpen { expanded.remove(term) } else { expanded.insert(term) }
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: term.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(term.tint)
                        .frame(width: 28, height: 28)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(term.title)
                            .font(StrandFont.headline)
                            .foregroundStyle(StrandPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(term.summary)
                            .font(StrandFont.subhead)
                            .foregroundStyle(StrandPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(StrandPalette.textTertiary)
                        .rotationEffect(.degrees(isOpen ? 0 : -90))
                        .padding(.top, 6)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityValue(Text(isOpen ? String(localized: "Expanded") : String(localized: "Collapsed")))
            .accessibilityHint(Text(isOpen ? String(localized: "Double tap to collapse") : String(localized: "Double tap to expand")))

            if isOpen {
                VStack(alignment: .leading, spacing: 10) {
                    if let other = term.alsoCalled {
                        Text("Also called \(other)")
                            .font(StrandFont.caption.weight(.semibold))
                            .foregroundStyle(term.tint)
                    }
                    Text(term.detail)
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let section = term.scoringSection {
                        Button { scoringSection = section } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "function")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("How NOOP calculates it")
                                    .font(StrandFont.subhead.weight(.semibold))
                            }
                            .foregroundStyle(term.tint)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 40)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#if DEBUG
#Preview("What the numbers mean") {
    NavigationStack { PlainGuideView(initialTerm: .charge) }
}
#endif
