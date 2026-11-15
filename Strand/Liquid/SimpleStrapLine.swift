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

/// Pure rule for when the strap line shows.
enum SimpleStrapStatus {
    /// Seconds the line waits after appearing before it may show: longer than an ordinary reconnect.
    static let settleSeconds: Double = 8

    /// True when the wearer should be told the strap is not connected.
    static func showsNotConnected(activeIsWhoop: Bool, connected: Bool, settled: Bool) -> Bool {
        activeIsWhoop && !connected && settled
    }
}

/// "Strap not connected" with a Connect button that opens Devices. See the file note.
struct SimpleStrapLine: View {
    @EnvironmentObject var live: LiveState
    @EnvironmentObject var router: NavRouter
    /// False until `SimpleStrapStatus.settleSeconds` after the line appears.
    @State private var settled = false

    var body: some View {
        // A stack rather than a Group: a Group with nothing in it has no view for `.task` to attach to, so the
        // settle wait would never start and the line could never appear.
        VStack(spacing: 0) {
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
