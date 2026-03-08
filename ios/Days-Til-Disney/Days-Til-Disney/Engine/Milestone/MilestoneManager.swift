import Foundation

/// The contract for detecting and emitting milestone celebration events.
protocol MilestoneManager {
    /// Checks whether the given days-out count corresponds to a milestone.
    /// Returns the matching Milestone if so, nil otherwise.
    func checkMilestone(daysOut: Int) -> Milestone?

    /// Returns true if the milestone for `daysOut` has already been celebrated
    /// for this trip (so we don't re-trigger on every app launch).
    func hasCelebrated(daysOut: Int, tripID: UUID) -> Bool

    /// Persists that the milestone was celebrated so it won't fire again.
    func recordCelebration(daysOut: Int, tripID: UUID)
}
