import SwiftUI

/// Launch splash screen. Displays an animated castle with sparkle effects
/// then calls `onComplete` to transition to the home screen.
struct SplashView: View {
    let onComplete: () -> Void

    @State private var castleOpacity: Double = 0
    @State private var castleScale: Double = 0.6
    @State private var titleOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0
    @State private var sparkleScale: Double = 0.5

    var body: some View {
        ZStack {
            // Background gradient — use Magic Kingdom as the "cold start" theme.
            LinearGradient(
                colors: [
                    Color(hex: "#0D2545"),
                    Color(hex: "#1A3A6B"),
                    Color(hex: "#2B5BA0")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Castle silhouette
                CastleSilhouetteView(
                    park: .magicKingdom,
                    size: 220,
                    color: .white,
                    opacity: castleOpacity
                )
                .scaleEffect(castleScale)

                // Sparkle decoration
                SparkleDecoration()
                    .opacity(sparkleOpacity)
                    .scaleEffect(sparkleScale)

                // App title
                VStack(spacing: 8) {
                    Text("Days Til")
                        .font(DTDFont.displayMedium)
                        .foregroundStyle(Color.disneyGold)

                    Text("Disney")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                .opacity(titleOpacity)

                Spacer()
                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Days Til Disney, loading")
        .task {
            runAnimation()
            // Use Task.sleep instead of DispatchQueue.main.asyncAfter so the wait is
            // cancellable when the view disappears (e.g. if the user force-quits).
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            onComplete()
        }
    }

    // MARK: - Animation sequence

    private func runAnimation() {
        // 1. Castle rises
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            castleOpacity = 0.85
            castleScale = 1.0
        }

        // 2. Sparkles pop
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.4)) {
            sparkleOpacity = 1.0
            sparkleScale = 1.0
        }

        // 3. Title fades in
        withAnimation(.easeInOut(duration: 0.6).delay(0.7)) {
            titleOpacity = 1.0
        }

        // Transition timing is handled by the .task modifier using Task.sleep.
    }
}

// MARK: - Sparkle decoration

private struct SparkleDecoration: View {
    private struct SparklePoint: Identifiable {
        let id: Int
        /// Normalized offset from center: -1.0 to +1.0 relative to container half-width/height.
        let normalizedX: CGFloat
        let normalizedY: CGFloat
        let size: CGFloat
        let delay: Double
    }

    private let points: [SparklePoint] = [
        SparklePoint(id: 0, normalizedX: -0.80, normalizedY: -0.50, size: 14, delay: 0.0),
        SparklePoint(id: 1, normalizedX:  0.80, normalizedY: -0.75, size: 10, delay: 0.15),
        SparklePoint(id: 2, normalizedX: -0.50, normalizedY:  0.75, size:  8, delay: 0.30),
        SparklePoint(id: 3, normalizedX:  0.60, normalizedY:  0.625, size: 12, delay: 0.10),
        SparklePoint(id: 4, normalizedX:  0.00, normalizedY: -1.25, size:  9, delay: 0.20),
    ]

    var body: some View {
        GeometryReader { geo in
            let hw = geo.size.width / 2
            let hh = geo.size.height / 2
            ZStack {
                ForEach(points) { point in
                    Image(systemName: "sparkle")
                        .foregroundStyle(Color.magicSparkle)
                        .font(.system(size: point.size))
                        .offset(x: point.normalizedX * hw, y: point.normalizedY * hh)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 200, height: 80)
    }
}

// MARK: - Preview

#Preview {
    SplashView(onComplete: {})
}
