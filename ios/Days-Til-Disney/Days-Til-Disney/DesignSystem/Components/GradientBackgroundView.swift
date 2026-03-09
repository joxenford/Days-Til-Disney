import SwiftUI

/// Full-screen animated gradient background driven by the active park theme.
/// Uses a 4-stop gradient keyed to each park's palette plus a time-of-day overlay,
/// and animates smoothly whenever the park or time of day changes.
struct GradientBackgroundView: View {
    @Environment(\.parkTheme) private var themeProvider

    var body: some View {
        LinearGradient(
            colors: themeProvider.richGradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.2), value: themeProvider.currentTheme.park)
        .animation(.easeInOut(duration: 2.0), value: themeProvider.currentTheme.timeOfDay)
    }
}

// MARK: - Star layer (night-time accent)

/// A field of stars that appear at dusk and reach full brightness at night.
/// Each star independently twinkles via a `TimelineView`-driven phase animation —
/// no manual timer management, no retain cycles.
struct StarFieldView: View {
    @Environment(\.parkTheme) private var themeProvider

    // Stars are deterministically generated so the layout is stable across re-renders.
    private struct Star: Identifiable {
        let id: Int
        let x: Double           // normalized 0–1 of screen width
        let y: Double           // normalized 0–0.72 of screen height (upper sky)
        let size: Double        // point diameter
        let twinklePhase: Double // radians offset so stars pulse at different times
        let twinkleSpeed: Double // seconds per twinkle cycle
        let baseBrightness: Double // 0.55–1.0: simulates apparent stellar magnitude
    }

    private let stars: [Star] = {
        var rng = SystemRandomNumberGenerator()
        return (0..<90).map { i in
            Star(
                id: i,
                x: Double.random(in: 0...1, using: &rng),
                y: Double.random(in: 0...0.72, using: &rng),
                size: Double.random(in: 1.4...3.6, using: &rng),
                twinklePhase: Double.random(in: 0...(2 * .pi), using: &rng),
                twinkleSpeed: Double.random(in: 1.8...4.2, using: &rng),
                baseBrightness: Double.random(in: 0.55...1.0, using: &rng)
            )
        }
    }()

    var body: some View {
        let fieldOpacity = themeProvider.currentTheme.timeOfDay.starOpacity

        // TimelineView updates the body on every animation frame — the right tool
        // for per-star twinkling without manual timers or @State clocks.
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: fieldOpacity == 0)) { timeline in
            // Derive a continuous phase from elapsed time since some epoch.
            let elapsed = timeline.date.timeIntervalSinceReferenceDate

            GeometryReader { geo in
                ForEach(stars) { star in
                    // Each star's brightness follows a sine wave at its own speed and phase.
                    let angle = (elapsed / star.twinkleSpeed) * 2 * .pi + star.twinklePhase
                    let twinkle = sin(angle) * 0.5 + 0.5  // maps to 0–1
                    let opacity = fieldOpacity * star.baseBrightness * (0.45 + twinkle * 0.55)

                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: geo.size.width  * star.x,
                            y: geo.size.height * star.y
                        )
                        .opacity(opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 2.0), value: fieldOpacity)
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

#Preview("Animal Kingdom - Dusk") {
    ZStack {
        GradientBackgroundView()
        StarFieldView()
    }
    .environment(\.parkTheme, ParkThemeProvider.preview(park: .animalKingdom, timeOfDay: .dusk))
}

#Preview("Hollywood Studios - Night") {
    ZStack {
        GradientBackgroundView()
        StarFieldView()
    }
    .environment(\.parkTheme, ParkThemeProvider.preview(park: .hollywoodStudios, timeOfDay: .night))
}

#Preview("EPCOT - Day") {
    GradientBackgroundView()
        .environment(\.parkTheme, ParkThemeProvider.preview(park: .epcot, timeOfDay: .day))
}
