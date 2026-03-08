import SwiftUI

/// Full-screen animated gradient background driven by the active park theme.
/// The gradient adapts to the current time of day and animates smoothly when
/// the park or time changes.
struct GradientBackgroundView: View {
    @Environment(\.parkTheme) private var themeProvider

    var body: some View {
        LinearGradient(
            colors: themeProvider.gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.2), value: themeProvider.currentTheme.park)
        .animation(.easeInOut(duration: 2.0), value: themeProvider.currentTheme.timeOfDay)
    }
}

// MARK: - Star layer (night-time accent)

struct StarFieldView: View {
    @Environment(\.parkTheme) private var themeProvider

    private let stars: [(x: Double, y: Double, size: Double)] = {
        var rng = SystemRandomNumberGenerator()
        return (0..<80).map { _ in
            (
                x: Double.random(in: 0...1, using: &rng),
                y: Double.random(in: 0...0.7, using: &rng),
                size: Double.random(in: 1.5...3.5, using: &rng)
            )
        }
    }()

    var body: some View {
        let opacity = themeProvider.currentTheme.timeOfDay.starOpacity
        GeometryReader { geo in
            ForEach(stars.indices, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: stars[i].size, height: stars[i].size)
                    .position(
                        x: geo.size.width * stars[i].x,
                        y: geo.size.height * stars[i].y
                    )
                    .opacity(opacity)
            }
        }
        .animation(.easeInOut(duration: 2.0), value: opacity)
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview("Magic Kingdom - Night") {
    ZStack {
        GradientBackgroundView()
        StarFieldView()
    }
    .environment(\.parkTheme, ParkThemeProvider.preview(park: .magicKingdom, timeOfDay: .night))
}

#Preview("Disneyland - Dawn") {
    GradientBackgroundView()
        .environment(\.parkTheme, ParkThemeProvider.preview(park: .disneyland, timeOfDay: .dawn))
}
