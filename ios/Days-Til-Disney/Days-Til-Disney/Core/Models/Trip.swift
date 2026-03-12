import Foundation
import SwiftData

/// A Disney trip countdown. Stored locally via SwiftData.
///
/// SwiftData stores enum properties as their raw String values to avoid
/// limitations with Codable enum arrays in iOS 17. Computed properties
/// expose the typed enums for use throughout the app.
@Model
final class Trip {
    var id: UUID = UUID()
    var name: String = ""
    /// Backing store for the `resort` enum — stored as its rawValue String.
    var resortRawValue: String = DisneyResort.waltDisneyWorld.rawValue
    /// Backing store for the `parks` array — stored as comma-separated rawValue Strings.
    var parkRawValues: [String] = []
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isPrimary: Bool = false
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    /// Packing checklist items for this trip.
    /// cascade delete ensures items are removed when the trip is deleted.
    @Relationship(deleteRule: .cascade, inverse: \PackingItem.trip)
    var packingItems: [PackingItem]? = []

    init(
        id: UUID = UUID(),
        name: String,
        resort: DisneyResort,
        parks: [DisneyPark],
        startDate: Date,
        endDate: Date,
        isPrimary: Bool = false,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.resortRawValue = resort.rawValue
        self.parkRawValues = parks.map(\.rawValue)
        self.startDate = startDate
        self.endDate = endDate
        self.isPrimary = isPrimary
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Typed computed properties

    /// The resort for this trip, derived from the stored raw value.
    var resort: DisneyResort {
        get { DisneyResort(rawValue: resortRawValue) ?? .waltDisneyWorld }
        set { resortRawValue = newValue.rawValue }
    }

    /// The parks selected for this trip, derived from the stored raw values.
    var parks: [DisneyPark] {
        get { parkRawValues.compactMap { DisneyPark(rawValue: $0) } }
        set { parkRawValues = newValue.map(\.rawValue) }
    }

    // MARK: - Computed properties

    /// The primary park for theming — the first selected park in the trip.
    var primaryPark: DisneyPark {
        parks.first ?? resort.primaryPark
    }

    var colorPalette: ParkColorPalette {
        primaryPark.colorPalette
    }

    /// Days remaining until the trip starts. Returns 0 if the trip has started or passed.
    var daysUntilStart: Int {
        max(0, startDate.daysUntil)
    }

    /// True when the trip start date is today.
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }

    /// True when today falls within the trip dates (inclusive).
    var isOngoing: Bool {
        #if DEBUG
        // Key string must match DebugSettings.forceOngoingTripKey (Engine/DebugSettings.swift).
        // A direct reference cannot be used here because Trip.swift is also compiled into the
        // Widget extension target, which does not include DebugSettings.swift.
        if UserDefaults.standard.bool(forKey: "debug_forceOngoingTrip") { return true }
        #endif
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)
        return today >= start && today <= end
    }

    /// True when the trip's end date has passed.
    var isPast: Bool {
        Calendar.current.startOfDay(for: Date()) > Calendar.current.startOfDay(for: endDate)
    }

    /// Calendar days since the trip ended. Returns 0 on the end day, positive after.
    var daysSinceEnd: Int {
        endDate.daysSince
    }

    /// Duration of the trip in days.
    var durationDays: Int {
        max(1, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
    }

    /// Touch updatedAt on any mutation so we can sort by recency.
    func markUpdated() {
        updatedAt = Date()
    }
}

// MARK: - Sample data

extension Trip {
    static var preview: Trip {
        Trip(
            name: "Magic Kingdom Family Trip",
            resort: .waltDisneyWorld,
            parks: [.magicKingdom, .epcot, .hollywoodStudios],
            startDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 52, to: Date()) ?? Date(),
            isPrimary: true
        )
    }

    static var previewToday: Trip {
        Trip(
            name: "Tokyo Adventure",
            resort: .tokyoDisneyResort,
            parks: [.tokyoDisneyland, .tokyoDisneySea],
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isPrimary: false
        )
    }

    static var previewPast: Trip {
        Trip(
            name: "Disneyland Summer 2024",
            resort: .disneylandResort,
            parks: [.disneyland, .californiaAdventure],
            startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -23, to: Date()) ?? Date(),
            isPrimary: false
        )
    }
}
