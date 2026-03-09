import Foundation
import UserNotifications
import Observation

/// Receives UNUserNotificationCenter delegate callbacks and surfaces the tapped
/// notification's trip ID to SwiftUI via `pendingTripID`.
///
/// Lifecycle:
///   - Warm launch (app in background/foreground): `userNotificationCenter(_:didReceive:withCompletionHandler:)`
///     fires immediately when the user taps the notification banner.
///   - Cold launch (app not running): iOS delivers the notification response via the
///     same delegate callback once the app finishes launching, provided this object is
///     set as the delegate before `application(_:didFinishLaunchingWithOptions:)` returns.
///     In a SwiftUI App lifecycle that means assigning the delegate in the `App` initialiser
///     or in `DaysTilDisneyApp`'s `init`, which runs before the first scene is connected.
///
/// Usage:
///   1. Hold a strong reference (e.g. in `AppContainer`).
///   2. Assign it as `UNUserNotificationCenter.current().delegate` at launch.
///   3. In SwiftUI, observe `pendingTripID` and push `.tripDetail(tripID:)` when non-nil,
///      then call `clearPendingTrip()` to reset.
@Observable
@MainActor
final class NotificationDeepLinkHandler: NSObject, UNUserNotificationCenterDelegate {

    // MARK: - State

    /// Set when the user taps a milestone notification. Observed by `AppNavigationRouter`
    /// to trigger deep-link navigation. Reset to `nil` after the route is pushed.
    private(set) var pendingTripID: UUID?

    // MARK: - Public interface

    /// Called by the router after it has consumed the pending trip ID and pushed the route.
    func clearPendingTrip() {
        pendingTripID = nil
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Called when the user taps a notification while the app is in the foreground,
    /// background, or after a cold launch.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }

        let userInfo = response.notification.request.content.userInfo
        guard
            let tripIDString = userInfo["tripID"] as? String,
            let tripID = UUID(uuidString: tripIDString)
        else { return }

        // Hop to MainActor to mutate @Observable state safely.
        Task { @MainActor in
            self.pendingTripID = tripID
        }
    }

    /// Called when a notification is delivered while the app is in the foreground.
    /// Show the banner so the user can tap it if they want to navigate.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
