import SwiftUI

/// First-launch welcome screen shown after the splash animation.
/// Presents a magical castle backdrop with a CTA to create the user's first trip.
struct WelcomeView: View {
    /// Called when the user taps "Create Your First Trip" — the caller navigates to AddEditTripView.
    let onCreateTrip: () -> Void
    /// Called when the user taps the skip option — proceeds to HomeView without a trip.
    let onSkip: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var castleOpacity: Double = 0
    @State private var castleOffset: CGFloat = 60
    @State private var contentOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Gradient background — Magic Kingdom palette matches the splash screen.
            LinearGradient(
                colors: DisneyPark.magicKingdom.colorPalette.gradientStops,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Twinkling star field.
            StarFieldView()

            VStack(spacing: 0) {
                Spacer()

                // Castle hero.
                ZStack {
                    CastleSilhouetteView(
                        park: .magicKingdom,
                        size: 240,
                        color: .white,
                        opacity: castleOpacity,
                        showGlow: true,
                        glowColor: Color.magicSparkle
                    )
                    .offset(y: castleOffset)

                    // Sparkle constellation around the castle.
                    WelcomeSparkles()
                        .opacity(sparkleOpacity)
                        .accessibilityHidden(true)
                }
                .frame(height: 280)

                Spacer().frame(height: 40)

                // Headline and subtitle.
                VStack(spacing: 14) {
                    Text("Welcome to")
                        .font(DTDFont.titleSecondary)
                        .foregroundStyle(.white.opacity(0.85))

                    Text("Days 'Til Disney")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(Color.disneyGold)
                        .shadow(color: Color.disneyGold.opacity(0.4), radius: 8, y: 4)

                    Text("Start counting down to your\nmagical adventure")
                        .font(DTDFont.body)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(contentOpacity)

                Spacer().frame(height: 48)

                // CTA buttons.
                VStack(spacing: 16) {
                    Button(action: onCreateTrip) {
                        Label("Create Your First Trip", systemImage: "sparkles")
                            .font(DTDFont.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: .white.opacity(0.25), radius: 12, y: 6)
                    }
                    .accessibilityLabel("Create your first Disney trip")
                    .padding(.horizontal, 32)

                    // H-2: Minimum 44×44pt tap target + capsule background for visual affordance.
                    Button(action: onSkip) {
                        Text("I'll do this later")
                            .font(DTDFont.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.10))
                            )
                    }
                    .accessibilityLabel("Skip onboarding and go to home screen")
                }
                .opacity(contentOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear { runEntrance() }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Entrance animation

    private func runEntrance() {
        if reduceMotion {
            // Skip animations — show everything immediately.
            castleOpacity = 0.9
            castleOffset = 0
            sparkleOpacity = 1.0
            contentOpacity = 1.0
            return
        }

        // Castle rises from below.
        withAnimation(.spring(response: 0.9, dampingFraction: 0.72).delay(0.1)) {
            castleOpacity = 0.9
            castleOffset = 0
        }

        // Sparkles pop after castle settles.
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.55)) {
            sparkleOpacity = 1.0
        }

        // Text and buttons slide in.
        withAnimation(.easeOut(duration: 0.55).delay(0.65)) {
            contentOpacity = 1.0
        }
    }
}

// MARK: - Sparkle decoration

private struct WelcomeSparkles: View {
    private struct Point: Identifiable {
        let id: Int
        /// Normalized offset from center: -1.0 to +1.0 relative to container half-width/height.
        let normalizedX: CGFloat
        let normalizedY: CGFloat
        let size: CGFloat
    }

    private let points: [Point] = [
        Point(id: 0, normalizedX: -0.917, normalizedY: -0.286, size: 16),
        Point(id: 1, normalizedX:  0.917, normalizedY: -0.393, size: 11),
        Point(id: 2, normalizedX: -0.625, normalizedY:  0.357, size:  9),
        Point(id: 3, normalizedX:  0.750, normalizedY:  0.286, size: 13),
        Point(id: 4, normalizedX:  0.000, normalizedY: -0.571, size: 10),
        Point(id: 5, normalizedX: -1.083, normalizedY:  0.071, size:  8),
        Point(id: 6, normalizedX:  1.042, normalizedY:  0.036, size:  8),
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
    }
}

// MARK: - Preview

#Preview {
    WelcomeView(onCreateTrip: {}, onSkip: {})
        .environment(\.parkThemeProvider, ParkThemeProvider.preview(park: .magicKingdom))
}
