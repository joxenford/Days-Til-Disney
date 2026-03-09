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

/// Cinderella Castle–inspired silhouette optimized for clean readability.
/// Kept in sync with `WidgetFallbackCastleShape` in DaysTilDisneyWidget.swift.
private struct FallbackCastleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // Left wall.
        path.move(to: CGPoint(x: w * 0.13, y: h))
        path.addLine(to: CGPoint(x: w * 0.13, y: h * 0.65))

        // Left outer turret.
        path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.20, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.65))

        // Left peaked roofline.
        path.addLine(to: CGPoint(x: w * 0.29, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.31, y: h * 0.57))
        path.addLine(to: CGPoint(x: w * 0.33, y: h * 0.65))

        // Left secondary spire.
        path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.13))
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.65))

        // Central spire.
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.0))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.30))

        // Right secondary spire — slightly taller for asymmetry.
        path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.32))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.11))
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.32))
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.65))

        // Right peaked roofline.
        path.addLine(to: CGPoint(x: w * 0.67, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.69, y: h * 0.58))
        path.addLine(to: CGPoint(x: w * 0.71, y: h * 0.65))

        // Right outer turret — slightly wider for asymmetry.
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.80, y: h * 0.17))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.65))

        // Right wall.
        path.addLine(to: CGPoint(x: w * 0.87, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.87, y: h))

        // Gothic pointed arch gate.
        path.addLine(to: CGPoint(x: w * 0.60, y: h))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.75),
            control: CGPoint(x: w * 0.57, y: h * 0.80)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.40, y: h),
            control: CGPoint(x: w * 0.43, y: h * 0.80)
        )
        path.addLine(to: CGPoint(x: w * 0.13, y: h))

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
