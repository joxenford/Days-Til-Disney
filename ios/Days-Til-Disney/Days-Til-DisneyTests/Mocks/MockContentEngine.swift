import Foundation
@testable import Days_Til_Disney

/// Stub ContentEngine for ViewModel tests.
@MainActor
final class MockContentEngine: ContentEngine {
    var contentToReturn: DailyContent? = nil
    var feedToReturn: [DailyContent] = []
    var resetHistoryCallCount = 0
    var contentForTodayCallCount = 0

    var shouldThrow = false
    enum MockError: Error { case intentional }

    func contentForToday(trip: Trip) async throws -> DailyContent? {
        contentForTodayCallCount += 1
        if shouldThrow { throw MockError.intentional }
        return contentToReturn
    }

    func fetchContentFeed(for trip: Trip, daysOut: Int) async throws -> [DailyContent] {
        if shouldThrow { throw MockError.intentional }
        return feedToReturn
    }

    func resetHistory(for tripID: UUID) async {
        resetHistoryCallCount += 1
    }
}
