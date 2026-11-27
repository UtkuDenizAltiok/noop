import SwiftUI
import StrandDesign

/// Runs the iPhone step calibration (`StepCalibration`) when NOOP comes to the front, at most once a day. Attached
/// once, at the iOS app's root. It reads only what the phone already counted; it never wakes anything.
struct StepCalibrationRunner: ViewModifier {
    @EnvironmentObject var repo: Repository
    @EnvironmentObject var profile: ProfileStore
    @EnvironmentObject var intelligence: IntelligenceEngine
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
        await StepCalibration.runIfDue(repo: repo, profile: profile, intelligence: intelligence)
    }
}

extension View {
    /// Calibrate the strap's step counter against the iPhone's pedometer once a day (`StepCalibrationRunner`).
    func calibratesStepsWithPhone() -> some View { modifier(StepCalibrationRunner()) }
}

/// The Settings rows for the step divisor: "Calibrate with my iPhone" (on by default), what it learned, and the
/// manual divisor when the switch is off.
struct StepCalibrationSettings: View {
    @EnvironmentObject var repo: Repository
    @EnvironmentObject var profile: ProfileStore
    @EnvironmentObject var intelligence: IntelligenceEngine
    @AppStorage(StepCalibration.enabledKey) private var enabled = true
    @State private var running = false
    @State private var lastRunFound: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: NoopMetrics.space2) {
            #if os(iOS)
            Toggle(isOn: $enabled) {
                Text("Calibrate steps with my iPhone")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textPrimary)
            }
            .tint(StrandPalette.accent)
            if enabled {
                Text(statusText)
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                NoopButton(running ? "Calibrating…" : "Calibrate now", systemImage: "figure.walk", kind: .secondary,
                           fullWidth: true) { calibrateNow() }
                    .disabled(running)
            }
            #endif
        }
    }

    private var statusText: String {
        if let result = StepCalibration.lastResult {
            let day = result.at > 0
                ? Date(timeIntervalSince1970: TimeInterval(result.at)).formatted(.dateTime.day().month(.abbreviated)) : ""
            return String(localized: "\(String(format: "%.2f", result.ticksPerStep)) strap ticks per step, learned from \(result.windows) quarter-hours of walking with your iPhone (\(day)). Your steps still come from the strap alone, all day, phone or not.")
        }
        if lastRunFound == false {
            return String(localized: "Not enough yet: NOOP needs about two hours of walking with your iPhone in a pocket over the last week, with the strap on. Until then it keeps the divisor below.")
        }
        return String(localized: "When you walk with your iPhone in a pocket, NOOP compares the two counts and learns how many strap ticks make one of your steps. Your steps still come from the strap alone, all day, phone or not. It needs Motion & Fitness access.")
    }

    private func calibrateNow() {
        running = true
        Task {
            let result = await StepCalibration.runIfDue(repo: repo, profile: profile, intelligence: intelligence,
                                                        force: true)
            lastRunFound = result != nil
            running = false
        }
    }
}
