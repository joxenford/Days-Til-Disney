import Foundation
import SwiftData

// MARK: - Widget Entry Model

/// Snapshot of trip data used by the widget timeline. Value type so it's safe
/// to pass across the extension boundary without live SwiftData objects.
struct WidgetTripEntry {
    let tripID: UUID
    let tripName: String
    let daysUntilStart: Int
    let isToday: Bool
    let isOngoing: Bool
    let isPast: Bool
    let startDate: Date
    let primaryPark: DisneyPark
    let colorPalette: ParkColorPalette
}

// MARK: - Provider

/// Reads trips from the shared App Group SwiftData container and converts them
/// into ``WidgetTripEntry`` values for use in the widget timeline.
struct WidgetDataProvider {

    // MARK: - Entry resolution

    /// Returns the best entry for the given optional trip ID.
    /// Falls back to the primary trip if `tripID` is nil or not found.
    static func entry(for tripID: UUID?) -> WidgetTripEntry? {
        guard let container = try? SwiftDataContainer.makeAppGroupContainer() else {
            return nil
        }
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Trip>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        guard let trips = try? context.fetch(descriptor), !trips.isEmpty else {
            return nil
        }

        // Resolve the requested trip, or fall back to primary / first upcoming / any.
        let trip: Trip?
        if let id = tripID {
            trip = trips.first { $0.id == id }
                ?? trips.first { $0.isPrimary }
                ?? trips.first { !$0.isPast }
                ?? trips.first
        } else {
            trip = trips.first { $0.isPrimary }
                ?? trips.first { !$0.isPast }
                ?? trips.first
        }

        return trip.map(WidgetTripEntry.init)
    }

    /// Returns the preferred trip for display when no specific trip is configured.
    static func preferredEntry() -> WidgetTripEntry? {
        entry(for: nil)
    }

    // MARK: - Trip list for SelectTripIntent

    /// All trips available for selection in the widget configuration UI.
    static func allTrips() -> [TripAppEntity] {
        guard let container = try? SwiftDataContainer.makeAppGroupContainer() else {
            return []
        }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Trip>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        let trips = (try? context.fetch(descriptor)) ?? []
        // Show primary trips first in the picker.
        let sorted = trips.sorted { ($0.isPrimary ? 0 : 1) < ($1.isPrimary ? 0 : 1) }
        return sorted.map { TripAppEntity(id: $0.id, name: $0.name, parkEmoji: $0.primaryPark.emoji) }
    }
}

// MARK: - WidgetTripEntry init from Trip

private extension WidgetTripEntry {
    init(_ trip: Trip) {
        tripID = trip.id
        tripName = trip.name
        daysUntilStart = trip.daysUntilStart
        isToday = trip.isToday
        isOngoing = trip.isOngoing
        isPast = trip.isPast
        startDate = trip.startDate
        primaryPark = trip.primaryPark
        colorPalette = trip.colorPalette
    }
}
