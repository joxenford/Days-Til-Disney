import SwiftData
import Foundation

/// Factory for creating and configuring the app's SwiftData ModelContainer.
enum SwiftDataContainer {

    /// The complete schema for the app. Add new models here as the app grows.
    static var schema: Schema {
        Schema([
            Trip.self
        ])
    }

    /// Creates the production ModelContainer backed by a persistent SQLite store.
    static func makeProductionContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none   // CloudKit deferred to v1.2
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Creates an in-memory container for SwiftUI previews and unit tests.
    /// Data is discarded when the container is deallocated.
    static func makePreviewContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: schema, configurations: [config])

        // Seed preview data.
        let context = container.mainContext
        let sampleTrips = [Trip.preview, Trip.previewToday]
        sampleTrips.forEach { context.insert($0) }
        return container
    }

    /// A convenience container for previews that suppresses throws.
    /// Falls back to an empty in-memory container on failure.
    static var preview: ModelContainer {
        do {
            return try makePreviewContainer()
        } catch {
            // In a preview context it's acceptable to crash loudly so developers notice.
            fatalError("Failed to create preview SwiftData container: \(error)")
        }
    }
}
