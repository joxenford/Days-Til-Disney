import Foundation
import Observation

// MARK: - Sort order

enum AttractionSortOrder: String, CaseIterable, Identifiable {
    case waitTimeDescending = "Wait Time"
    case alphabetical       = "A – Z"
    case statusFirst        = "Status"

    var id: String { rawValue }
}

// MARK: - View state

enum ParkDashboardViewState {
    case loading
    case loaded(ParkLiveData)
    case error(String)
}

// MARK: - ViewModel

@Observable
@MainActor
final class ParkDashboardViewModel {

    // MARK: Published state

    private(set) var viewState: ParkDashboardViewState = .loading
    private(set) var selectedPark: DisneyPark
    var sortOrder: AttractionSortOrder = .waitTimeDescending

    // MARK: Derived

    /// Sorted attractions for the currently selected park snapshot.
    var sortedAttractions: [LiveAttraction] {
        guard case .loaded(let data) = viewState else { return [] }
        return sort(data.attractions, by: sortOrder)
    }

    /// Shows for the currently selected park snapshot.
    var shows: [LiveShow] {
        guard case .loaded(let data) = viewState else { return [] }
        return data.shows.filter { !$0.allShowTimes.isEmpty }
    }

    var operatingCount: Int {
        guard case .loaded(let data) = viewState else { return 0 }
        return data.operatingAttractions.count
    }

    var averageWait: Int? {
        guard case .loaded(let data) = viewState else { return nil }
        return data.averageWaitMinutes
    }

    var lastUpdated: Date? {
        guard case .loaded(let data) = viewState else { return nil }
        return data.fetchedAt
    }

    // MARK: Dependencies

    private let availableParks: [DisneyPark]
    private let service: any LiveParkDataService

    /// Tracks the most recently launched load task so it can be cancelled when
    /// the user switches parks before the previous fetch completes.
    private var loadTask: Task<Void, Never>?

    // MARK: Init

    init(
        parks: [DisneyPark],
        initialPark: DisneyPark,
        service: any LiveParkDataService
    ) {
        self.availableParks = parks
        self.selectedPark = initialPark
        self.service = service
    }

    // MARK: Computed

    /// Parks the user can switch between (multi-park trips show a picker).
    var parks: [DisneyPark] { availableParks }

    // MARK: - Lifecycle

    func onAppear() async {
        await loadData(park: selectedPark)
    }

    // MARK: - Actions

    func refresh() async {
        service.clearCache(for: selectedPark)
        await loadData(park: selectedPark)
    }

    func selectPark(_ park: DisneyPark) {
        guard park != selectedPark else { return }
        selectedPark = park
        viewState = .loading
        // Cancel any in-flight fetch from a previous park selection.
        loadTask?.cancel()
        loadTask = Task { await loadData(park: park) }
    }

    // MARK: - Private

    /// Fetches live data for `park` and applies the result only if `park` is still
    /// the selected park when the response arrives (guards against stale responses
    /// when the user switches parks rapidly).
    private func loadData(park: DisneyPark) async {
        do {
            let data = try await service.fetchLiveData(for: park)
            // Discard the result if the user has already moved to a different park.
            guard park == selectedPark else { return }
            viewState = .loaded(data)
        } catch {
            guard park == selectedPark else { return }
            viewState = .error(error.localizedDescription)
        }
    }

    private func sort(_ attractions: [LiveAttraction], by order: AttractionSortOrder) -> [LiveAttraction] {
        switch order {
        case .waitTimeDescending:
            return attractions.sorted { lhs, rhs in
                // Operating with a wait time always outrank non-operating.
                if lhs.status == .operating && rhs.status != .operating { return true }
                if lhs.status != .operating && rhs.status == .operating { return false }
                let lWait = lhs.standbyWaitMinutes ?? -1
                let rWait = rhs.standbyWaitMinutes ?? -1
                if lWait != rWait { return lWait > rWait }
                return lhs.name < rhs.name
            }
        case .alphabetical:
            return attractions.sorted { $0.name < $1.name }
        case .statusFirst:
            let statusRanks: [AttractionStatus] = [.operating, .down, .closed, .refurbishment]
            return attractions.sorted { lhs, rhs in
                let li = statusRanks.firstIndex(of: lhs.status) ?? statusRanks.count
                let ri = statusRanks.firstIndex(of: rhs.status) ?? statusRanks.count
                if li != ri { return li < ri }
                return lhs.name < rhs.name
            }
        }
    }

    // MARK: - Factory

    static func make(tripID: UUID, parks: [DisneyPark], initialPark: DisneyPark, from container: AppContainer) -> ParkDashboardViewModel {
        ParkDashboardViewModel(
            parks: parks,
            initialPark: initialPark,
            service: container.liveParkDataService
        )
    }
}
