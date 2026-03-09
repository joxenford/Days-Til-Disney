import Foundation
import Observation

// MARK: - View State

enum PackingListViewState {
    case loading
    case loaded(trip: Trip, sections: [PackingSection])
    case error(String)
}

/// A category section in the packing list — one per `PackingCategory`.
struct PackingSection: Identifiable {
    let category: PackingCategory
    var items: [PackingItem]

    var id: String { category.id }

    var checkedCount: Int { items.filter(\.isChecked).count }
    var totalCount: Int { items.count }
    var allChecked: Bool { !items.isEmpty && checkedCount == totalCount }
}

// MARK: - ViewModel

@Observable
@MainActor
final class PackingListViewModel {
    private(set) var viewState: PackingListViewState = .loading
    private(set) var isAddingItem = false
    var newItemName: String = ""
    var newItemCategory: PackingCategory = .custom
    private(set) var saveError: String?

    private let tripID: UUID
    private let tripRepository: any TripRepository
    private let packingListRepository: any PackingListRepository

    init(
        tripID: UUID,
        tripRepository: any TripRepository,
        packingListRepository: any PackingListRepository
    ) {
        self.tripID = tripID
        self.tripRepository = tripRepository
        self.packingListRepository = packingListRepository
    }

    // MARK: - Computed helpers

    /// Total progress across all categories.
    var totalChecked: Int {
        guard case .loaded(_, let sections) = viewState else { return 0 }
        return sections.reduce(0) { $0 + $1.checkedCount }
    }

    var totalItems: Int {
        guard case .loaded(_, let sections) = viewState else { return 0 }
        return sections.reduce(0) { $0 + $1.totalCount }
    }

    // MARK: - Lifecycle

    func onAppear() async {
        await loadData()
    }

    // MARK: - Data loading

    private func loadData() async {
        do {
            guard let trip = try await tripRepository.fetchTrip(by: tripID) else {
                viewState = .error("Trip not found.")
                return
            }

            // Seed defaults on first open — if the trip has no items yet.
            let alreadySeeded = try await packingListRepository.hasItems(for: tripID)
            if !alreadySeeded {
                let defaults = DefaultPackingItems.makeItems(for: trip)
                for item in defaults {
                    try await packingListRepository.addItem(item)
                }
            }

            let items = try await packingListRepository.fetchItems(for: tripID)
            let sections = buildSections(from: items)
            viewState = .loaded(trip: trip, sections: sections)

        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func buildSections(from items: [PackingItem]) -> [PackingSection] {
        // Group by category, then sort sections by their display order.
        let grouped = Dictionary(grouping: items) { $0.category }
        return PackingCategory.allCases
            .sorted { $0.sortOrder < $1.sortOrder }
            .compactMap { category in
                guard let categoryItems = grouped[category], !categoryItems.isEmpty else {
                    return nil
                }
                return PackingSection(category: category, items: categoryItems)
            }
    }

    // MARK: - Item actions

    func toggleItem(_ item: PackingItem) {
        item.isChecked.toggle()
        Task {
            do {
                try await packingListRepository.updateItem(item)
                // Refresh sections to update progress counts.
                await refreshSections()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func deleteItem(_ item: PackingItem) {
        Task {
            do {
                try await packingListRepository.deleteItem(item)
                await refreshSections()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func addCustomItem() {
        let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard case .loaded(let trip, _) = viewState else { return }

        let item = PackingItem(
            name: trimmed,
            category: newItemCategory,
            isParkDefault: false,
            trip: trip
        )

        newItemName = ""
        isAddingItem = false

        Task {
            do {
                try await packingListRepository.addItem(item)
                await refreshSections()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func cancelAddItem() {
        newItemName = ""
        isAddingItem = false
    }

    func beginAddItem() {
        isAddingItem = true
    }

    // MARK: - Reset

    func resetToDefaults() {
        guard case .loaded(let trip, _) = viewState else { return }
        Task {
            do {
                try await packingListRepository.resetToDefaults(for: trip)
                await refreshSections()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func clearSaveError() {
        saveError = nil
    }

    // MARK: - Private helpers

    private func refreshSections() async {
        do {
            guard case .loaded(let trip, _) = viewState else { return }
            let items = try await packingListRepository.fetchItems(for: tripID)
            let sections = buildSections(from: items)
            viewState = .loaded(trip: trip, sections: sections)
        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: - Factory

    static func make(tripID: UUID, from container: AppContainer) -> PackingListViewModel {
        PackingListViewModel(
            tripID: tripID,
            tripRepository: container.tripRepository,
            packingListRepository: container.packingListRepository
        )
    }
}
