import Foundation
import Observation
import SwiftUI

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
    private(set) var shareImage: UIImage?
    private(set) var isGeneratingShareImage = false

    private let tripID: UUID
    private let tripRepository: any TripRepository
    private let contentEngine: any ContentEngine
    private let milestoneManager: any MilestoneManager
    private let themeProvider: ParkThemeProvider

    init(
        tripID: UUID,
        tripRepository: any TripRepository,
        contentEngine: any ContentEngine,
        milestoneManager: any MilestoneManager,
        themeProvider: ParkThemeProvider
    ) {
        self.tripID = tripID
        self.tripRepository = tripRepository
        self.contentEngine = contentEngine
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
            let content = try await contentEngine.fetchContentFeed(for: trip, daysOut: daysOut)

            themeProvider.setActivePark(trip.primaryPark)
            viewState = .loaded(trip: trip, content: content)
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

    // MARK: - Notes

    /// Updates the notes on the loaded trip. SwiftData persists the change automatically.
    func updateNotes(_ newValue: String) {
        guard case .loaded(let trip, let content) = viewState else { return }
        trip.notes = newValue
        trip.markUpdated()
        // Re-publish the state so observers see the change reflected immediately.
        viewState = .loaded(trip: trip, content: content)
    }

    // MARK: - Share image generation

    /// Renders the ShareCountdownCard to a UIImage and stores it in `shareImage`.
    /// Call this when the user taps the share button, then observe `shareImage`
    /// to know when to present the share sheet.
    func generateShareImage(for trip: Trip) {
        guard !isGeneratingShareImage else { return }
        isGeneratingShareImage = true
        shareImage = nil

        // ImageRenderer must be created and used on the main actor.
        let card = ShareCountdownCard(trip: trip)
        let renderer = ImageRenderer(content: card)
        // Render at 3x for crisp social-share quality.
        renderer.scale = 3.0
        shareImage = renderer.uiImage
        isGeneratingShareImage = false
    }

    func clearShareImage() {
        shareImage = nil
    }

    // MARK: - Factory

    static func make(tripID: UUID, from container: AppContainer) -> TripDetailViewModel {
        TripDetailViewModel(
            tripID: tripID,
            tripRepository: container.tripRepository,
            contentEngine: container.contentEngine,
            milestoneManager: container.milestoneManager,
            themeProvider: container.themeProvider
        )
    }
}
