import AppIntents
import Foundation

// MARK: - Trip App Entity

/// A lightweight, serialisable representation of a Trip used by AppIntents.
/// Only carries the fields the widget configuration UI needs.
struct TripAppEntity: AppEntity {

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Disney Trip"

    static var defaultQuery = TripAppEntityQuery()

    var id: UUID
    var name: String
    var parkEmoji: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(parkEmoji) \(name)"
        )
    }
}

// MARK: - Query

struct TripAppEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [TripAppEntity] {
        WidgetDataProvider.allTrips().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [TripAppEntity] {
        WidgetDataProvider.allTrips()
    }
}

// MARK: - Intent

/// Lets users pick which trip to display in the widget configuration sheet.
struct SelectTripIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Trip"
    static var description = IntentDescription("Choose which Disney trip to count down to.")

    @Parameter(title: "Trip", optionsProvider: TripOptionsProvider())
    var trip: TripAppEntity?
}

// MARK: - Options Provider

private struct TripOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [TripAppEntity] {
        WidgetDataProvider.allTrips()
    }
}
