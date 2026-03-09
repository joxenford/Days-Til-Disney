import XCTest
@testable import Days_Til_Disney

@MainActor
final class DefaultMilestoneManagerTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!
    private var sut: DefaultMilestoneManager!
    private let tripID = UUID()

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "com.test.DefaultMilestoneManagerTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        sut = DefaultMilestoneManager(defaults: defaults)
    }

    override func tearDown() async throws {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        sut = nil
        try await super.tearDown()
    }

    // MARK: - checkMilestone

    func test_checkMilestone_returnsMatchingMilestone() {
        let result = sut.checkMilestone(daysOut: 100)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.daysOut, 100)
    }

    func test_checkMilestone_returnsNil_forNonMilestoneDay() {
        XCTAssertNil(sut.checkMilestone(daysOut: 42))
        XCTAssertNil(sut.checkMilestone(daysOut: 99))
        XCTAssertNil(sut.checkMilestone(daysOut: -1))
    }

    func test_checkMilestone_day0_returnsFireworksMilestone() {
        let result = sut.checkMilestone(daysOut: 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.celebrationType, .fireworks)
    }

    func test_checkMilestone_allDefinedMilestoneDays_areFound() {
        for milestone in Milestone.all {
            let found = sut.checkMilestone(daysOut: milestone.daysOut)
            XCTAssertNotNil(found, "Expected milestone at daysOut=\(milestone.daysOut)")
        }
    }

    // MARK: - hasCelebrated / recordCelebration

    func test_hasCelebrated_returnsFalse_beforeCelebration() {
        XCTAssertFalse(sut.hasCelebrated(daysOut: 100, tripID: tripID))
    }

    func test_hasCelebrated_returnsTrue_afterRecordCelebration() {
        sut.recordCelebration(daysOut: 100, tripID: tripID)
        XCTAssertTrue(sut.hasCelebrated(daysOut: 100, tripID: tripID))
    }

    func test_hasCelebrated_isIsolatedPerDaysOut() {
        sut.recordCelebration(daysOut: 100, tripID: tripID)
        XCTAssertFalse(sut.hasCelebrated(daysOut: 50, tripID: tripID))
    }

    func test_hasCelebrated_isIsolatedPerTrip() {
        let otherTripID = UUID()
        sut.recordCelebration(daysOut: 100, tripID: tripID)
        XCTAssertFalse(sut.hasCelebrated(daysOut: 100, tripID: otherTripID))
    }

    func test_recordCelebration_persistsAcrossInstances() {
        sut.recordCelebration(daysOut: 7, tripID: tripID)

        let newManager = DefaultMilestoneManager(defaults: defaults)
        XCTAssertTrue(newManager.hasCelebrated(daysOut: 7, tripID: tripID))
    }

    func test_recordCelebration_allMilestoneDays() {
        for milestone in Milestone.all {
            sut.recordCelebration(daysOut: milestone.daysOut, tripID: tripID)
            XCTAssertTrue(
                sut.hasCelebrated(daysOut: milestone.daysOut, tripID: tripID),
                "daysOut=\(milestone.daysOut) should be celebrated"
            )
        }
    }

    // MARK: - MilestoneEvent

    func test_milestoneEvent_hasCorrectID() {
        let trip = Trip.makeTest()
        let milestone = Milestone.matching(daysOut: 7)!
        let event = MilestoneEvent(milestone: milestone, trip: trip)

        XCTAssertEqual(event.id, "\(7)-\(trip.id.uuidString)")
    }

    func test_milestoneEvent_celebrationType_delegatesToMilestone() {
        let trip = Trip.makeTest()
        let milestone = Milestone.matching(daysOut: 7)!
        let event = MilestoneEvent(milestone: milestone, trip: trip)
        XCTAssertEqual(event.celebrationType, .fireworks)
    }

    func test_milestoneEvent_tripName_matchesTrip() {
        let trip = Trip.makeTest(name: "Magical Trip")
        let event = MilestoneEvent(milestone: Milestone.matching(daysOut: 30)!, trip: trip)
        XCTAssertEqual(event.tripName, "Magical Trip")
    }

    func test_milestoneEvent_parkDisplayName_matchesPrimaryPark() {
        let trip = Trip.makeTest(parks: [.epcot])
        let event = MilestoneEvent(milestone: Milestone.matching(daysOut: 50)!, trip: trip)
        XCTAssertEqual(event.parkDisplayName, DisneyPark.epcot.displayName)
    }

    func test_milestoneEvent_equality_sameIDAreEqual() {
        let trip = Trip.makeTest()
        let milestone = Milestone.matching(daysOut: 14)!
        let event1 = MilestoneEvent(milestone: milestone, trip: trip)
        let event2 = MilestoneEvent(milestone: milestone, trip: trip)
        XCTAssertEqual(event1, event2)
    }
}
