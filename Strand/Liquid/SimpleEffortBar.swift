import SwiftUI
import StrandDesign

/// Simple mode's suggested-Effort bar: the whole Effort scale as a thin track, today's Effort so far
/// filled from the left, and the suggested range drawn as a taller outline over both, so the range stays
/// readable once the fill reaches into it. The outline uses the Charge colour because the range comes
/// from Charge; the fill uses the Effort colour because it is today's Effort. Drawn still (no timeline or
/// animation), and hidden from VoiceOver because the card's text beside it says the same figures in words.
struct SimpleEffortBar: View {
    /// Today's Effort on the display scale, or nil before any is measured (no fill is drawn).
    let value: Double?
    /// The suggested range on the same scale.
    let band: ClosedRange<Int>
    /// The top of the display scale (100, or 21 on the WHOOP-style scale).
    let maxValue: Double

    private static let trackHeight: CGFloat = 8
    private static let markerHeight: CGFloat = 18

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let low = position(Double(band.lowerBound), width: width)
            let markerWidth = max(Self.markerHeight, position(Double(band.upperBound), width: width) - low)
            ZStack(alignment: .leading) {
                Capsule().fill(StrandPalette.surfaceInset)
                    .frame(height: Self.trackHeight)
                if let value, value > 0 {
                    Capsule()
                        .fill(StrandPalette.effortColor)
                        .frame(width: max(Self.trackHeight, position(value, width: width)), height: Self.trackHeight)
                }
                RoundedRectangle(cornerRadius: Self.markerHeight / 2)
                    .fill(StrandPalette.chargeColor.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: Self.markerHeight / 2)
                        .strokeBorder(StrandPalette.chargeColor, lineWidth: 2))
                    .frame(width: markerWidth, height: Self.markerHeight)
                    .offset(x: low)
            }
            .frame(height: Self.markerHeight)
        }
        .frame(height: Self.markerHeight)
        .accessibilityHidden(true)
    }

    /// The x position of a value on the track, clamped to the track.
    private func position(_ value: Double, width: CGFloat) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(min(1, max(0, value / maxValue))) * width
    }
}
