import SwiftUI

/// The complete theming contract for a Disney park.
/// Views bind to a ParkTheme via environment; the theme engine swaps it reactively.
protocol ParkTheme {
    var park: DisneyPark { get }
    var palette: ParkColorPalette { get }
    var castleAssetName: String { get }
    var timeOfDay: TimeOfDay { get }

    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var textOnPrimary: Color { get }
}

// MARK: - Default implementations

extension ParkTheme {
    var castleAssetName: String { park.castleAssetName }
    var primaryColor: Color { palette.primary }
    var secondaryColor: Color { palette.secondary }
    var accentColor: Color { palette.accent }
    var textOnPrimary: Color { palette.textOnPrimary }
}

// MARK: - TimeOfDay

enum TimeOfDay: String, CaseIterable {
    case dawn
    case day
    case dusk
    case night

    /// Hour ranges (24h) for each period.
    static func current(hour: Int) -> TimeOfDay {
        switch hour {
        case 5..<8:   return .dawn
        case 8..<17:  return .day
        case 17..<20: return .dusk
        default:      return .night
        }
    }

    var displayName: String {
        switch self {
        case .dawn:  return "Dawn"
        case .day:   return "Day"
        case .dusk:  return "Dusk"
        case .night: return "Night"
        }
    }

    var overlayColor: Color {
        switch self {
        case .dawn:  return Color(hex: "#FF9966")
        case .day:   return .clear
        case .dusk:  return Color(hex: "#FF6B35")
        case .night: return Color(hex: "#1a1a2e")
        }
    }

    var overlayStrength: Double {
        switch self {
        case .dawn:  return 0.25
        case .day:   return 0.0
        case .dusk:  return 0.30
        case .night: return 0.45
        }
    }

    var starOpacity: Double {
        switch self {
        case .dawn:  return 0.1
        case .day:   return 0.0
        case .dusk:  return 0.15
        case .night: return 0.8
        }
    }
}
