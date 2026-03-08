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

    var gradientColors: [Color] {
        [currentTheme.effectiveGradientStart, currentTheme.effectiveGradientEnd]
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
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
