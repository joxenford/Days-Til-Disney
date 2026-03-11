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

    // MARK: - iCloud sync state

    /// The current iCloud account status, used to render the sync indicator in Settings.
    private(set) var iCloudSyncStatus: ICloudSyncStatus = .unknown

    enum ICloudSyncStatus {
        /// Not yet checked.
        case unknown
        /// The user is signed in to iCloud — sync is active.
        case active
        /// The user is not signed in to iCloud — sync is unavailable.
        case notSignedIn

        var displayTitle: String {
            switch self {
            case .unknown:    return "Checking..."
            case .active:     return "On"
            case .notSignedIn: return "Sign in to iCloud to sync"
            }
        }

        var systemImage: String {
            switch self {
            case .unknown:    return "icloud"
            case .active:     return "icloud.fill"
            case .notSignedIn: return "icloud.slash"
            }
        }

        var isActive: Bool { self == .active }
    }

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
        refreshICloudStatus()
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
        case .denied:
            notificationPermissionDenied = true
            // If permission was revoked externally, keep the pref in sync.
            if userPreferences.milestoneNotificationsEnabled {
                userPreferences.milestoneNotificationsEnabled = false
            }
        case .authorized, .provisional, .ephemeral:
            notificationPermissionDenied = false
        case .notDetermined:
            notificationPermissionDenied = false
        @unknown default:
            notificationPermissionDenied = false
        }
    }

    private func scheduleNotificationsForAllTrips() async {
        let trips = (try? await tripRepository.fetchAllTrips()) ?? []
        await notificationManager.scheduleNotifications(forAll: trips.map(\.notificationSnapshot))
    }

    /// Checks whether the user is signed in to iCloud by inspecting the
    /// ubiquity identity token. This is synchronous and cheap — no network call.
    private func refreshICloudStatus() {
        let token = FileManager.default.ubiquityIdentityToken
        iCloudSyncStatus = token != nil ? .active : .notSignedIn
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
