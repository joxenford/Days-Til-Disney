import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {
    private let userPreferences: UserPreferences

    init(userPreferences: UserPreferences) {
        self.userPreferences = userPreferences
    }

    // Proxied bindings so Views don't hold a direct reference to preferences.
    var themeMode: UserPreferences.ThemeMode {
        get { userPreferences.themeMode }
        set { userPreferences.themeMode = newValue }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    static func make(from container: AppContainer) -> SettingsViewModel {
        SettingsViewModel(userPreferences: container.userPreferences)
    }
}
