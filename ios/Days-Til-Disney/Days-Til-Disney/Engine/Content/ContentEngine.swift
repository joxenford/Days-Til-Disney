import Foundation

/// The contract for selecting and delivering daily Disney content.
protocol ContentEngine {
    /// Returns the content to display today for the given trip.
    /// Handles no-repeat tracking internally and falls back gracefully when
    /// the curated library is exhausted.
    func contentForToday(trip: Trip) async throws -> DailyContent?

    /// Resets the shown-content history for a trip (useful for testing or on trip deletion).
    func resetHistory(for tripID: UUID) async
}
