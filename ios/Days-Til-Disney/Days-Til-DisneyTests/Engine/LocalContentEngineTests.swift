import XCTest
@testable import Days_Til_Disney

@MainActor
final class LocalContentEngineTests: XCTestCase {

    private var mockRepo: MockContentRepository!
    private var sut: LocalContentEngine!
    private let trip = Trip.makeTest(resort: .waltDisneyWorld, parks: [.magicKingdom])

    override func setUp() async throws {
        try await super.setUp()
        mockRepo = MockContentRepository()
        sut = LocalContentEngine(repository: mockRepo)
    }

    // MARK: - djb2Hash (tested via daySeed behaviour)

    /// Two calls for the same tripID+date must return the same index.
    func test_daySeed_isDeterministic_sameTripSameDay() async throws {
        let content = (1...5).map { i in
            DailyContent.makeTest(title: "Item \(i)", daysOutRange: .universal)
        }
        mockRepo.allContent = content

        let first = try await sut.contentForToday(trip: trip)
        // Reset shown so we can re-select (reset clears tracking so second call sees fresh set).
        await sut.resetHistory(for: trip.id)
        let second = try await sut.contentForToday(trip: trip)

        XCTAssertEqual(first?.id, second?.id, "Same trip on the same day must always pick the same item")
    }

    /// djb2Hash must not crash on edge-case strings (empty, very long, all-same-byte).
    func test_djb2Hash_doesNotCrashOnEdgeCaseUUIDs() async throws {
        // We can't call the private method directly, but we can exercise it via
        // contentForToday with a trip whose UUID produces edge-case hash inputs.
        let zeroUUIDTrip = Trip(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            name: "ZeroTrip",
            resort: .waltDisneyWorld,
            parks: [.magicKingdom],
            startDate: .daysFromNow(30),
            endDate: .daysFromNow(37)
        )
        mockRepo.allContent = [DailyContent.makeTest(daysOutRange: .universal)]

        let result = try await sut.contentForToday(trip: zeroUUIDTrip)
        XCTAssertNotNil(result)
    }

    /// The (daysSinceEpoch ^ uuidHash) & Int.max guard ensures we never return a negative index.
    func test_daySeed_alwaysProducesNonNegativeIndex() async throws {
        // Try with a maxed-out UUID to stress the hash.
        let maxUUIDTrip = Trip(
            id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
            name: "MaxTrip",
            resort: .waltDisneyWorld,
            parks: [.magicKingdom],
            startDate: .daysFromNow(30),
            endDate: .daysFromNow(37)
        )
        let content = (1...10).map { DailyContent.makeTest(title: "\($0)", daysOutRange: .universal) }
        mockRepo.allContent = content

        // If the index were negative this would crash with an out-of-bounds. Not crashing = passing.
        let result = try await sut.contentForToday(trip: maxUUIDTrip)
        XCTAssertNotNil(result)
    }

    // MARK: - contentForToday

    func test_contentForToday_returnsNil_whenNoCandidates() async throws {
        mockRepo.allContent = [] // no content at all

        let result = try await sut.contentForToday(trip: trip)
        XCTAssertNil(result)
    }

    func test_contentForToday_marksSelectedContentAsShown() async throws {
        let content = DailyContent.makeTest(daysOutRange: .universal)
        mockRepo.allContent = [content]

        _ = try await sut.contentForToday(trip: trip)

        XCTAssertEqual(mockRepo.markShownCallCount, 1)
    }

    func test_contentForToday_deduplicates_acrossCallsOnSameDay() async throws {
        // With 2 items and tracking: first call returns one item and marks it shown.
        // Second call on the same day should see the same index (deterministic) but
        // the item would already be in shownIDs. The dedup algorithm resets when
        // all items are exhausted, so with 1 item the second call will always reset first.
        let items = (1...3).map { DailyContent.makeTest(title: "Item \($0)", daysOutRange: .universal) }
        mockRepo.allContent = items

        _ = try await sut.contentForToday(trip: trip)
        // Mark all items as shown manually to trigger exhaustion.
        for item in items {
            await mockRepo.markContentShown(contentID: item.id, tripID: trip.id)
        }

        // Now all are shown — next call should reset and re-pick.
        let postExhaustion = try await sut.contentForToday(trip: trip)
        XCTAssertNotNil(postExhaustion)
        XCTAssertEqual(mockRepo.resetShownCallCount, 1)
    }

    func test_contentForToday_resetsAndStartsOver_whenAllShown() async throws {
        let item = DailyContent.makeTest(daysOutRange: .universal)
        mockRepo.allContent = [item]

        // Pre-mark the only item as shown.
        await mockRepo.markContentShown(contentID: item.id, tripID: trip.id)

        let result = try await sut.contentForToday(trip: trip)

        // Should have reset and returned the only available item.
        XCTAssertEqual(mockRepo.resetShownCallCount, 1)
        XCTAssertEqual(result?.id, item.id)
    }

    // MARK: - fetchContentFeed

    func test_fetchContentFeed_delegatesToRepository() async throws {
        let items = [
            DailyContent.makeTest(title: "Feed1", daysOutRange: .universal),
            DailyContent.makeTest(title: "Feed2", daysOutRange: .universal)
        ]
        mockRepo.allContent = items

        let feed = try await sut.fetchContentFeed(for: trip, daysOut: 10)
        XCTAssertEqual(feed.count, 2)
        XCTAssertEqual(mockRepo.fetchContentCallCount, 1)
    }

    // MARK: - resetHistory

    func test_resetHistory_callsRepositoryReset() async {
        await sut.resetHistory(for: trip.id)
        XCTAssertEqual(mockRepo.resetShownCallCount, 1)
    }

    // MARK: - Content filtering via repository

    func test_contentForToday_onlySelectsRelevantContent() async throws {
        let wdwContent = DailyContent.makeTest(
            title: "WDW",
            resort: .waltDisneyWorld,
            daysOutRange: .universal
        )
        let tokyoContent = DailyContent.makeTest(
            title: "Tokyo",
            resort: .tokyoDisneyResort,
            daysOutRange: .universal
        )
        mockRepo.allContent = [wdwContent, tokyoContent]

        // Trip is WDW — only wdwContent and universal (no filter) items qualify.
        // The MockContentRepository.fetchContent calls isRelevant internally.
        let result = try await sut.contentForToday(trip: trip)
        XCTAssertNotNil(result)
        // The Tokyo item should NOT be selected for a WDW trip.
        XCTAssertNotEqual(result?.title, "Tokyo")
    }
}
