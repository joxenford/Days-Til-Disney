import SwiftUI

/// Displays the park-appropriate castle silhouette asset.
/// Falls back to a programmatic castle shape if the asset image is missing
/// (common during development before art assets are added to the catalog).
///
/// The silhouette can show a multi-layered glow effect that creates a sense
/// of magic and depth — the outer glow uses the park's accent color while
/// the inner silhouette stays crisp.
struct CastleSilhouetteView: View {
    let park: DisneyPark
    var size: CGFloat = 200
    var color: Color = .white
    var opacity: Double = 0.15
    /// When true, adds a soft colored glow behind the silhouette.
    var showGlow: Bool = false
    /// The color used for the glow effect. Falls back to `color` if nil.
    var glowColor: Color? = nil

    var body: some View {
        ZStack {
            if showGlow {
                // Outer diffuse glow — large and very soft.
                silhouetteShape
                    .foregroundStyle(glowColor ?? color)
                    .opacity(opacity * 0.35)
                    .blur(radius: size * 0.18)
                    .blendMode(.screen)

                // Inner tight glow — adds crisp luminance around the edges.
                silhouetteShape
                    .foregroundStyle(glowColor ?? color)
                    .opacity(opacity * 0.55)
                    .blur(radius: size * 0.06)
                    .blendMode(.screen)
            }

            // The crisp silhouette on top.
            silhouetteShape
                .foregroundStyle(color)
                .opacity(opacity)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true) // Decorative — the label text carries meaning.
        .animation(.easeInOut(duration: 0.8), value: park)
    }

    @ViewBuilder
    private var silhouetteShape: some View {
        if let _ = UIImage(named: park.castleAssetName) {
            Image(park.castleAssetName)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
        } else {
            // Programmatic fallback silhouette until art assets are added.
            FallbackCastleShape()
        }
    }
}

// MARK: - Fallback shape

/// A programmatic castle silhouette with a Cinderella-style profile:
/// three towers with pointed spires, a grand arched gate, and crenellations on the walls.
private struct FallbackCastleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // ── Main walls ──────────────────────────────────────────────────────
        path.addRect(CGRect(x: w * 0.18, y: h * 0.44, width: w * 0.64, height: h * 0.56))

        // Crenellations across the wall top (left section).
        for col in 0..<3 {
            let x = w * 0.18 + CGFloat(col) * w * 0.095
            path.addRect(CGRect(x: x, y: h * 0.38, width: w * 0.055, height: h * 0.07))
        }
        // Crenellations (right section).
        for col in 0..<3 {
            let x = w * 0.605 + CGFloat(col) * w * 0.095
            path.addRect(CGRect(x: x, y: h * 0.38, width: w * 0.055, height: h * 0.07))
        }

        // ── Gate arch ───────────────────────────────────────────────────────
        // Semi-circular arch
        path.addArc(
            center: CGPoint(x: w * 0.5, y: h * 0.71),
            radius: w * 0.115,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Rectangular base of gate passage
        path.addRect(CGRect(x: w * 0.385, y: h * 0.71, width: w * 0.23, height: h * 0.29))

        // ── Center tower ────────────────────────────────────────────────────
        path.addRect(CGRect(x: w * 0.365, y: h * 0.24, width: w * 0.27, height: h * 0.22))
        // Center spire (tall, elegant)
        path.move(to: CGPoint(x: w * 0.365, y: h * 0.24))
        path.addLine(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.635, y: h * 0.24))
        path.closeSubpath()
        // Crenellations on center tower top
        for col in 0..<4 {
            let x = w * 0.365 + CGFloat(col) * w * 0.065
            path.addRect(CGRect(x: x, y: h * 0.19, width: w * 0.04, height: h * 0.06))
        }

        // ── Left tower ──────────────────────────────────────────────────────
        path.addRect(CGRect(x: w * 0.10, y: h * 0.34, width: w * 0.17, height: h * 0.12))
        path.move(to: CGPoint(x: w * 0.10, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.185, y: h * 0.10))
        path.addLine(to: CGPoint(x: w * 0.27, y: h * 0.34))
        path.closeSubpath()

        // ── Right tower ─────────────────────────────────────────────────────
        path.addRect(CGRect(x: w * 0.73, y: h * 0.34, width: w * 0.17, height: h * 0.12))
        path.move(to: CGPoint(x: w * 0.73, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.815, y: h * 0.10))
        path.addLine(to: CGPoint(x: w * 0.90, y: h * 0.34))
        path.closeSubpath()

        // ── Small flanking turrets ───────────────────────────────────────────
        // Left turret (between left tower and main walls)
        path.addRect(CGRect(x: w * 0.24, y: h * 0.40, width: w * 0.10, height: h * 0.06))
        path.move(to: CGPoint(x: w * 0.24, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.29, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.34, y: h * 0.40))
        path.closeSubpath()

        // Right turret
        path.addRect(CGRect(x: w * 0.66, y: h * 0.40, width: w * 0.10, height: h * 0.06))
        path.move(to: CGPoint(x: w * 0.66, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.71, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.40))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview("Castle Silhouettes — All Parks") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#0D2545"), Color(hex: "#2B5BA0")],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 32) {
                ForEach([
                    DisneyPark.magicKingdom,
                    .disneyland,
                    .epcot,
                    .hollywoodStudios,
                    .animalKingdom,
                ], id: \.self) { park in
                    VStack(spacing: 8) {
                        CastleSilhouetteView(
                            park: park,
                            size: 140,
                            color: .white,
                            opacity: 0.9,
                            showGlow: true,
                            glowColor: Color.magicSparkle
                        )
                        Text(park.displayName)
                            .foregroundStyle(.white)
                            .font(DTDFont.label)
                    }
                }
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview("Castle with Glow") {
    ZStack {
        Color(hex: "#0D2545").ignoresSafeArea()
        CastleSilhouetteView(
            park: .magicKingdom,
            size: 200,
            color: .white,
            opacity: 0.85,
            showGlow: true,
            glowColor: Color.magicSparkle
        )
    }
}
