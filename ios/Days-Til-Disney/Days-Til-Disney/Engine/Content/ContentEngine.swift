import Foundation

/// The contract for selecting and delivering daily Disney content.
@MainActor
protocol ContentEngine {
    /// Returns the content to display today for the given trip.
    /// Handles no-repeat tracking internally and falls back gracefully when
    /// the curated library is exhausted.
    func contentForToday(trip: Trip) async throws -> DailyContent?

    /// Returns all content items relevant to the given trip and days-out count.
    /// Used by detail views that display a multi-item content feed rather than a single card.
    func fetchContentFeed(for trip: Trip, daysOut: Int) async throws -> [DailyContent]

    /// Resets the shown-content history for a trip (useful for testing or on trip deletion).
    func resetHistory(for tripID: UUID) async
}
