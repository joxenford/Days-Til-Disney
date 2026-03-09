import Foundation
import Observation

// MARK: - View State

enum HomeViewState {
    case loading
    case empty                          // No trips created yet.
    case loaded(primary: Trip?, secondary: [Trip], past: [Trip])
    case error(String)
}

// MARK: - ViewModel

@Observable
@MainActor
final class HomeViewModel {
    // MARK: - Published state

    private(set) var viewState: HomeViewState = .loading
    private(set) var dailyContent: DailyContent?
    private(set) var activeMilestone: MilestoneEvent?
    private(set) var isRefreshing: Bool = false

    // MARK: - Dependencies

    private let tripRepository: any TripRepository
    private let contentEngine: any ContentEngine
    private let milestoneManager: any MilestoneManager
    private let notificationManager: (any MilestoneNotificationManager)?
    private let themeProvider: ParkThemeProvider

    // MARK: - Init

    init(
        tripRepository: any TripRepository,
        contentEngine: any ContentEngine,
        milestoneManager: any MilestoneManager,
        notificationManager: (any MilestoneNotificationManager)? = nil,
        themeProvider: ParkThemeProvider
    ) {
        self.tripRepository = tripRepository
        self.contentEngine = contentEngine
        self.milestoneManager = milestoneManager
        self.notificationManager = notificationManager
        self.themeProvider = themeProvider
    }

    // MARK: - Lifecycle

    func onAppear() async {
        await loadData()
    }

    func onRefresh() async {
        isRefreshing = true
        await loadData()
        isRefreshing = false
    }

    // MARK: - Data loading

    private func loadData() async {
        do {
            let allTrips = try await tripRepository.fetchAllTrips()

            guard !allTrips.isEmpty else {
                viewState = .empty
                return
            }

            // Prefer the explicitly flagged primary, then a non-past trip, then any trip.
            let primary = allTrips.first { $0.isPrimary }
                ?? allTrips.first { !$0.isPast }
                ?? allTrips.first
            // Separate past trips from upcoming/ongoing secondary trips.
            let otherTrips = allTrips.filter { $0.id != primary?.id }
            let secondary = otherTrips.filter { !$0.isPast }
            let past = otherTrips.filter { $0.isPast }

            viewState = .loaded(primary: primary, secondary: secondary, past: past)

            // Update theme to match primary trip.
            if let primary {
                themeProvider.setActivePark(primary.primaryPark)
                await loadDailyContent(for: primary)
                checkMilestones(for: primary)
            }

        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func loadDailyContent(for trip: Trip) async {
        dailyContent = try? await contentEngine.contentForToday(trip: trip)
    }

    private func checkMilestones(for trip: Trip) {
        let daysOut = trip.daysUntilStart
        guard let milestone = milestoneManager.checkMilestone(daysOut: daysOut),
              !milestoneManager.hasCelebrated(daysOut: daysOut, tripID: trip.id) else {
            return
        }

        milestoneManager.recordCelebration(daysOut: daysOut, tripID: trip.id)
        activeMilestone = MilestoneEvent(milestone: milestone, trip: trip)
    }

    // MARK: - User actions

    func dismissMilestone() {
        activeMilestone = nil
    }

    func setPrimaryTrip(id: UUID) async {
        do {
            try await tripRepository.setPrimaryTrip(id: id)
            await loadData()
        } catch {
            // Surface error to user in a future iteration; silently recover for MVP.
        }
    }

    func deleteTrip(id: UUID) async {
        // Cancel notifications and clear content history before the delete
        // so we have the trip ID available for cleanup.
        notificationManager?.cancelNotifications(for: id)
        await contentEngine.resetHistory(for: id)
        do {
            try await tripRepository.deleteTrip(id: id)
            await loadData()
        } catch {
            // Persist failure — log or surface in v1.1.
        }
    }
}

// MARK: - Factory

extension HomeViewModel {
    static func make(from container: AppContainer) -> HomeViewModel {
        HomeViewModel(
            tripRepository: container.tripRepository,
            contentEngine: container.contentEngine,
            milestoneManager: container.milestoneManager,
            notificationManager: container.milestoneNotificationManager,
            themeProvider: container.themeProvider
        )
    }

    static var preview: HomeViewModel {
        HomeViewModel(
            tripRepository: MockTripRepository(),
            contentEngine: MockContentEngine(),
            milestoneManager: DefaultMilestoneManager(),
            themeProvider: ParkThemeProvider.preview()
        )
    }
}

// MARK: - Mock implementations for previews

private final class MockTripRepository: TripRepository {
    func fetchAllTrips() async throws -> [Trip] { [Trip.preview, Trip.previewToday] }
    func fetchPrimaryTrip() async throws -> Trip? { Trip.preview }
    func fetchTrip(by id: UUID) async throws -> Trip? { Trip.preview }
    func saveTrip(_ trip: Trip) async throws {}
    func saveTripAsPrimary(_ trip: Trip) async throws {}
    func updateTrip(_ trip: Trip) async throws {}
    func deleteTrip(id: UUID) async throws {}
    func setPrimaryTrip(id: UUID) async throws {}
}

private final class MockContentEngine: ContentEngine {
    func contentForToday(trip: Trip) async throws -> DailyContent? { .preview }
    func resetHistory(for tripID: UUID) async {}
}
