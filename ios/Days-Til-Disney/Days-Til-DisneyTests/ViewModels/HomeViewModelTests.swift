import XCTest
@testable import Days_Til_Disney

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var tripRepo: MockTripRepository!
    private var contentEngine: MockContentEngine!
    private var milestoneManager: MockMilestoneManager!
    private var notificationManager: MockMilestoneNotificationManager!
    private var themeProvider: ParkThemeProvider!
    private var sut: HomeViewModel!

    override func setUp() async throws {
        try await super.setUp()
        tripRepo = MockTripRepository()
        contentEngine = MockContentEngine()
        milestoneManager = MockMilestoneManager()
        notificationManager = MockMilestoneNotificationManager()
        themeProvider = ParkThemeProvider.preview()
        sut = makeVM()
    }

    override func tearDown() async throws {
        sut = nil
        themeProvider = nil
        notificationManager = nil
        milestoneManager = nil
        contentEngine = nil
        tripRepo = nil
        try await super.tearDown()
    }

    private func makeVM() -> HomeViewModel {
        HomeViewModel(
            tripRepository: tripRepo,
            contentEngine: contentEngine,
            milestoneManager: milestoneManager,
            notificationManager: notificationManager,
            themeProvider: themeProvider
        )
    }

    // MARK: - Initial state

    func test_initialState_isLoading() {
        XCTAssertEqual(stateLabel(sut.viewState), "loading")
    }

    // MARK: - onAppear / loadData

    func test_onAppear_withNoTrips_setsEmptyState() async {
        await sut.onAppear()
        XCTAssertEqual(stateLabel(sut.viewState), "empty")
    }

    func test_onAppear_withTrips_setsLoadedState() async {
        tripRepo.trips = [Trip.makeTest(isPrimary: true)]
        await sut.onAppear()
        XCTAssertEqual(stateLabel(sut.viewState), "loaded")
    }

    func test_onAppear_fetchError_setsErrorState() async {
        tripRepo.shouldThrowOnFetch = true
        await sut.onAppear()
        XCTAssertEqual(stateLabel(sut.viewState), "error")
    }

    // MARK: - Primary trip selection

    func test_primaryTrip_prefersExplicitlyFlaggedPrimary() async {
        let primary = Trip.makeTest(name: "Primary", isPrimary: true)
        let other = Trip.makeTest(name: "Other", startDate: .daysFromNow(60), isPrimary: false)
        tripRepo.trips = [primary, other]

        await sut.onAppear()

        if case .loaded(let resolvedPrimary, _, _) = sut.viewState {
            XCTAssertEqual(resolvedPrimary?.name, "Primary")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func test_primaryTrip_fallsBackToFirstNonPast_whenNoneIsFlagged() async {
        let past = Trip.makeTest(name: "Past", startDate: .daysAgo(10), endDate: .daysAgo(5), isPrimary: false)
        let upcoming = Trip.makeTest(name: "Upcoming", startDate: .daysFromNow(10), isPrimary: false)
        tripRepo.trips = [past, upcoming]

        await sut.onAppear()

        if case .loaded(let primary, _, _) = sut.viewState {
            XCTAssertEqual(primary?.name, "Upcoming")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func test_primaryTrip_fallsBackToFirstTrip_whenAllArePast() async {
        let past1 = Trip.makeTest(name: "Past1", startDate: .daysAgo(10), endDate: .daysAgo(7))
        let past2 = Trip.makeTest(name: "Past2", startDate: .daysAgo(5), endDate: .daysAgo(2))
        tripRepo.trips = [past1, past2]

        await sut.onAppear()

        if case .loaded(let primary, _, _) = sut.viewState {
            XCTAssertNotNil(primary)
        } else {
            XCTFail("Expected loaded state")
        }
    }

    // MARK: - Secondary / past trip partitioning

    func test_secondaryTrips_excludePrimary_andPastTrips() async {
        let primary = Trip.makeTest(name: "Primary", startDate: .daysFromNow(30), isPrimary: true)
        let secondary = Trip.makeTest(name: "Secondary", startDate: .daysFromNow(60), isPrimary: false)
        let past = Trip.makeTest(name: "Past", startDate: .daysAgo(10), endDate: .daysAgo(5))
        tripRepo.trips = [primary, secondary, past]

        await sut.onAppear()

        if case .loaded(_, let sec, let p) = sut.viewState {
            XCTAssertEqual(sec.count, 1)
            XCTAssertEqual(sec.first?.name, "Secondary")
            XCTAssertEqual(p.count, 1)
            XCTAssertEqual(p.first?.name, "Past")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    // MARK: - Daily content

    func test_onAppear_loadsDailyContent_forPrimaryTrip() async {
        let trip = Trip.makeTest(isPrimary: true)
        tripRepo.trips = [trip]
        contentEngine.contentToReturn = .preview

        await sut.onAppear()

        XCTAssertNotNil(sut.dailyContent)
    }

    func test_onAppear_contentLoadFailure_leavesContentNil() async {
        tripRepo.trips = [Trip.makeTest(isPrimary: true)]
        contentEngine.shouldThrow = true

        await sut.onAppear()

        // ContentEngine failure should be swallowed (try?) and leave dailyContent nil.
        XCTAssertNil(sut.dailyContent)
    }

    // MARK: - Milestone checking

    func test_onAppear_triggersMilestone_whenMatchingAndNotYetCelebrated() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(100), isPrimary: true)
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[100] = Milestone.matching(daysOut: 100)!

        await sut.onAppear()

        XCTAssertNotNil(sut.activeMilestone)
        XCTAssertEqual(sut.activeMilestone?.milestone.daysOut, 100)
    }

    func test_onAppear_doesNotTriggerMilestone_whenAlreadyCelebrated() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(100), isPrimary: true)
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[100] = Milestone.matching(daysOut: 100)!
        milestoneManager.celebratedKeys.insert("100-\(trip.id.uuidString)")

        await sut.onAppear()

        XCTAssertNil(sut.activeMilestone)
    }

    func test_onAppear_recordsCelebration_whenMilestoneTriggered() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(100), isPrimary: true)
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[100] = Milestone.matching(daysOut: 100)!

        await sut.onAppear()

        XCTAssertEqual(milestoneManager.recordCelebrationCallCount, 1)
    }

    // MARK: - dismissMilestone

    func test_dismissMilestone_clearsActiveMilestone() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(100), isPrimary: true)
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[100] = Milestone.matching(daysOut: 100)!

        await sut.onAppear()
        XCTAssertNotNil(sut.activeMilestone)

        sut.dismissMilestone()
        XCTAssertNil(sut.activeMilestone)
    }

    // MARK: - setPrimaryTrip

    func test_setPrimaryTrip_callsRepository_andReloads() async {
        let t1 = Trip.makeTest(name: "T1", isPrimary: true)
        let t2 = Trip.makeTest(name: "T2", startDate: .daysFromNow(60), isPrimary: false)
        tripRepo.trips = [t1, t2]
        await sut.onAppear()

        await sut.setPrimaryTrip(id: t2.id)

        XCTAssertEqual(tripRepo.setPrimaryTripCallCount, 1)
    }

    // MARK: - deleteTrip

    func test_deleteTrip_callsNotificationCancellation() async {
        let trip = Trip.makeTest(name: "ToDelete")
        tripRepo.trips = [trip]
        await sut.onAppear()

        await sut.deleteTrip(id: trip.id)

        XCTAssertTrue(notificationManager.cancelledTripIDs.contains(trip.id))
    }

    func test_deleteTrip_resetsContentHistory() async {
        let trip = Trip.makeTest()
        tripRepo.trips = [trip]
        await sut.onAppear()

        await sut.deleteTrip(id: trip.id)

        XCTAssertEqual(contentEngine.resetHistoryCallCount, 1)
    }

    func test_deleteTrip_removesFromRepository() async {
        let trip = Trip.makeTest()
        tripRepo.trips = [trip]
        await sut.onAppear()

        await sut.deleteTrip(id: trip.id)

        XCTAssertEqual(tripRepo.deleteTripCallCount, 1)
        XCTAssertTrue(tripRepo.trips.isEmpty)
    }

    // MARK: - onRefresh

    func test_onRefresh_setsAndClearsRefreshing() async {
        await sut.onRefresh()
        XCTAssertFalse(sut.isRefreshing)
    }

    // MARK: - Theme provider

    func test_onAppear_withPrimaryTrip_updatesThemeProvider() async {
        let trip = Trip.makeTest(parks: [.epcot], isPrimary: true)
        tripRepo.trips = [trip]

        await sut.onAppear()

        XCTAssertEqual(themeProvider.currentTheme.park, .epcot)
    }

    // MARK: - Helpers

    private func stateLabel(_ state: HomeViewState) -> String {
        switch state {
        case .loading:            return "loading"
        case .empty:              return "empty"
        case .loaded:             return "loaded"
        case .error:              return "error"
        }
    }
}
