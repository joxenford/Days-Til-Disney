import Foundation
import Observation
import UserNotifications

@Observable
@MainActor
final class SettingsViewModel {
    private let userPreferences: UserPreferences
    private let notificationManager: any MilestoneNotificationManager
    private let tripRepository: any TripRepository

    // MARK: - Notification permission state

    /// Reflects whether the system denied (or restricted) notification permission,
    /// which means we should surface a link to Settings instead of a simple toggle.
    private(set) var notificationPermissionDenied: Bool = false

    init(
        userPreferences: UserPreferences,
        notificationManager: any MilestoneNotificationManager,
        tripRepository: any TripRepository
    ) {
        self.userPreferences = userPreferences
        self.notificationManager = notificationManager
        self.tripRepository = tripRepository
    }

    // MARK: - Lifecycle

    func onAppear() async {
        await refreshNotificationStatus()
    }

    // MARK: - Proxied preference bindings

    var themeMode: UserPreferences.ThemeMode {
        get { userPreferences.themeMode }
        set { userPreferences.themeMode = newValue }
    }

    var milestoneNotificationsEnabled: Bool {
        get { userPreferences.milestoneNotificationsEnabled }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Notification toggle

    /// Called when the user flips the milestone notifications toggle.
    func setMilestoneNotifications(enabled: Bool) async {
        if enabled {
            let granted = await notificationManager.requestPermission()
            if granted {
                userPreferences.milestoneNotificationsEnabled = true
                notificationPermissionDenied = false
                await scheduleNotificationsForAllTrips()
            } else {
                // Permission was denied — keep the preference off and surface the Settings link.
                userPreferences.milestoneNotificationsEnabled = false
                notificationPermissionDenied = true
            }
        } else {
            userPreferences.milestoneNotificationsEnabled = false
            notificationManager.cancelAllNotifications()
        }
    }

    // MARK: - Private

    private func refreshNotificationStatus() async {
        let status = await notificationManager.authorizationStatus()
        switch status {
        case .denied, .ephemeral:
            notificationPermissionDenied = true
            // If permission was revoked externally, keep the pref in sync.
            if userPreferences.milestoneNotificationsEnabled {
                userPreferences.milestoneNotificationsEnabled = false
            }
        case .authorized, .provisional:
            notificationPermissionDenied = false
        case .notDetermined:
            notificationPermissionDenied = false
        @unknown default:
            notificationPermissionDenied = false
        }
    }

    private func scheduleNotificationsForAllTrips() async {
        let trips = (try? await tripRepository.fetchAllTrips()) ?? []
        await notificationManager.scheduleNotifications(forAll: trips)
    }

    // MARK: - Factory

    static func make(from container: AppContainer) -> SettingsViewModel {
        SettingsViewModel(
            userPreferences: container.userPreferences,
            notificationManager: container.milestoneNotificationManager,
            tripRepository: container.tripRepository
        )
    }
}
