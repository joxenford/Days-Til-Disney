import Foundation
import UserNotifications

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
    func scheduleNotifications(for trip: Trip) async

    /// Schedules milestone notifications for every trip in the collection.
    func scheduleNotifications(forAll trips: [Trip]) async

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

    func scheduleNotifications(for trip: Trip) async {
        // Remove any previously scheduled notifications for this trip first.
        cancelNotifications(for: trip.id)

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else { return }

        let requests = buildRequests(for: trip)
        for request in requests {
            try? await notificationCenter.add(request)
        }
    }

    func scheduleNotifications(forAll trips: [Trip]) async {
        for trip in trips {
            await scheduleNotifications(for: trip)
        }
    }

    // MARK: - Cancellation

    func cancelNotifications(for tripID: UUID) {
        let identifiers = Milestone.all.map { notificationID(tripID: tripID, daysOut: $0.daysOut) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAllNotifications() {
        // Only remove notifications we own (identified by our prefix).
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let ours = requests
                .filter { $0.identifier.hasPrefix(Self.notificationPrefix) }
                .map(\.identifier)
            self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: ours)
        }
    }

    // MARK: - Private helpers

    private static let notificationPrefix = "dtd.milestone."

    private func notificationID(tripID: UUID, daysOut: Int) -> String {
        "\(Self.notificationPrefix)\(tripID.uuidString).\(daysOut)"
    }

    /// Builds UNNotificationRequest objects for each future milestone.
    private func buildRequests(for trip: Trip) -> [UNNotificationRequest] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tripStart = calendar.startOfDay(for: trip.startDate)

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
            content.title = notificationTitle(for: milestone, trip: trip)
            content.body = notificationBody(for: milestone, trip: trip)
            content.sound = .default
            // Store the trip ID so the app can navigate on tap in the future.
            content.userInfo = [
                "tripID": trip.id.uuidString,
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
                identifier: notificationID(tripID: trip.id, daysOut: milestone.daysOut),
                content: content,
                trigger: trigger
            )
        }
    }

    // MARK: - Message copy

    private func notificationTitle(for milestone: Milestone, trip: Trip) -> String {
        let emoji = trip.primaryPark.emoji
        switch milestone.daysOut {
        case 100: return "\(emoji) 100 Days of Magic!"
        case 50:  return "\(emoji) 50 Days to Go!"
        case 30:  return "\(emoji) One Month Until Disney!"
        case 14:  return "\(emoji) Two Weeks Away!"
        case 7:   return "\(emoji) One Week Until the Magic!"
        case 3:   return "\(emoji) Almost There — 3 Days!"
        case 1:   return "\(emoji) Tomorrow's the Big Day!"
        case 0:   return "\(emoji) TODAY IS THE DAY!"
        default:  return "\(emoji) \(milestone.daysOut) Days to Disney!"
        }
    }

    private func notificationBody(for milestone: Milestone, trip: Trip) -> String {
        let parkName = trip.primaryPark.displayName
        switch milestone.daysOut {
        case 100:
            return "Your \(trip.name) adventure starts in 100 days. Time to start dreaming!"
        case 50:
            return "Halfway to \(parkName)! Now's a great time to start planning dining and FastPass+."
        case 30:
            return "\(parkName) is just one month away. Start those packing lists!"
        case 14:
            return "Two weeks until \(trip.name)! The excitement is real. Check your reservations."
        case 7:
            return "Seven sleeps until \(parkName)! Time to start packing and charging the camera."
        case 3:
            return "Just 3 days until \(parkName)! Finish those last-minute preparations and rest up."
        case 1:
            return "One sleep left! Tomorrow you'll be at \(parkName). Sweet Disney dreams tonight!"
        case 0:
            return "The wait is over — \(trip.name) is HERE! Have the most magical day!"
        default:
            return "\(milestone.daysOut) days until \(trip.name) at \(parkName). The magic is coming!"
        }
    }
}
