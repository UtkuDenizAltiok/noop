import SwiftUI
import StrandDesign

// MARK: - Simple mode: the strap line
//
// A first-time wearer whose strap is not connected saw only an unlabelled icon in Today's header and a
// sentence in the heart-rate card, with no way to connect from the screen they were on (Design v6, W3). This
// line says it where the day starts and carries the way in.
//
// It is a leaf of its own: it observes the live state so a connect or a disconnect re-renders this line
// alone, never the whole Today. It draws nothing while the strap is connected, while another kind of device
// is the active one (the header control stays silent then too, #2208), and for the first moments after it
// appears, because every launch starts disconnected until the strap answers and a line that flashed on each
// launch would cry wolf.
//
// Step 6 adds the low-battery line: a strap that runs flat overnight records no night. There is deliberately no
// "not synced since" line. A connected strap syncs itself every few minutes, a strap that is not connected is
// already said above, and on a WHOOP 5.0 or MG the history sync can still be experimental
// (`LiveState.historySyncExperimental`), where such a line would be a false alarm every day.

/// Pure rules for the strap line and More's "My strap" row. Both read the strap's charge through
/// `LiquidTodayView.StrapBatteryDisplay`, the funnel Today's header ring draws from, so the three cannot disagree.
enum SimpleStrapStatus {
    /// Seconds the line waits after appearing before it may show: longer than an ordinary reconnect.
    static let settleSeconds: Double = 8

    /// True when the wearer should be told the strap is not connected.
    static func showsNotConnected(activeIsWhoop: Bool, connected: Bool, settled: Bool) -> Bool {
        activeIsWhoop && !connected && settled
    }

    /// The strap's charge as the header ring prints it, when it is at or below the level the low-battery
    /// notification fires at (`BatteryNotifier.BatteryAlertPolicy.lowThreshold`) and not charging; nil
    /// otherwise. A ring's own charge is not the strap's, so it never counts.
    static func lowBattery(_ display: LiquidTodayView.StrapBatteryDisplay) -> Int? {
        guard case .charge(let pct, let charging, let isRing) = display, !isRing, !charging else { return nil }
        let printed = Int(pct.rounded())
        return printed <= BatteryNotifier.BatteryAlertPolicy.lowThreshold ? printed : nil
    }

    /// The state More's "My strap" row says under its name.
    enum Caption: Equatable {
        case notConnected
        /// Connected, no charge reading yet.
        case connected
        case battery(percent: Int, charging: Bool)
    }

    /// The caption for the active strap, or nil while another kind of device is the active one (the header
    /// ring is not drawn then either, #2208).
    static func caption(_ display: LiquidTodayView.StrapBatteryDisplay) -> Caption? {
        switch display {
        case .offline: return .notConnected
        case .pending: return .connected
        case .charge(let pct, let charging, let isRing):
            return isRing ? nil : .battery(percent: Int(pct.rounded()), charging: charging)
        case .notActiveDevice: return nil
        }
    }
}

/// "Strap not connected" with a Connect button that opens Devices, or "Strap battery low". See the file note.
struct SimpleStrapLine: View {
    @EnvironmentObject var live: LiveState
    @EnvironmentObject var router: NavRouter
    /// False until `SimpleStrapStatus.settleSeconds` after the line appears.
    @State private var settled = false

    private var batteryDisplay: LiquidTodayView.StrapBatteryDisplay {
        .resolve(activeIsWhoop: live.activeIsWhoop, connected: live.connected, batteryPct: live.batteryPct,
                 charging: live.charging, ringPct: live.ouraBatteryPct,
                 ringCharging: live.ouraWearState == .charging)
    }

    var body: some View {
        // A stack rather than a Group: a Group with nothing in it has no view for `.task` to attach to, so the
        // settle wait would never start and the line could never appear.
        VStack(spacing: 0) {
            if let low = SimpleStrapStatus.lowBattery(batteryDisplay) {
                // A strap that runs flat overnight records no night, and the next morning has no Charge. The
                // same level the low-battery notification uses, so the line and the notification agree.
                HStack(spacing: 12) {
                    Image(systemName: "battery.25percent")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(StrandPalette.statusWarning)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Strap battery low: \(low)%")
                            .font(StrandFont.subhead.weight(.semibold))
                            .foregroundStyle(StrandPalette.textPrimary)
                        Text("Charge it soon so your next night is recorded.")
                            .font(StrandFont.footnote)
                            .foregroundStyle(StrandPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(NoopPanelSurface(tint: StrandPalette.statusWarning, cornerRadius: 22))
                .accessibilityElement(children: .combine)
                .padding(.bottom, NoopMetrics.space3)
            }
            if SimpleStrapStatus.showsNotConnected(activeIsWhoop: live.activeIsWhoop, connected: live.connected,
                                                   settled: settled) {
                HStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(StrandPalette.statusWarning)
                        .accessibilityHidden(true)
                    Text("Strap not connected")
                        .font(StrandFont.subhead.weight(.semibold))
                        .foregroundStyle(StrandPalette.textPrimary)
                    Spacer(minLength: 8)
                    Button { router.openDevices() } label: {
                        Text("Connect")
                            .font(StrandFont.subhead.weight(.semibold))
                            .foregroundStyle(StrandPalette.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Capsule().strokeBorder(StrandPalette.accent.opacity(0.4), lineWidth: 1))
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(NoopPanelSurface(tint: StrandPalette.statusWarning, cornerRadius: 22))
                // The gap to the scores card below, carried here so a hidden line leaves none.
                .padding(.bottom, NoopMetrics.space3)
            }
        }
        // One wait per appearance, then nothing: no timer runs while the line is shown or hidden.
        .task {
            try? await Task.sleep(nanoseconds: UInt64(SimpleStrapStatus.settleSeconds * 1_000_000_000))
            settled = true
        }
    }
}
