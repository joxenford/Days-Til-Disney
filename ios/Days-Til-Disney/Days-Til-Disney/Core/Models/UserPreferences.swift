import SwiftUI
import Observation

/// User-level preferences stored via AppStorage (UserDefaults).
/// Not a SwiftData model — preferences are simple scalar values that
/// don't need relational queries or migrations.
@Observable
final class UserPreferences {
    // MARK: - Stored properties backed by AppStorage

    private let defaults: UserDefaults

    var themeMode: ThemeMode {
        didSet { defaults.set(themeMode.rawValue, forKey: Keys.themeMode) }
    }

    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    var primaryTripID: UUID? {
        didSet {
            if let id = primaryTripID {
                defaults.set(id.uuidString, forKey: Keys.primaryTripID)
            } else {
                defaults.removeObject(forKey: Keys.primaryTripID)
            }
        }
    }

    /// Whether the user has opted into local milestone push notifications.
    /// Toggling this ON will trigger a permission request and schedule notifications
    /// for all existing trips. Toggling OFF cancels all pending notifications.
    var milestoneNotificationsEnabled: Bool {
        didSet { defaults.set(milestoneNotificationsEnabled, forKey: Keys.milestoneNotificationsEnabled) }
    }

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Load stored values or fall back to defaults.
        let rawTheme = defaults.string(forKey: Keys.themeMode) ?? ThemeMode.auto.rawValue
        self.themeMode = ThemeMode(rawValue: rawTheme) ?? .auto
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.milestoneNotificationsEnabled = defaults.bool(forKey: Keys.milestoneNotificationsEnabled)

        if let uuidString = defaults.string(forKey: Keys.primaryTripID),
           let uuid = UUID(uuidString: uuidString) {
            self.primaryTripID = uuid
        } else {
            self.primaryTripID = nil
        }
    }

    // MARK: - Computed

    var colorScheme: ColorScheme? {
        switch themeMode {
        case .auto:  return nil
        case .light: return .light
        case .dark:  return .dark
        }
    }

    // MARK: - Storage keys

    private enum Keys {
        static let themeMode                      = "userPrefs.themeMode"
        static let hasCompletedOnboarding         = "userPrefs.hasCompletedOnboarding"
        static let primaryTripID                  = "userPrefs.primaryTripID"
        static let milestoneNotificationsEnabled  = "userPrefs.milestoneNotificationsEnabled"
    }
}

// MARK: - ThemeMode

extension UserPreferences {
    enum ThemeMode: String, CaseIterable, Identifiable {
        case auto
        case light
        case dark

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .auto:  return "Automatic"
            case .light: return "Light"
            case .dark:  return "Dark"
            }
        }

        var systemImageName: String {
            switch self {
            case .auto:  return "circle.lefthalf.filled"
            case .light: return "sun.max.fill"
            case .dark:  return "moon.fill"
            }
        }
    }
}
