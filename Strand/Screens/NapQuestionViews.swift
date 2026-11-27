import SwiftUI
import StrandDesign
import StrandAnalytics

/// Looks for naps to ask about when NOOP comes to the front (`NapQuestions`). Attached once, at the iOS root.
struct NapQuestionRunner: ViewModifier {
    @EnvironmentObject var repo: Repository
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .task { await run() }
            .onChangeCompat(of: scenePhase) { phase in
                if phase == .active { Task { await run() } }
            }
    }

    @MainActor
    private func run() async {
        guard scenePhase == .active else { return }
        await NapQuestions.runIfDue(repo: repo)
    }
}

extension View {
    /// Ask about likely naps on the Sleep tab (`NapQuestionRunner`).
    func asksAboutNaps() -> some View { modifier(NapQuestionRunner()) }
}

/// "Did you nap from 15:10 to 15:42?" on the Sleep tab, for the newest nap NOOP thinks it saw. Yes adds it as a
/// nap (the "Add a nap" path) and works the scores out again; No forgets it. Nothing is added without a Yes.
struct NapQuestionCard: View {
    @EnvironmentObject var repo: Repository
    @EnvironmentObject var intelligence: IntelligenceEngine
    @State private var question: NapCandidate?
    @State private var saving = false

    var body: some View {
        VStack(spacing: 0) {
            if let question {
                NoopCard(tint: StrandPalette.restColor) {
                    VStack(alignment: .leading, spacing: NoopMetrics.space2) {
                        Text("Did you nap from \(Night.clockString(question.start)) to \(Night.clockString(question.end))?")
                            .font(StrandFont.headline)
                            .foregroundStyle(StrandPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Your wrist was still and your heart rate settled then. A wrist cannot always tell quiet rest from sleep, so NOOP asks instead of guessing.")
                            .font(StrandFont.footnote)
                            .foregroundStyle(StrandPalette.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: NoopMetrics.space2) {
                            NoopButton("Yes, add it", systemImage: "checkmark", kind: .primary, fullWidth: true) {
                                answer(question, yes: true)
                            }
                            NoopButton("No", systemImage: "xmark", kind: .secondary, fullWidth: true) {
                                answer(question, yes: false)
                            }
                        }
                        .disabled(saving)
                    }
                }
            }
        }
        .task { question = NapQuestions.pending.last }
    }

    private func answer(_ c: NapCandidate, yes: Bool) {
        saving = true
        Task {
            if yes {
                await repo.addManualNap(startTs: c.start, endTs: c.end)
                await intelligence.analyzeRecent()
                await repo.refresh()
            }
            NapQuestions.markAnswered(c)
            question = NapQuestions.pending.last
            saving = false
        }
    }
}
