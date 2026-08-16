import SwiftUI

/// Displays the app's universal "Wish" hero mark — a four-point sparkle with a
/// tapering comet arc (a shooting star).
///
/// The mark can show a multi-layered glow effect that creates a sense of magic
/// and depth — the outer glow uses the park's accent color while the inner mark
/// stays crisp.
///
/// The mark is universal (identical for every park), so `park` no longer selects
/// artwork; it is retained only to drive the cross-fade animation at call sites
/// where the primary park can change.
struct HeroMarkView: View {
    let park: DisneyPark
    var size: CGFloat = 200
    var color: Color = .white
    var opacity: Double = 0.15
    /// When true, adds a soft colored glow behind the mark.
    var showGlow: Bool = false
    /// The color used for the glow effect. Falls back to `color` if nil.
    var glowColor: Color? = nil

    var body: some View {
        ZStack {
            if showGlow {
                // Outer diffuse glow — large and very soft.
                markShape
                    .foregroundStyle(glowColor ?? color)
                    .opacity(opacity * 0.35)
                    .blur(radius: size * 0.18)
                    .blendMode(.screen)

                // Inner tight glow — adds crisp luminance around the edges.
                markShape
                    .foregroundStyle(glowColor ?? color)
                    .opacity(opacity * 0.55)
                    .blur(radius: size * 0.06)
                    .blendMode(.screen)
            }

            // The crisp mark on top.
            markShape
                .foregroundStyle(color)
                .opacity(opacity)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true) // Decorative — the label text carries meaning.
        .animation(.easeInOut(duration: 0.8), value: park)
    }

    private var markShape: some View {
        WishStarShape()
    }
}

// MARK: - Wish mark shape

/// The "Wish" shooting-star mark: a four-point sparkle with a tapering comet arc.
/// Designed to read as original, stay clean at small sizes, and fill with a single
/// color so the glow/opacity layers in `HeroMarkView` work unchanged.
///
/// SYNC NOTE: This shape is intentionally duplicated in `WidgetWishStarShape` inside
/// `DaysTilDisneyWidget/DaysTilDisneyWidget.swift`. The widget extension cannot import
/// from the main app target, so both shapes must be maintained independently. If you
/// change the path coordinates here, update `WidgetWishStarShape` as well.
struct WishStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        WishStar.path(in: rect)
    }
}

/// Shared geometry for the Wish mark. Kept as a free function so the main app and the
/// widget copy can stay pixel-identical by copying one body.
enum WishStar {
    static func path(in rect: CGRect) -> Path {
        // Single continuous outline: a sparkle head (top / right / left tips) whose
        // lower-left arm is elongated into a tapering comet trail. One subpath, so the
        // head and trail merge with no overlap seams. (Coordinates tuned against a
        // rasterized preview at 200pt and 44pt — see the design handoff.)
        let w = rect.width
        let h = rect.height
        let m = min(w, h)
        var path = Path()

        let cx = w * 0.60
        let cy = h * 0.40
        let arm = m * 0.30    // top / right / left tip distance
        let waist = m * 0.085 // valley radius → sharp sparkle points

        let n    = CGPoint(x: cx,        y: cy - arm)
        let e    = CGPoint(x: cx + arm,  y: cy)
        let wl   = CGPoint(x: cx - arm,  y: cy)
        let tail = CGPoint(x: w * 0.10,  y: h * 0.92) // elongated lower-left arm

        // Valleys between consecutive tips (clockwise: N → E → tail → W → N).
        let vNE = CGPoint(x: cx + waist,       y: cy - waist)
        let vES = CGPoint(x: cx + waist,       y: cy + waist)       // between E and tail
        let vTW = CGPoint(x: cx - waist * 1.3, y: cy + waist * 0.7) // between tail and W
        let vWN = CGPoint(x: cx - waist,       y: cy - waist)

        path.move(to: n)
        path.addQuadCurve(to: e,    control: vNE)
        path.addQuadCurve(to: tail, control: vES) // long sweep out to the comet tip
        path.addQuadCurve(to: wl,   control: vTW) // back up to the left tip
        path.addQuadCurve(to: n,    control: vWN)
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview("Hero Mark — Sizes") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#12102E"), Color(hex: "#4C1D95")],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 32) {
                ForEach([200.0, 110.0, 70.0, 44.0], id: \.self) { s in
                    VStack(spacing: 8) {
                        HeroMarkView(
                            park: .magicKingdom,
                            size: s,
                            color: .white,
                            opacity: 0.9,
                            showGlow: true,
                            glowColor: Color(hex: "#FFC93C")
                        )
                        Text("\(Int(s))pt")
                            .foregroundStyle(.white)
                            .font(DTDFont.label)
                    }
                }
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview("Hero Mark — Glow") {
    ZStack {
        Color(hex: "#12102E").ignoresSafeArea()
        HeroMarkView(
            park: .magicKingdom,
            size: 200,
            color: .white,
            opacity: 0.85,
            showGlow: true,
            glowColor: Color(hex: "#FFC93C")
        )
    }
}
