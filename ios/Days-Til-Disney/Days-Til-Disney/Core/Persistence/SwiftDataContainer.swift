import SwiftData
import Foundation

/// Factory for creating and configuring the app's SwiftData ModelContainer.
///
/// ## App Group migration (v1.1+)
/// From this version forward the SQLite store lives in the shared App Group
/// container (`group.com.thinkupllc.Days-Til-Disney`) so the widget extension
/// can read the same data. On the very first launch after this update the store
/// is copied from the old default location (inside the app sandbox) to the new
/// App Group URL, preserving all existing trips for TestFlight / release users.
enum SwiftDataContainer {

    // MARK: - Constants

    /// The App Group identifier. Must match the entitlement in both the main app
    /// target and the widget extension target.
    static let appGroupIdentifier = "group.com.thinkupllc.Days-Til-Disney"

    /// File name for the SQLite store.
    static let storeFileName = "Days-Til-Disney.sqlite"

    // MARK: - Schema

    /// The complete schema for the app. Add new models here as the app grows.
    static var schema: Schema {
        Schema([
            Trip.self
        ])
    }

    // MARK: - URLs

    /// The canonical store URL inside the shared App Group container.
    static var appGroupStoreURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(storeFileName)
    }

    /// The legacy store URL inside the app's default sandbox container.
    /// SwiftData places the default store here when no URL is explicitly given.
    static var legacyStoreURL: URL? {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else { return nil }
        return appSupport.appendingPathComponent(storeFileName)
    }

    // MARK: - Production container

    /// Creates the production ModelContainer backed by the App Group SQLite store.
    ///
    /// If a store already exists at the legacy (sandbox) path but not yet at the
    /// App Group path, the legacy store is copied over first so existing user data
    /// is not lost.
    static func makeProductionContainer() throws -> ModelContainer {
        guard let groupURL = appGroupStoreURL else {
            // App Group not configured — this is a misconfiguration. Fall back to
            // the default location so the app doesn't crash in a broken state, but
            // log loudly so it's caught during development.
            assertionFailure(
                "[SwiftDataContainer] App Group '\(appGroupIdentifier)' is not available. " +
                "Make sure the App Group capability is added to the main app target."
            )
            let fallback = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            return try ModelContainer(for: schema, configurations: [fallback])
        }

        // Migrate legacy store if necessary.
        migrateFromLegacyStoreIfNeeded(to: groupURL)

        let config = ModelConfiguration(
            schema: schema,
            url: groupURL,
            cloudKitDatabase: .none   // CloudKit deferred to v1.2
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    // MARK: - App Group container (used by the widget extension)

    /// Creates a ModelContainer pointing at the shared App Group store.
    /// Throws if the App Group is not available (widget mis-configuration).
    static func makeAppGroupContainer() throws -> ModelContainer {
        guard let groupURL = appGroupStoreURL else {
            throw StoreError.appGroupUnavailable
        }
        let config = ModelConfiguration(
            schema: schema,
            url: groupURL,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    // MARK: - Preview / test container

    /// Creates an in-memory container for SwiftUI previews and unit tests.
    /// Data is discarded when the container is deallocated.
    @MainActor
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
    @MainActor
    static var preview: ModelContainer {
        do {
            return try makePreviewContainer()
        } catch {
            // In a preview context it's acceptable to crash loudly so developers notice.
            fatalError("Failed to create preview SwiftData container: \(error)")
        }
    }

    // MARK: - Migration

    /// Copies the legacy store files (`.sqlite`, `-wal`, `-shm`) from the app's
    /// default Application Support directory to the App Group container.
    ///
    /// This runs at most once — if the destination file already exists the copy
    /// is skipped. File-system errors are swallowed so a migration hiccup never
    /// prevents the app from launching; the worst outcome is a fresh (empty) store.
    private static func migrateFromLegacyStoreIfNeeded(to destination: URL) {
        let fm = FileManager.default

        // Nothing to do if the App Group store already exists.
        guard !fm.fileExists(atPath: destination.path) else { return }

        guard let legacyURL = legacyStoreURL,
              fm.fileExists(atPath: legacyURL.path) else {
            // No legacy store present — first-install, nothing to migrate.
            return
        }

        // Ensure the destination directory exists.
        let destinationDir = destination.deletingLastPathComponent()
        try? fm.createDirectory(at: destinationDir, withIntermediateDirectories: true)

        // Copy the main store file and its associated WAL / SHM journal files.
        let extensions = ["", "-wal", "-shm"]
        for ext in extensions {
            let src = legacyURL.deletingPathExtension()
                .appendingPathExtension(legacyURL.pathExtension + ext)
            let dst = destination.deletingPathExtension()
                .appendingPathExtension(destination.pathExtension + ext)
            guard fm.fileExists(atPath: src.path) else { continue }
            do {
                try fm.copyItem(at: src, to: dst)
            } catch {
                // Non-fatal — the main store copy may still succeed.
                print("[SwiftDataContainer] Migration: could not copy \(src.lastPathComponent): \(error)")
            }
        }

        print("[SwiftDataContainer] Migrated legacy store to App Group container.")
    }

    // MARK: - Errors

    enum StoreError: Error, LocalizedError {
        case appGroupUnavailable

        var errorDescription: String? {
            switch self {
            case .appGroupUnavailable:
                return "The App Group '\(appGroupIdentifier)' is not available. " +
                       "Ensure the App Group capability is configured in the widget extension target."
            }
        }
    }
}
