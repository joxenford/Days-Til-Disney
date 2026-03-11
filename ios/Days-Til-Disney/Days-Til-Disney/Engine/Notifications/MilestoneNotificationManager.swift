import Foundation
import UserNotifications

// MARK: - Trip snapshot

/// A Sendable snapshot of the Trip fields needed for notification scheduling.
/// Created on the MainActor before any async boundary is crossed, so the
/// non-Sendable Trip model is never passed between actors.
struct TripNotificationSnapshot: Sendable {
    let id: UUID
    let name: String
    let startDate: Date
    let primaryParkEmoji: String
    let primaryParkDisplayName: String
}

extension Trip {
    /// Captures the fields required for notification scheduling into a Sendable value type.
    var notificationSnapshot: TripNotificationSnapshot {
        TripNotificationSnapshot(
            id: id,
            name: name,
            startDate: startDate,
            primaryParkEmoji: primaryPark.emoji,
            primaryParkDisplayName: primaryPark.displayName
        )
    }
}

// MARK: - Protocol

/// Manages scheduling and cancellation of local milestone notifications for trips.
protocol MilestoneNotificationManager {
    /// Requests UNUserNotificationCenter authorization. Returns true if granted.
    func requestPermission() async -> Bool

    /// Returns the current authorization status without prompting.
    func authorizationStatus() async -> UNAuthorizationStatus

    /// Schedules (or reschedules) milestone notifications for a single trip.
    /// Only future milestones are scheduled; past ones are silently skipped.
    /// Existing notifications for this trip are replaced.
    func scheduleNotifications(for snapshot: TripNotificationSnapshot) async

    /// Schedules milestone notifications for every trip in the collection.
    func scheduleNotifications(forAll snapshots: [TripNotificationSnapshot]) async

    /// Cancels all pending milestone notifications for a trip.
    func cancelNotifications(for tripID: UUID)

    /// Cancels every milestone notification across all trips.
    func cancelAllNotifications()
}

// MARK: - Implementation

/// UNUserNotificationCenter-backed milestone notification manager.
/// All scheduling is idempotent: call `scheduleNotifications(for:)` after any
/// trip mutation and it will replace the old set of pending notifications.
final class DefaultMilestoneNotificationManager: MilestoneNotificationManager {
    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationCenter.notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    func scheduleNotifications(for snapshot: TripNotificationSnapshot) async {
        // Remove any previously scheduled notifications for this trip first.
        cancelNotifications(for: snapshot.id)

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else { return }

        let requests = buildRequests(for: snapshot)
        for request in requests {
            try? await notificationCenter.add(request)
        }
    }

    func scheduleNotifications(forAll snapshots: [TripNotificationSnapshot]) async {
        for snapshot in snapshots {
            await scheduleNotifications(for: snapshot)
        }
    }

    // MARK: - Cancellation

    func cancelNotifications(for tripID: UUID) {
        let identifiers = Milestone.all.map { notificationID(tripID: tripID, daysOut: $0.daysOut) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAllNotifications() {
        // Only remove notifications we own (identified by our prefix).
        // This callback executes on an arbitrary background thread managed by
        // UNUserNotificationCenter — no MainActor isolation required.
        // [weak self] is unnecessary: the closure is short-lived and the
        // notification center holds no strong reference to self.
        notificationCenter.getPendingNotificationRequests { [notificationCenter] requests in
            let ours = requests
                .filter { $0.identifier.hasPrefix(Self.notificationPrefix) }
                .map(\.identifier)
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ours)
        }
    }

    // MARK: - Private helpers

    private static let notificationPrefix = "dtd.milestone."

    private func notificationID(tripID: UUID, daysOut: Int) -> String {
        "\(Self.notificationPrefix)\(tripID.uuidString).\(daysOut)"
    }

    /// Builds UNNotificationRequest objects for each future milestone.
    private func buildRequests(for snapshot: TripNotificationSnapshot) -> [UNNotificationRequest] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tripStart = calendar.startOfDay(for: snapshot.startDate)

        return Milestone.all.compactMap { milestone in
            // Calculate the date on which this milestone fires (startDate - daysOut).
            guard let fireDate = calendar.date(
                byAdding: .day,
                value: -milestone.daysOut,
                to: tripStart
            ) else { return nil }

            // Skip milestones whose fire date is in the past or today
            // (the in-app celebration handles day-of triggers).
            guard fireDate > today else { return nil }

            let content = UNMutableNotificationContent()
            content.title = notificationTitle(for: milestone, snapshot: snapshot)
            content.body = notificationBody(for: milestone, snapshot: snapshot)
            content.sound = .default
            // Store the trip ID so the app can navigate on tap in the future.
            content.userInfo = [
                "tripID": snapshot.id.uuidString,
                "daysOut": milestone.daysOut
            ]

            // Fire at 9 AM on the milestone day.
            var components = calendar.dateComponents(
                [.year, .month, .day],
                from: fireDate
            )
            components.hour = 9
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            return UNNotificationRequest(
                identifier: notificationID(tripID: snapshot.id, daysOut: milestone.daysOut),
                content: content,
                trigger: trigger
            )
        }
    }

    // MARK: - Message copy

    private func notificationTitle(for milestone: Milestone, snapshot: TripNotificationSnapshot) -> String {
        let emoji = snapshot.primaryParkEmoji
        switch milestone.daysOut {
        case 100: return "\(emoji) 100 Days of Magic!"
        case 50:  return "\(emoji) 50 Days to Go!"
        case 30:  return "\(emoji) One Month Until Disney!"
        case 14:  return "\(emoji) Two Weeks Away!"
        case 7:   return "\(emoji) One Week Until the Magic!"
        case 3:   return "\(emoji) Almost There — 3 Days!"
        case 1:   return "\(emoji) Tomorrow's the Big Day!"
        default:  return "\(emoji) \(milestone.daysOut) Days to Disney!"
        }
    }

    private func notificationBody(for milestone: Milestone, snapshot: TripNotificationSnapshot) -> String {
        let parkName = snapshot.primaryParkDisplayName
        switch milestone.daysOut {
        case 100:
            return "Your \(snapshot.name) adventure starts in 100 days. Time to start dreaming!"
        case 50:
            return "Halfway to \(parkName)! Now's a great time to start planning dining and Lightning Lane."
        case 30:
            return "\(parkName) is just one month away. Start those packing lists!"
        case 14:
            return "Two weeks until \(snapshot.name)! The excitement is real. Check your reservations."
        case 7:
            return "Seven sleeps until \(parkName)! Time to start packing and charging the camera."
        case 3:
            return "Just 3 days until \(parkName)! Finish those last-minute preparations and rest up."
        case 1:
            return "One sleep left! Tomorrow you'll be at \(parkName). Sweet Disney dreams tonight!"
        default:
            return "\(milestone.daysOut) days until \(snapshot.name) at \(parkName). The magic is coming!"
        }
    }
}
