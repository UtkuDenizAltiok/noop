import SwiftUI
import StrandDesign

// MARK: - High heart rate warning: the screen
//
// One card, shown in two places (Automations, and its own screen from More and the Today row), bound to the same
// three settings keys, so the two places cannot disagree. The card itself watches nothing live: only its status
// line observes the running warning, and only the "Feel the buzz" button observes the strap link, each in its own
// small view, so a heart-rate tick redraws those lines and not the card.

/// The high heart rate warning's controls: the switch, the limit, the duration, and what it is doing now.
struct HighHRAlertCard: View {
    @AppStorage(HighHRAlertPrefs.enabledKey) private var enabled = HighHRAlertPrefs.defaultEnabled
    @AppStorage(HighHRAlertPrefs.thresholdKey) private var threshold = HighHRAlertPrefs.defaultThresholdBpm
    @AppStorage(HighHRAlertPrefs.windowKey) private var window = HighHRAlertPrefs.defaultWindowSec

    private var limitBpm: Int { HighHRAlertPrefs.clampedThreshold(threshold) }
    private var windowSec: Int { HighHRAlertPrefs.clampedWindow(window) }

    var body: some View {
        StrandCard(padding: 20, tint: StrandPalette.accent) {
            VStack(alignment: .leading, spacing: 16) {
                header
                Text("Your strap buzzes twice, every 5 seconds, while your heart rate stays above the limit you set. NOOP judges it on your average, so one odd reading can't set it off or stop it.")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 0) {
                    switchRow
                    rowDivider
                    stepperRow(label: String(localized: "Above"),
                               value: String(localized: "\(limitBpm) bpm"),
                               binding: $threshold, range: HighHRAlertPrefs.thresholdRange, step: 1)
                    rowDivider
                    stepperRow(label: String(localized: "For at least"),
                               value: HighHRAlertPrefs.durationText(windowSec),
                               binding: $window, range: HighHRAlertPrefs.windowRange,
                               step: HighHRAlertPrefs.windowStepSec)
                }
                Text(HighHRAlertCopy.summary(limitBpm: limitBpm, windowSec: windowSec))
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if enabled {
                    HighHRAlertStatusLine(windowSec: windowSec)
                }
                HighHRAlertBuzzButton()
                VStack(alignment: .leading, spacing: 8) {
                    note("Works while NOOP is open or running in the background with your strap connected. It can't warn you if you swipe NOOP away, turn Bluetooth off or leave the strap out of range.")
                    note("Each buzz uses a little strap battery, so switch the warning off when you don't need it.")
                    note("A training and pacing aid, not a medical alarm.")
                }
            }
        }
        .background(HighHRAlertSettingsRelay(enabled: enabled, threshold: threshold, window: window))
    }

    /// The same header as the other Automations cards: an "Automation" overline that says ON while it is on.
    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text("Automation").strandOverline()
                if enabled {
                    Text("ON").font(StrandFont.overline)
                        .tracking(StrandFont.overlineTracking)
                        .foregroundStyle(StrandPalette.accent)
                }
            }
            HStack(spacing: 10) {
                Image(systemName: "bell.and.waves.left.and.right")
                    .foregroundStyle(enabled ? StrandPalette.accent : StrandPalette.textSecondary)
                    .accessibilityHidden(true)
                Text("High heart rate warning").font(StrandFont.title2).foregroundStyle(StrandPalette.textPrimary)
            }
        }
    }

    private var switchRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Warn me").font(StrandFont.body).foregroundStyle(StrandPalette.textPrimary)
            Spacer()
            Toggle("", isOn: $enabled).labelsHidden().toggleStyle(.switch).tint(StrandPalette.accent)
                .accessibilityLabel(Text("Warn me"))
        }
        .frame(minHeight: 42).padding(.vertical, 4)
    }

    /// A label with its value and a native −/+ stepper, clamped to `range` and moved by `step`.
    private func stepperRow(label: String, value: String, binding: Binding<Int>,
                            range: ClosedRange<Int>, step: Int) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label).font(StrandFont.body).foregroundStyle(StrandPalette.textPrimary)
            Spacer()
            Text(value).font(StrandFont.bodyNumber).foregroundStyle(StrandPalette.textPrimary)
            Stepper("", value: binding, in: range, step: step).labelsHidden()
                .accessibilityLabel(Text(label))
                .accessibilityValue(Text(value))
        }
        .frame(minHeight: 42).padding(.vertical, 4)
    }

    private func note(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(StrandFont.footnote)
            .foregroundStyle(StrandPalette.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var rowDivider: some View {
        Rectangle().fill(StrandPalette.hairline).frame(height: 1).padding(.vertical, 4)
    }
}

/// The warning's own screen: the card on its own, from More and from the Today row.
struct HighHRAlertView: View {
    /// Set when the screen is presented as a sheet; adds a Done button that calls it.
    var onClose: (() -> Void)? = nil

    @ViewBuilder var body: some View {
        if let onClose {
            scaffold
                .toolbar {
                    ToolbarItem(placement: Self.doneButtonPlacement) {
                        Button("Done", action: onClose).foregroundStyle(StrandPalette.accent)
                    }
                }
        } else {
            scaffold
        }
    }

    private var scaffold: some View {
        ScreenScaffold(title: "Heart rate warning") {
            HighHRAlertCard()
        }
    }

    private static var doneButtonPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .confirmationAction
        #endif
    }
}

/// Today's reminder that the warning is on (so a forgotten warning doesn't buzz through a whole workout), one tap
/// from the switch. Renders nothing while the warning is off. Reads only the settings, nothing live.
struct HighHRAlertTodayRow: View {
    @AppStorage(HighHRAlertPrefs.enabledKey) private var enabled = HighHRAlertPrefs.defaultEnabled
    @AppStorage(HighHRAlertPrefs.thresholdKey) private var threshold = HighHRAlertPrefs.defaultThresholdBpm
    @AppStorage(HighHRAlertPrefs.windowKey) private var window = HighHRAlertPrefs.defaultWindowSec
    @State private var showingWarning = false

    var body: some View {
        // Kept (invisible) while its sheet is open: switching the warning off inside the sheet would otherwise
        // remove the row, and the sheet with it, under the wearer's finger. It goes once the sheet is closed.
        if enabled || showingWarning {
            Button {
                StrandHaptic.selection.play()
                showingWarning = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "bell.and.waves.left.and.right")
                        .font(StrandFont.headline)
                        .foregroundStyle(StrandPalette.accent)
                        .frame(width: 26, alignment: .center)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("High heart rate warning is on")
                            .font(StrandFont.body)
                            .foregroundStyle(StrandPalette.textPrimary)
                        Text(HighHRAlertCopy.todayDetail(limitBpm: HighHRAlertPrefs.clampedThreshold(threshold),
                                                         windowSec: HighHRAlertPrefs.clampedWindow(window)))
                            .font(StrandFont.caption)
                            .foregroundStyle(StrandPalette.textTertiary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(StrandFont.footnote.weight(.semibold))
                        .foregroundStyle(StrandPalette.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(NoopPanelSurface(cornerRadius: NoopMetrics.cardRadius))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .opacity(enabled ? 1 : 0)
            .accessibilityHidden(!enabled)
            .transition(.opacity)
            .sheet(isPresented: $showingWarning) {
                NavigationStack {
                    HighHRAlertView(onClose: { showingWarning = false })
                        .background(StrandPalette.surfaceBase.ignoresSafeArea())
                }
            }
        }
    }
}

/// The warning's sentences that carry a number, built in one place so the card, its status line and the Today row
/// word the same setting the same way (each duration through `HighHRAlertPrefs.durationText`).
enum HighHRAlertCopy {
    /// The card's summary of what the current settings do.
    static func summary(limitBpm: Int, windowSec: Int) -> String {
        let duration = HighHRAlertPrefs.durationText(windowSec)
        return String(localized: "Buzzes when your average heart rate over the last \(duration) is above \(limitBpm) bpm, and stops a few seconds after your heart rate drops back under it.")
    }

    /// The Today row's second line.
    static func todayDetail(limitBpm: Int, windowSec: Int) -> String {
        let duration = HighHRAlertPrefs.durationText(windowSec)
        return String(localized: "Above \(limitBpm) bpm for \(duration)")
    }

    /// The status line while the warning is on. `.off` reads as waiting: the switch is on by the time this shows,
    /// and the running warning catches up at its next reading.
    static func status(_ status: HighHRAlertMonitor.Status, windowSec: Int) -> String {
        let duration = HighHRAlertPrefs.durationText(windowSec)
        switch status {
        case .off, .waiting:
            return String(localized: "Waiting for a live heart rate from your strap.")
        case .measuring:
            return String(localized: "Measuring. The first warning can come after \(duration) of readings.")
        case .below(let average):
            return String(localized: "Watching. Your average over the last \(duration) is \(average) bpm.")
        case .alerting(let average, true):
            return String(localized: "Above your limit: average \(average) bpm. Your strap is buzzing.")
        case .alerting(_, false):
            return String(localized: "Above your limit, but NOOP can't reach your strap to buzz it right now.")
        }
    }
}

/// The status line: the one part of the card that watches the running warning.
private struct HighHRAlertStatusLine: View {
    let windowSec: Int
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HighHRAlertStatusText(monitor: model.highHRAlert, windowSec: windowSec)
    }
}

private struct HighHRAlertStatusText: View {
    @ObservedObject var monitor: HighHRAlertMonitor
    let windowSec: Int

    private var isAlerting: Bool {
        if case .alerting = monitor.status { return true }
        return false
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: isAlerting ? "exclamationmark.circle.fill" : "waveform.path.ecg")
                .font(StrandFont.footnote)
                .foregroundStyle(isAlerting ? StrandPalette.statusWarning : StrandPalette.accent)
                .accessibilityHidden(true)
            Text(HighHRAlertCopy.status(monitor.status, windowSec: windowSec))
                .font(StrandFont.footnote)
                .foregroundStyle(isAlerting ? StrandPalette.statusWarning : StrandPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// "Feel the buzz": one double buzz, offered only when the warning itself could buzz the strap (`AppModel.canBuzz`,
/// the same answer the warning's own buzz asks). Observes `live` so it follows the link coming and going.
private struct HighHRAlertBuzzButton: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var live: LiveState

    var body: some View {
        NoopButton("Feel the buzz", systemImage: "waveform.path", kind: .secondary, fullWidth: true) {
            model.buzz(loops: HighHRAlertEngine.buzzLoops)
        }
        .disabled(!model.canBuzz)
    }
}

/// Tells the running warning when the switch, the limit or the duration changes, so it can log the change and
/// start or stop at once. Zero size; it observes the model only to reach the warning.
private struct HighHRAlertSettingsRelay: View {
    let enabled: Bool
    let threshold: Int
    let window: Int
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .onChangeCompat(of: enabled) { _ in model.highHRAlert.settingsChanged() }
            .onChangeCompat(of: threshold) { _ in model.highHRAlert.settingsChanged() }
            .onChangeCompat(of: window) { _ in model.highHRAlert.settingsChanged() }
    }
}
