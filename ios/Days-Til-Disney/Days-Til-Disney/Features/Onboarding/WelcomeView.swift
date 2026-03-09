import SwiftUI

/// First-launch welcome screen shown after the splash animation.
/// Presents a magical castle backdrop with a CTA to create the user's first trip.
struct WelcomeView: View {
    /// Called when the user taps "Create Your First Trip" — the caller navigates to AddEditTripView.
    let onCreateTrip: () -> Void
    /// Called when the user taps the skip option — proceeds to HomeView without a trip.
    let onSkip: () -> Void

    @State private var castleOpacity: Double = 0
    @State private var castleOffset: CGFloat = 60
    @State private var contentOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Gradient background — Magic Kingdom blue palette matches the splash.
            LinearGradient(
                colors: [
                    Color(hex: "#0D2545"),
                    Color(hex: "#1A3A6B"),
                    Color(hex: "#2B5BA0"),
                    Color(hex: "#3A72C8")
                ],
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

                    Button(action: onSkip) {
                        Text("I'll do this later")
                            .font(DTDFont.body)
                            .foregroundStyle(.white.opacity(0.55))
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
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
    }

    private let points: [Point] = [
        Point(id: 0, x: -110, y: -40,  size: 16),
        Point(id: 1, x:  110, y: -55,  size: 11),
        Point(id: 2, x:  -75, y:  50,  size:  9),
        Point(id: 3, x:   90, y:  40,  size: 13),
        Point(id: 4, x:    0, y: -80,  size: 10),
        Point(id: 5, x: -130, y:  10,  size:  8),
        Point(id: 6, x:  125, y:   5,  size:  8),
    ]

    var body: some View {
        ZStack {
            ForEach(points) { point in
                Image(systemName: "sparkle")
                    .foregroundStyle(Color.magicSparkle)
                    .font(.system(size: point.size))
                    .offset(x: point.x, y: point.y)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView(onCreateTrip: {}, onSkip: {})
        .environment(\.parkThemeProvider, ParkThemeProvider.preview(park: .magicKingdom))
}
