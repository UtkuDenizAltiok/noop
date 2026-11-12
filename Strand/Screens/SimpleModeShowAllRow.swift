import SwiftUI
import StrandDesign

/// The last row of every screen Simple mode simplifies (Today, Sleep, Trends, Stress, Health, Workouts):
/// "Show everything on this screen" switches that one screen to its full layout, with every card and tool
/// the full view has, and "Back to the simple view" returns it. A hidden card or tool is therefore one tap
/// away where the wearer is, never only behind the app-wide Simple mode switch.
///
/// Each screen owns its `showingAll` state and reads it through `SimpleModePrefs.isSimple`. The choice is
/// never stored and never reset on leaving the screen: a reset on disappear would also fire when a detail
/// screen is pushed, and the wearer would come back to a different layout. It lasts until tapped back or
/// the app restarts. Screens render this row only while the stored switch is on, so the full view (Simple
/// mode off) never shows it.
///
/// Drawn like the "All features" row in Simple mode's More list: an accent icon, a body-size title with a
/// caption under it, and a trailing chevron, on the standard panel surface.
struct SimpleModeShowAllRow: View {
    @Binding var showingAll: Bool
    @Environment(\.scrollScreenToTop) private var scrollScreenToTop

    var body: some View {
        Button {
            // "Back to the simple view" makes the page much shorter while the wearer is at its foot. A lazily
            // built page (Sleep, Trends, Stress, Health, Workouts) kept the old scroll position and showed
            // only empty space until the wearer scrolled up. So the screen returns to its top first, then
            // switches: the wearer sees the simple view from its start.
            if showingAll { scrollScreenToTop() }
            showingAll.toggle()
        } label: {
            label
        }
        .buttonStyle(.plain)
    }

    private var label: some View {
        HStack(spacing: NoopMetrics.space3) {
            Image(systemName: showingAll ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                .font(StrandFont.headline)
                .foregroundStyle(StrandPalette.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: NoopMetrics.spaceHalf) {
                if showingAll {
                    Text("Back to the simple view")
                        .font(StrandFont.body)
                        .foregroundStyle(StrandPalette.textPrimary)
                } else {
                    Text("Show everything on this screen")
                        .font(StrandFont.body)
                        .foregroundStyle(StrandPalette.textPrimary)
                    Text("The full version, with every card and tool.")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                }
            }
            Spacer(minLength: NoopMetrics.space2)
            Image(systemName: showingAll ? "chevron.up" : "chevron.down")
                .font(StrandFont.footnote.weight(.semibold))
                .foregroundStyle(StrandPalette.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, NoopMetrics.space4)
        .padding(.vertical, NoopMetrics.space3)
        .frame(minHeight: NoopMetrics.controlHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NoopPanelSurface(cornerRadius: NoopMetrics.cardRadius))
        .contentShape(Rectangle())
    }
}
