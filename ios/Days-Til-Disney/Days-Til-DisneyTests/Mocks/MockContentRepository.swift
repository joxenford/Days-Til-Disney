import Foundation
@testable import Days_Til_Disney

/// In-memory ContentRepository mock for engine and ViewModel tests.
@MainActor
final class MockContentRepository: ContentRepository {
    var allContent: [DailyContent] = []
    var shownIDs: [UUID: Set<UUID>] = [:]

    var fetchAllCallCount = 0
    var fetchContentCallCount = 0
    var markShownCallCount = 0
    var resetShownCallCount = 0

    var shouldThrow = false
    enum MockError: Error { case intentional }

    func fetchAllContent() async throws -> [DailyContent] {
        fetchAllCallCount += 1
        if shouldThrow { throw MockError.intentional }
        return allContent
    }

    func fetchContent(for trip: Trip, daysOut: Int) async throws -> [DailyContent] {
        fetchContentCallCount += 1
        if shouldThrow { throw MockError.intentional }
        return allContent.filter { $0.isRelevant(for: trip, daysOut: daysOut) }
    }

    func fetchShownContentIDs(for tripID: UUID) async -> Set<UUID> {
        shownIDs[tripID] ?? []
    }

    func markContentShown(contentID: UUID, tripID: UUID) async {
        markShownCallCount += 1
        shownIDs[tripID, default: []].insert(contentID)
    }

    func resetShownContentIDs(for tripID: UUID) async {
        resetShownCallCount += 1
        shownIDs.removeValue(forKey: tripID)
    }
}
