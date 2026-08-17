import SwiftUI
import SwiftData
import UserNotifications

@main
struct DaysTilDisneyApp: App {
    @State private var container: AppContainer = .shared

    init() {
        // Register the deep-link handler as the UNUserNotificationCenter delegate
        // before the first scene connects. This ensures cold-launch notification
        // responses are delivered to our handler rather than dropped.
        UNUserNotificationCenter.current().delegate = AppContainer.shared.notificationDeepLinkHandler
    }

    var body: some Scene {
        WindowGroup {
            AppNavigationRouter()
                .modelContainer(container.modelContainer)
                // Inject the container itself so child views can reach all dependencies.
                .environment(container)
                // Also inject common services individually for convenience.
                .environment(container.userPreferences)
                .environment(container.themeProvider)
                .environment(\.parkThemeProvider, container.themeProvider)
                .preferredColorScheme(container.userPreferences.colorScheme)
        }
    }
}
