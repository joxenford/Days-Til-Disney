import Foundation
@testable import Days_Til_Disney

/// Configurable MilestoneManager mock for ViewModel tests.
@MainActor
final class MockMilestoneManager: MilestoneManager {
    /// Map from daysOut → Milestone to return from checkMilestone.
    var milestonesByDaysOut: [Int: Milestone] = [:]
    /// Set of (daysOut, tripID) pairs that have been celebrated.
    var celebratedKeys: Set<String> = []

    var checkMilestoneCallCount = 0
    var hasCelebratedCallCount = 0
    var recordCelebrationCallCount = 0

    func checkMilestone(daysOut: Int) -> Milestone? {
        checkMilestoneCallCount += 1
        return milestonesByDaysOut[daysOut]
    }

    func hasCelebrated(daysOut: Int, tripID: UUID) -> Bool {
        hasCelebratedCallCount += 1
        return celebratedKeys.contains(key(daysOut: daysOut, tripID: tripID))
    }

    func recordCelebration(daysOut: Int, tripID: UUID) {
        recordCelebrationCallCount += 1
        celebratedKeys.insert(key(daysOut: daysOut, tripID: tripID))
    }

    private func key(daysOut: Int, tripID: UUID) -> String {
        "\(daysOut)-\(tripID.uuidString)"
    }
}
