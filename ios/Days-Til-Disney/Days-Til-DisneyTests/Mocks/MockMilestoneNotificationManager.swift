import Foundation
import UserNotifications
@testable import Days_Til_Disney

/// Stub MilestoneNotificationManager — no actual UNUserNotificationCenter calls.
final class MockMilestoneNotificationManager: MilestoneNotificationManager {
    var permissionGranted = true
    var authStatus: UNAuthorizationStatus = .authorized

    var requestPermissionCallCount = 0
    var scheduleForTripCallCount = 0
    var scheduleForAllCallCount = 0
    var cancelForTripCallCount = 0
    var cancelAllCallCount = 0

    var scheduledTripIDs: [UUID] = []
    var cancelledTripIDs: [UUID] = []

    func requestPermission() async -> Bool {
        requestPermissionCallCount += 1
        return permissionGranted
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        authStatus
    }

    func scheduleNotifications(for trip: Trip) async {
        scheduleForTripCallCount += 1
        scheduledTripIDs.append(trip.id)
    }

    func scheduleNotifications(forAll trips: [Trip]) async {
        scheduleForAllCallCount += 1
        scheduledTripIDs.append(contentsOf: trips.map(\.id))
    }

    func cancelNotifications(for tripID: UUID) {
        cancelForTripCallCount += 1
        cancelledTripIDs.append(tripID)
    }

    func cancelAllNotifications() {
        cancelAllCallCount += 1
    }
}
