import Foundation
import Observation

// MARK: - View State

enum TripDetailViewState {
    case loading
    case loaded(trip: Trip, content: [DailyContent])
    case notFound
    case error(String)
}

// MARK: - ViewModel

@Observable
@MainActor
final class TripDetailViewModel {
    private(set) var viewState: TripDetailViewState = .loading
    private(set) var activeMilestone: MilestoneEvent?

    private let tripID: UUID
    private let tripRepository: any TripRepository
    private let contentRepository: any ContentRepository
    private let milestoneManager: any MilestoneManager
    private let themeProvider: ParkThemeProvider

    init(
        tripID: UUID,
        tripRepository: any TripRepository,
        contentRepository: any ContentRepository,
        milestoneManager: any MilestoneManager,
        themeProvider: ParkThemeProvider
    ) {
        self.tripID = tripID
        self.tripRepository = tripRepository
        self.contentRepository = contentRepository
        self.milestoneManager = milestoneManager
        self.themeProvider = themeProvider
    }

    // MARK: - Lifecycle

    func onAppear() async {
        await loadData()
    }

    // MARK: - Data loading

    private func loadData() async {
        do {
            guard let trip = try await tripRepository.fetchTrip(by: tripID) else {
                viewState = .notFound
                return
            }

            let daysOut = trip.daysUntilStart
            let content = try await contentRepository.fetchContent(for: trip, daysOut: daysOut)

            viewState = .loaded(trip: trip, content: content)
            themeProvider.setActivePark(trip.primaryPark)
            checkMilestones(for: trip)

        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func checkMilestones(for trip: Trip) {
        let daysOut = trip.daysUntilStart
        guard let milestone = milestoneManager.checkMilestone(daysOut: daysOut),
              !milestoneManager.hasCelebrated(daysOut: daysOut, tripID: trip.id) else { return }

        milestoneManager.recordCelebration(daysOut: daysOut, tripID: trip.id)
        activeMilestone = MilestoneEvent(milestone: milestone, trip: trip)
    }

    func dismissMilestone() {
        activeMilestone = nil
    }

    // MARK: - Factory

    static func make(tripID: UUID, from container: AppContainer) -> TripDetailViewModel {
        TripDetailViewModel(
            tripID: tripID,
            tripRepository: container.tripRepository,
            contentRepository: container.contentRepository,
            milestoneManager: container.milestoneManager,
            themeProvider: container.themeProvider
        )
    }
}
