import SwiftUI
import Observation

// MARK: - Concrete ParkTheme

/// A value type holding the resolved theme for a specific park at a specific time of day.
struct ResolvedParkTheme: ParkTheme {
    let park: DisneyPark
    let palette: ParkColorPalette
    let timeOfDay: TimeOfDay
}

// MARK: - ParkThemeProvider

/// Observable service that owns the currently active theme.
/// Inject via environment so all views react when the theme changes.
@Observable
final class ParkThemeProvider {
    private(set) var currentTheme: ResolvedParkTheme
    private let timeOfDayProvider: any TimeOfDayProviding

    init(
        park: DisneyPark = .magicKingdom,
        timeOfDayProvider: any TimeOfDayProviding = LiveTimeOfDayProvider()
    ) {
        self.timeOfDayProvider = timeOfDayProvider
        let timeOfDay = timeOfDayProvider.currentTimeOfDay
        self.currentTheme = ResolvedParkTheme(
            park: park,
            palette: park.colorPalette,
            timeOfDay: timeOfDay
        )
    }

    // MARK: - Mutations

    /// Switches the active park theme, e.g. when the user selects a trip.
    func setActivePark(_ park: DisneyPark) {
        let timeOfDay = timeOfDayProvider.currentTimeOfDay
        currentTheme = ResolvedParkTheme(
            park: park,
            palette: park.colorPalette,
            timeOfDay: timeOfDay
        )
    }

    /// Refreshes time-of-day without changing the park.
    /// Call this when the app foregrounds to keep gradients current.
    func refreshTimeOfDay() {
        let timeOfDay = timeOfDayProvider.currentTimeOfDay
        currentTheme = ResolvedParkTheme(
            park: currentTheme.park,
            palette: currentTheme.palette,
            timeOfDay: timeOfDay
        )
    }

    // MARK: - Convenience

    /// Rich 4-stop gradient with time-of-day overlay blended into each stop.
    /// The final stop always receives the strongest overlay effect for depth.
    var richGradientColors: [Color] {
        let palette = currentTheme.palette
        let timeOfDay = currentTheme.timeOfDay
        let base = palette.gradientStops
        return base.enumerated().map { index, color in
            // Apply progressively stronger overlay toward the bottom (higher index = bottom).
            let progress = Double(index) / Double(max(base.count - 1, 1))
            return applyTimeOfDayOverlay(to: color, timeOfDay: timeOfDay, progress: progress)
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: richGradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Private helpers

    /// Blends a time-of-day color tint into a base gradient stop.
    /// `progress` ranges 0 (top of screen) → 1 (bottom), so the overlay
    /// darkens the bottom of the screen more heavily for depth.
    private func applyTimeOfDayOverlay(to base: Color, timeOfDay: TimeOfDay, progress: Double) -> Color {
        switch timeOfDay {
        case .day:
            // Daytime: no overlay, pure park colors.
            return base

        case .dawn:
            // Dawn: warm golden-orange tint, lighter at top fading to full warmth at bottom.
            let strength = 0.18 + progress * 0.12
            return base.blended(with: Color(hex: "#FF9966"), strength: strength)

        case .dusk:
            // Dusk: orange-purple cinematic blend. Top stays warm, bottom turns purple.
            let warmStrength = 0.25 * (1 - progress)
            let purpleStrength = 0.30 * progress
            let warm = base.blended(with: Color(hex: "#FF6B35"), strength: warmStrength)
            return warm.blended(with: Color(hex: "#6B2FA0"), strength: purpleStrength)

        case .night:
            // Night: deep blue-black vignette darkens everything, strongest at bottom.
            let strength = 0.30 + progress * 0.35
            return base.blended(with: Color(hex: "#050A1E"), strength: strength)
        }
    }
}

// MARK: - Preview helper

extension ParkThemeProvider {
    static func preview(park: DisneyPark = .magicKingdom, timeOfDay: TimeOfDay = .day) -> ParkThemeProvider {
        let hour: Int
        switch timeOfDay {
        case .dawn:  hour = 6
        case .day:   hour = 12
        case .dusk:  hour = 18
        case .night: hour = 22
        }
        return ParkThemeProvider(
            park: park,
            timeOfDayProvider: FixedTimeOfDayProvider(hour: hour)
        )
    }
}
