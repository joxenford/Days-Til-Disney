import Foundation
import Observation
import UserNotifications

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
    private let notificationManager: (any MilestoneNotificationManager)?
    private let userPreferences: UserPreferences?

    init(
        mode: AddEditTripMode,
        tripRepository: any TripRepository,
        notificationManager: (any MilestoneNotificationManager)? = nil,
        userPreferences: UserPreferences? = nil
    ) {
        self.mode = mode
        self.tripRepository = tripRepository
        self.notificationManager = notificationManager
        self.userPreferences = userPreferences
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
                // Determine if this should be primary: use the user's preference,
                // or auto-promote if this is the very first trip.
                let existingTrips = try await tripRepository.fetchAllTrips()
                let isFirstTrip = existingTrips.isEmpty
                let shouldBePrimary = form.isPrimary || isFirstTrip
                let trip = Trip(
                    name: form.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    resort: form.selectedResort,
                    parks: parksOrdered,
                    startDate: form.startDate,
                    endDate: form.endDate,
                    isPrimary: shouldBePrimary
                )
                // Atomically save and promote to primary in one operation so we never
                // have a saved trip without the correct isPrimary flag.
                if shouldBePrimary {
                    try await tripRepository.saveTripAsPrimary(trip)
                } else {
                    try await tripRepository.saveTrip(trip)
                }
                // On first trip creation, request notification permission automatically.
                // This is the natural onboarding moment — the user just committed to a trip.
                if isFirstTrip {
                    await requestPermissionAndSchedule(for: trip)
                } else {
                    await scheduleNotificationsIfEnabled(for: trip)
                }

            case .edit(let id):
                if let existing = try await tripRepository.fetchTrip(by: id) {
                    existing.name = form.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    existing.resort = form.selectedResort
                    existing.parks = parksOrdered
                    existing.startDate = form.startDate
                    existing.endDate = form.endDate
                    existing.isPrimary = form.isPrimary
                    // If this trip should be primary, clear other primaries first so
                    // there is never a moment where two trips have isPrimary == true.
                    // updateTrip (called after) then saves all remaining field changes.
                    if form.isPrimary {
                        try await tripRepository.setPrimaryTrip(id: id)
                    }
                    // updateTrip calls markUpdated() internally — no need to call it here.
                    try await tripRepository.updateTrip(existing)
                    await scheduleNotificationsIfEnabled(for: existing)
                } else {
                    saveError = "This trip no longer exists."
                    isSaving = false
                    return
                }
            }

            didSaveSuccessfully = true
        } catch {
            saveError = error.localizedDescription
        }

        isSaving = false
    }

    // MARK: - Private

    /// Requests permission on first trip creation (onboarding moment).
    /// If permission is granted, enables the pref and schedules notifications for the trip.
    /// If denied or not yet determined, does nothing — user can enable via Settings later.
    private func requestPermissionAndSchedule(for trip: Trip) async {
        guard let notificationManager else { return }
        let status = await notificationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            // This is the onboarding prompt — ask for permission naturally.
            let granted = await notificationManager.requestPermission()
            if granted {
                userPreferences?.milestoneNotificationsEnabled = true
                await notificationManager.scheduleNotifications(for: trip)
            }
        case .authorized, .provisional:
            // Permission already granted from a prior session.
            userPreferences?.milestoneNotificationsEnabled = true
            await notificationManager.scheduleNotifications(for: trip)
        default:
            // Denied or restricted — do not re-prompt; user can enable in Settings.
            break
        }
    }

    private func scheduleNotificationsIfEnabled(for trip: Trip) async {
        guard let notificationManager,
              userPreferences?.milestoneNotificationsEnabled == true else { return }
        await notificationManager.scheduleNotifications(for: trip)
    }

    private func loadExistingTrip(id: UUID) async {
        do {
            guard let trip = try await tripRepository.fetchTrip(by: id) else {
                saveError = "This trip could not be found."
                return
            }
            form.name = trip.name
            form.selectedResort = trip.resort
            form.selectedParks = Set(trip.parks)
            form.startDate = trip.startDate
            form.endDate = trip.endDate
            form.isPrimary = trip.isPrimary
        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: - Factory

    static func make(mode: AddEditTripMode, from container: AppContainer) -> AddEditTripViewModel {
        AddEditTripViewModel(
            mode: mode,
            tripRepository: container.tripRepository,
            notificationManager: container.milestoneNotificationManager,
            userPreferences: container.userPreferences
        )
    }
}
