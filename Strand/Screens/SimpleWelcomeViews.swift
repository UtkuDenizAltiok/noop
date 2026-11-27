import SwiftUI
import StrandAnalytics
import StrandDesign

// MARK: - Simple mode: the welcome (Design v6, step 6)
//
// "How to read NOOP", shown once when Today first appears in Simple mode and kept in the guide as "Start here",
// and "Getting to know you", the card on Today for the first two weeks. The rules, and every night count, are in
// `SimpleWelcome`; these views only say them.

extension SimpleWelcome.Milestone {
    /// The line the card and the welcome print for it, with the night count from the gate itself.
    var text: String {
        switch self {
        case .rest:
            return String(localized: "After your first night: your Rest score")
        case .charge:
            return String(localized: "After \(nights) nights: your Charge")
        case .advice:
            return String(localized: "After \(nights) nights: advice for your day")
        case .ownNormal:
            return String(localized: "After \(nights) nights: your readings compared with your own normal")
        }
    }
}

/// The milestone lines. On Today's card each carries a tick once reached; in the welcome sheet they are the plan
/// alone, so the card stays the one place that says how far NOOP has got.
struct SimpleWelcomeSteps: View {
    let steps: [SimpleWelcome.Step]
    /// True on Today's card: a tick for each step reached. False in the sheet: plain bullets.
    let showsProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(steps, id: \.milestone) { step in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    marker(step)
                        .accessibilityHidden(true)
                    Text(step.milestone.text)
                        .font(StrandFont.subhead)
                        .foregroundStyle(showsProgress && step.reached ? StrandPalette.textSecondary
                                                                       : StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
                .modifier(SimpleWelcomeStepValue(reached: showsProgress ? step.reached : nil))
            }
        }
    }

    @ViewBuilder
    private func marker(_ step: SimpleWelcome.Step) -> some View {
        if showsProgress {
            Image(systemName: step.reached ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(step.reached ? StrandPalette.statusPositive : StrandPalette.textTertiary)
        } else {
            Image(systemName: "circle.fill")
                .font(.system(size: 6, weight: .semibold))
                .foregroundStyle(StrandPalette.textTertiary)
                .frame(width: 14)
        }
    }
}

/// VoiceOver's "Done" / "Not yet" for a step on Today's card; nothing for the sheet's plain bullets.
private struct SimpleWelcomeStepValue: ViewModifier {
    let reached: Bool?

    func body(content: Content) -> some View {
        if let reached {
            content.accessibilityValue(Text(reached ? String(localized: "Done") : String(localized: "Not yet")))
        } else {
            content
        }
    }
}

/// "Getting to know you": the inside of Today's card for the first two weeks (Today draws the card around it).
/// It replaces the "Early estimate" line under the scores and the night count "Your day" used to carry: one
/// place says how far NOOP has got, from the one count every gate reads (`SimpleWelcome.learnedNights`).
struct SimpleGettingToKnowYou: View {
    let learnedNights: Int
    /// True while the Rest ring shows a score.
    let hasRest: Bool
    /// True while today's own Charge rests on a baseline NOOP does not fully trust yet
    /// (`SimpleDayPlan.earlyEstimateNights`), so the foot can say it is an early estimate.
    let chargeIsEarlyEstimate: Bool
    let onGuide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("Getting to know you")
                    .font(StrandFont.overline).tracking(1.6).textCase(.uppercase)
                    .foregroundStyle(StrandPalette.textSecondary)
                Spacer(minLength: 8)
                Button(action: onGuide) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(StrandPalette.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("What the numbers mean")
            }
            Text("\(learnedNights) of \(Baselines.minNightsTrust) nights so far")
                .font(StrandFont.headline)
                .foregroundStyle(StrandPalette.textPrimary)
            SimpleWelcomeSteps(steps: SimpleWelcome.steps(learnedNights: learnedNights, hasRest: hasRest),
                               showsProgress: true)
            Group {
                if chargeIsEarlyEstimate {
                    Text("Wear the strap to bed every night. Until then your Charge is an early estimate: it settles as NOOP learns your normal.")
                } else {
                    Text("Wear the strap to bed every night. Until NOOP has enough nights, it shows a dash instead of guessing.")
                }
            }
            .font(StrandFont.footnote)
            .foregroundStyle(StrandPalette.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// "How to read NOOP": the three scores, where to look each day, the first two weeks, and the WHOOP names.
/// Presented once over Today in Simple mode (`RootTabView`), and from the guide's "Start here" at any time. It
/// explains and reads no data: how far NOOP has got is said in one place only, Today's card.
struct SimpleWelcomeSheet: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .background { ScenicHeroBackground(domain: .charge, starCount: 28, fadesToBase: true) }
            Divider().overlay(StrandPalette.hairline)
            ScrollView {
                VStack(alignment: .leading, spacing: NoopMetrics.sectionGap) {
                    scoresCard
                    eachDayCard
                    firstWeeksCard
                    whoopCard
                    Text("NOOP is not a medical device. If you feel unwell, trust how you feel and talk to a doctor.")
                        .font(StrandFont.footnote)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                }
                .padding(20)
            }
            #if os(iOS)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            #endif
            Divider().overlay(StrandPalette.hairline)
            footer
        }
        #if os(macOS)
        .frame(width: 560, height: 640)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .noopSheetPresentation(largeFirst: true)
        #endif
        .background(StrandPalette.surfaceBase)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Start here").strandOverline()
                Text("How to read NOOP")
                    .font(StrandFont.rounded(26, weight: .bold))
                    .foregroundStyle(StrandPalette.textPrimary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(StrandPalette.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(20)
    }

    private var scoresCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Your three scores").strandOverline()
                Text("NOOP turns what your strap measures into three scores.")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                scoreRow(.charge, String(localized: "How ready your body is today, from 0 to 100. Worked out while you sleep."))
                scoreRow(.effort, String(localized: "How hard your heart has worked today. It climbs through the day."))
                scoreRow(.rest, String(localized: "How well you slept last night, from 0 to 100."))
            }
        }
    }

    /// One score: its ring colour and icon (the guide's), its name, and what it means.
    private func scoreRow(_ term: PlainGuideTerm, _ meaning: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: term.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(term.tint)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(term.title)
                    .font(StrandFont.headline)
                    .foregroundStyle(StrandPalette.textPrimary)
                Text(meaning)
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var eachDayCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Each day").strandOverline()
                line("sun.max.fill", String(localized: "Each morning, look at your Charge. Your day, just below it, says how hard to go."))
                line("moon.fill", String(localized: "Each evening, Tonight says when to be asleep."))
                line("hand.tap.fill", String(localized: "Tap a score to see what moved it, and an ⓘ to see what a card means."))
            }
        }
    }

    private func line(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(StrandPalette.accent)
                .frame(width: 18)
                .accessibilityHidden(true)
            Text(text)
                .font(StrandFont.subhead)
                .foregroundStyle(StrandPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var firstWeeksCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your first two weeks").strandOverline()
                Text("NOOP compares you with yourself, not with other people, so it first needs nights of sleep with the strap.")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                SimpleWelcomeSteps(steps: SimpleWelcome.steps(learnedNights: 0, hasRest: false),
                                   showsProgress: false)
                Text("Until then it shows a dash instead of guessing. While NOOP is still learning, Getting to know you on Today shows how far it has got.")
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var whoopCard: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("If you know the WHOOP app").strandOverline()
                Text("Charge is WHOOP's \(PlainGuideTerm.charge.alsoCalled ?? ""), Effort is its \(PlainGuideTerm.effort.alsoCalled ?? "") and Rest is its \(PlainGuideTerm.rest.alsoCalled ?? ""). NOOP works them out itself, on your phone, so they won't match WHOOP's exactly.")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                Text("Got it").frame(minWidth: 120).padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(StrandPalette.accent)
            .keyboardShortcut(.defaultAction)
        }
        .padding(16)
    }
}

#if DEBUG
#Preview("Getting to know you") {
    SimpleGettingToKnowYou(learnedNights: 5, hasRest: true, chargeIsEarlyEstimate: true, onGuide: {})
        .padding()
}
#endif
