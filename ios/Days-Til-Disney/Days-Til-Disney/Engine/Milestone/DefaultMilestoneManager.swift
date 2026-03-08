import Foundation

/// Default milestone manager backed by UserDefaults for celebration persistence.
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
struct MilestoneEvent: Identifiable {
    let id = UUID()
    let milestone: Milestone
    let trip: Trip

    var celebrationType: Milestone.CelebrationType { milestone.celebrationType }
    var title: String { milestone.title }
    var subtitle: String { milestone.subtitle }
}
