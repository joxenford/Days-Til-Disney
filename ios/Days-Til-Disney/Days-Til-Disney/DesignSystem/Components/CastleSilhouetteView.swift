import SwiftUI

/// Displays the park-appropriate castle silhouette asset.
/// Falls back to a generic castle shape if the asset image is missing
/// (common during development before assets are added to the catalog).
struct CastleSilhouetteView: View {
    let park: DisneyPark
    var size: CGFloat = 200
    var color: Color = .white
    var opacity: Double = 0.15

    var body: some View {
        Group {
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
        .foregroundStyle(color)
        .opacity(opacity)
        .frame(width: size, height: size)
        .accessibilityHidden(true) // Decorative — the label text carries meaning.
        .animation(.easeInOut(duration: 0.8), value: park)
    }
}

// MARK: - Fallback shape

/// A simple programmatic castle silhouette for use during development.
private struct FallbackCastleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Base / walls
        path.addRect(CGRect(x: w * 0.2, y: h * 0.45, width: w * 0.6, height: h * 0.55))

        // Gate arch
        path.addArc(
            center: CGPoint(x: w * 0.5, y: h * 0.72),
            radius: w * 0.1,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addRect(CGRect(x: w * 0.4, y: h * 0.72, width: w * 0.2, height: h * 0.28))

        // Center tower
        path.addRect(CGRect(x: w * 0.38, y: h * 0.25, width: w * 0.24, height: h * 0.22))

        // Center spire
        path.move(to: CGPoint(x: w * 0.38, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.25))
        path.closeSubpath()

        // Left tower
        path.addRect(CGRect(x: w * 0.15, y: h * 0.35, width: w * 0.15, height: h * 0.12))
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.225, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.30, y: h * 0.35))
        path.closeSubpath()

        // Right tower
        path.addRect(CGRect(x: w * 0.70, y: h * 0.35, width: w * 0.15, height: h * 0.12))
        path.move(to: CGPoint(x: w * 0.70, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.775, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.35))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview("Castle Silhouettes") {
    ZStack {
        Color(hex: "#1A3A6B").ignoresSafeArea()
        VStack(spacing: 24) {
            CastleSilhouetteView(park: .magicKingdom, size: 160, color: .white, opacity: 0.8)
            Text("Magic Kingdom Castle")
                .foregroundStyle(.white)
                .font(DTDFont.label)
        }
    }
}
