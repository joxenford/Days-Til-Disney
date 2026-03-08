import Foundation
import Observation

// MARK: - Mode

enum AddEditTripMode {
    case add
    case edit(tripID: UUID)

    var isEditing: Bool {
        if case .edit = self { return true }
        return false
    }

    var navigationTitle: String {
        isEditing ? "Edit Trip" : "New Trip"
    }
}

// MARK: - Form State

struct TripFormState {
    var name: String = ""
    var selectedResort: DisneyResort = .waltDisneyWorld
    var selectedParks: Set<DisneyPark> = [.magicKingdom]
    var startDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 37, to: Date()) ?? Date()
    var isPrimary: Bool = false

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !selectedParks.isEmpty
        && endDate >= startDate
    }

    var validationError: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter a trip name."
        }
        if selectedParks.isEmpty {
            return "Please select at least one park."
        }
        if endDate < startDate {
            return "End date must be on or after the start date."
        }
        return nil
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class AddEditTripViewModel {
    var form: TripFormState = TripFormState()
    private(set) var isSaving: Bool = false
    private(set) var saveError: String?
    private(set) var didSaveSuccessfully: Bool = false

    private let mode: AddEditTripMode
    private let tripRepository: any TripRepository

    init(mode: AddEditTripMode, tripRepository: any TripRepository) {
        self.mode = mode
        self.tripRepository = tripRepository
    }

    // MARK: - Lifecycle

    func onAppear() async {
        if case .edit(let id) = mode {
            await loadExistingTrip(id: id)
        }
    }

    // MARK: - Form actions

    /// When the resort changes, reset park selection to the resort's first park.
    func resortDidChange(to resort: DisneyResort) {
        form.selectedResort = resort
        form.selectedParks = [resort.primaryPark]
    }

    func togglePark(_ park: DisneyPark) {
        if form.selectedParks.contains(park) {
            // Don't allow deselecting the last park.
            if form.selectedParks.count > 1 {
                form.selectedParks.remove(park)
            }
        } else {
            form.selectedParks.insert(park)
        }
    }

    func save() async {
        guard form.isValid else {
            saveError = form.validationError
            return
        }

        isSaving = true
        saveError = nil

        do {
            let parksOrdered = form.selectedResort.parks.filter { form.selectedParks.contains($0) }

            switch mode {
            case .add:
                let trip = Trip(
                    name: form.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    resort: form.selectedResort,
                    parks: parksOrdered,
                    startDate: form.startDate,
                    endDate: form.endDate,
                    isPrimary: form.isPrimary
                )
                try await tripRepository.saveTrip(trip)
                if form.isPrimary {
                    try await tripRepository.setPrimaryTrip(id: trip.id)
                }

            case .edit(let id):
                if let existing = try await tripRepository.fetchTrip(by: id) {
                    existing.name = form.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    existing.resort = form.selectedResort
                    existing.parks = parksOrdered
                    existing.startDate = form.startDate
                    existing.endDate = form.endDate
                    existing.isPrimary = form.isPrimary
                    try await tripRepository.updateTrip(existing)
                    if form.isPrimary {
                        try await tripRepository.setPrimaryTrip(id: id)
                    }
                }
            }

            didSaveSuccessfully = true
        } catch {
            saveError = error.localizedDescription
        }

        isSaving = false
    }

    // MARK: - Private

    private func loadExistingTrip(id: UUID) async {
        guard let trip = try? await tripRepository.fetchTrip(by: id) else { return }
        form.name = trip.name
        form.selectedResort = trip.resort
        form.selectedParks = Set(trip.parks)
        form.startDate = trip.startDate
        form.endDate = trip.endDate
        form.isPrimary = trip.isPrimary
    }

    // MARK: - Factory

    static func make(mode: AddEditTripMode, from container: AppContainer) -> AddEditTripViewModel {
        AddEditTripViewModel(mode: mode, tripRepository: container.tripRepository)
    }
}
