import Foundation

/// Default milestone manager backed by UserDefaults for celebration persistence.
@MainActor
final class DefaultMilestoneManager: MilestoneManager {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - MilestoneManager

    func checkMilestone(daysOut: Int) -> Milestone? {
        Milestone.matching(daysOut: daysOut)
    }

    func hasCelebrated(daysOut: Int, tripID: UUID) -> Bool {
        let key = celebrationKey(daysOut: daysOut, tripID: tripID)
        return defaults.bool(forKey: key)
    }

    func recordCelebration(daysOut: Int, tripID: UUID) {
        let key = celebrationKey(daysOut: daysOut, tripID: tripID)
        defaults.set(true, forKey: key)
    }

    // MARK: - Private

    private func celebrationKey(daysOut: Int, tripID: UUID) -> String {
        "milestone.celebrated.\(tripID.uuidString).\(daysOut)"
    }
}

// MARK: - MilestoneEvent

/// A resolved event ready for the UI layer to consume.
/// Uses value types only — no live SwiftData @Model references — so it is safe
/// to store and compare across actor boundaries.
struct MilestoneEvent: Identifiable, Equatable {
    /// Deterministic ID derived from the milestone day and trip UUID so equality
    /// is stable across re-creations (e.g. the same milestone on app relaunch).
    let id: String
    let milestone: Milestone
    let tripID: UUID
    let tripName: String
    let parkDisplayName: String
    let parkEmoji: String

    init(milestone: Milestone, trip: Trip) {
        self.id = "\(milestone.daysOut)-\(trip.id.uuidString)"
        self.milestone = milestone
        self.tripID = trip.id
        self.tripName = trip.name
        self.parkDisplayName = trip.primaryPark.displayName
        self.parkEmoji = trip.primaryPark.emoji
    }

    var celebrationType: Milestone.CelebrationType { milestone.celebrationType }
    var title: String { milestone.title }
    var subtitle: String { milestone.subtitle }
}
