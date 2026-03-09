import XCTest
@testable import Days_Til_Disney

@MainActor
final class TripDetailViewModelTests: XCTestCase {

    private var tripRepo: MockTripRepository!
    private var contentEngine: MockContentEngine!
    private var milestoneManager: MockMilestoneManager!
    private var themeProvider: ParkThemeProvider!

    override func setUp() async throws {
        try await super.setUp()
        tripRepo = MockTripRepository()
        contentEngine = MockContentEngine()
        milestoneManager = MockMilestoneManager()
        themeProvider = ParkThemeProvider.preview()
    }

    override func tearDown() async throws {
        themeProvider = nil
        milestoneManager = nil
        contentEngine = nil
        tripRepo = nil
        try await super.tearDown()
    }

    private func makeVM(tripID: UUID) -> TripDetailViewModel {
        TripDetailViewModel(
            tripID: tripID,
            tripRepository: tripRepo,
            contentEngine: contentEngine,
            milestoneManager: milestoneManager,
            themeProvider: themeProvider
        )
    }

    // MARK: - Initial state

    func test_initialState_isLoading() {
        let sut = makeVM(tripID: UUID())
        XCTAssertEqual(stateLabel(sut.viewState), "loading")
    }

    // MARK: - onAppear / loadData

    func test_onAppear_tripFound_setsLoadedState() async {
        let trip = Trip.makeTest()
        tripRepo.trips = [trip]

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        XCTAssertEqual(stateLabel(sut.viewState), "loaded")
    }

    func test_onAppear_tripNotFound_setsNotFoundState() async {
        let sut = makeVM(tripID: UUID()) // no trips in repo

        await sut.onAppear()

        XCTAssertEqual(stateLabel(sut.viewState), "notFound")
    }

    func test_onAppear_repositoryError_setsErrorState() async {
        tripRepo.shouldThrowOnFetch = true
        let sut = makeVM(tripID: UUID())

        await sut.onAppear()

        XCTAssertEqual(stateLabel(sut.viewState), "error")
    }

    // MARK: - Content feed

    func test_onAppear_loadsContentFeed() async {
        let trip = Trip.makeTest()
        tripRepo.trips = [trip]
        let feedItems = [DailyContent.makeTest(title: "Feed Item", daysOutRange: .universal)]
        contentEngine.feedToReturn = feedItems

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        if case .loaded(_, let content) = sut.viewState {
            XCTAssertEqual(content.count, 1)
            XCTAssertEqual(content.first?.title, "Feed Item")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func test_onAppear_emptyFeed_setsLoadedWithEmptyContent() async {
        let trip = Trip.makeTest()
        tripRepo.trips = [trip]
        contentEngine.feedToReturn = []

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        if case .loaded(_, let content) = sut.viewState {
            XCTAssertTrue(content.isEmpty)
        } else {
            XCTFail("Expected loaded state")
        }
    }

    // MARK: - Theme provider

    func test_onAppear_updatesThemeProvider_withTripPrimaryPark() async {
        let trip = Trip.makeTest(parks: [.tokyoDisneySea])
        tripRepo.trips = [trip]

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        XCTAssertEqual(themeProvider.currentTheme.park, .tokyoDisneySea)
    }

    // MARK: - Milestone checking

    func test_onAppear_triggersMilestone_whenMatchingAndNotCelebrated() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(7))
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[7] = Milestone.matching(daysOut: 7)!

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        XCTAssertNotNil(sut.activeMilestone)
        XCTAssertEqual(sut.activeMilestone?.milestone.daysOut, 7)
    }

    func test_onAppear_doesNotTriggerMilestone_whenAlreadyCelebrated() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(7))
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[7] = Milestone.matching(daysOut: 7)!
        milestoneManager.celebratedKeys.insert("7-\(trip.id.uuidString)")

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        XCTAssertNil(sut.activeMilestone)
    }

    func test_onAppear_noMatchingMilestone_activeMilestoneRemainsNil() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(42)) // Not a milestone day
        tripRepo.trips = [trip]

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        XCTAssertNil(sut.activeMilestone)
    }

    // MARK: - dismissMilestone

    func test_dismissMilestone_clearsActiveMilestone() async {
        let trip = Trip.makeTest(startDate: .daysFromNow(100))
        tripRepo.trips = [trip]
        milestoneManager.milestonesByDaysOut[100] = Milestone.matching(daysOut: 100)!

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()
        XCTAssertNotNil(sut.activeMilestone)

        sut.dismissMilestone()
        XCTAssertNil(sut.activeMilestone)
    }

    // MARK: - Loaded state data

    func test_loadedState_containsCorrectTrip() async {
        let trip = Trip.makeTest(name: "Test Detail Trip")
        tripRepo.trips = [trip]

        let sut = makeVM(tripID: trip.id)
        await sut.onAppear()

        if case .loaded(let loadedTrip, _) = sut.viewState {
            XCTAssertEqual(loadedTrip.name, "Test Detail Trip")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    // MARK: - Helpers

    private func stateLabel(_ state: TripDetailViewState) -> String {
        switch state {
        case .loading:   return "loading"
        case .loaded:    return "loaded"
        case .notFound:  return "notFound"
        case .error:     return "error"
        }
    }
}
