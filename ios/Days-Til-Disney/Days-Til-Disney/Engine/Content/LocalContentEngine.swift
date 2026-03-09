import Foundation

/// Selects daily content from the local repository with no-repeat tracking.
///
/// Selection algorithm:
/// 1. Filter content that matches the trip's park/resort and days-out range.
/// 2. Exclude content already shown for this trip.
/// 3. Pick a deterministically random item seeded by (tripID + date) so the
///    same content appears consistently on the same day across app launches.
/// 4. If all relevant content has been shown, reset shown history and start again.
final class LocalContentEngine: ContentEngine {
    private let repository: any ContentRepository
    private let calendar: Calendar

    init(
        repository: any ContentRepository,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.calendar = calendar
    }

    // MARK: - ContentEngine

    func contentForToday(trip: Trip) async throws -> DailyContent? {
        let daysOut = calendar.daysUntil(trip.startDate)
        let candidates = try await repository.fetchContent(for: trip, daysOut: daysOut)

        guard !candidates.isEmpty else { return nil }

        let shownIDs = await repository.fetchShownContentIDs(for: trip.id)
        var unshown = candidates.filter { !shownIDs.contains($0.id) }

        // All content exhausted — reset and start over for this trip.
        if unshown.isEmpty {
            await repository.resetShownContentIDs(for: trip.id)
            unshown = candidates
        }

        // Deterministic seed: same content for the same trip on the same day.
        let seed = daySeed(for: trip.id)
        let index = seed % unshown.count
        let selected = unshown[index]

        await repository.markContentShown(contentID: selected.id, tripID: trip.id)
        return selected
    }

    func resetHistory(for tripID: UUID) async {
        await repository.resetShownContentIDs(for: tripID)
    }

    // MARK: - Private

    /// Produces an integer index seeded by trip ID + today's date.
    /// Uses djb2 hashing of the UUID string bytes for a launch-stable result —
    /// `hashValue` is not stable across process launches.
    private func daySeed(for tripID: UUID) -> Int {
        let today = calendar.startOfDay(for: Date())
        let daysSinceEpoch = Int(today.timeIntervalSinceReferenceDate / 86_400)
        let uuidHash = djb2Hash(tripID.uuidString)
        return abs(daysSinceEpoch ^ uuidHash)
    }

    /// djb2 hash: stable across process launches, simple, good distribution.
    private func djb2Hash(_ string: String) -> Int {
        var hash = 5381
        for byte in string.utf8 {
            hash = ((hash << 5) &+ hash) &+ Int(byte)
        }
        return abs(hash)
    }
}
