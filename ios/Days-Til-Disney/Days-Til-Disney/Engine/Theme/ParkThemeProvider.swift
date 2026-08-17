import SwiftUI
import Observation

// MARK: - ParkThemeProvider

/// Observable holder for the app's currently active park identity. Injected via
/// environment so `HomeViewModel` / `TripDetailViewModel` can set the active park
/// when a trip becomes primary.
///
/// Toy Box redesign: this is now a **park-identity-only holder**. The former
/// time-of-day gradient/overlay surface (`richGradientColors`, `gradient`,
/// `refreshTimeOfDay`, the `TimeOfDay` engine) was removed — panels resolve their
/// colour directly from `park.colorPalette.panelColor(for:)`.
@Observable
final class ParkThemeProvider {
    private(set) var park: DisneyPark

    init(park: DisneyPark = .magicKingdom) {
        self.park = park
    }

    /// Switches the active park, e.g. when the user selects a primary trip.
    func setActivePark(_ park: DisneyPark) {
        self.park = park
    }
}

// MARK: - Preview helper

extension ParkThemeProvider {
    static func preview(park: DisneyPark = .magicKingdom) -> ParkThemeProvider {
        ParkThemeProvider(park: park)
    }
}
