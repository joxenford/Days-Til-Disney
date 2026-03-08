import Foundation
import SwiftData
import Observation

/// Dependency injection container for the app.
/// All services and repositories are created once here and injected downward.
/// This is a service locator approach kept simple for MVP; a formal DI graph
/// can be introduced when the app grows to warrant it.
@Observable
@MainActor
final class AppContainer {
    // MARK: - Singleton for production use

    static let shared = AppContainer()

    // MARK: - SwiftData

    let modelContainer: ModelContainer

    // MARK: - Repositories

    let tripRepository: any TripRepository
    let contentRepository: any ContentRepository

    // MARK: - Engines

    let contentEngine: any ContentEngine
    let milestoneManager: any MilestoneManager
    let themeProvider: ParkThemeProvider

    // MARK: - Preferences

    let userPreferences: UserPreferences

    // MARK: - Init (production)

    private init() {
        do {
            modelContainer = try SwiftDataContainer.makeProductionContainer()
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }

        let defaults = UserDefaults.standard
        userPreferences = UserPreferences(defaults: defaults)

        let localContent = LocalContentRepository(defaults: defaults)
        contentRepository = localContent

        tripRepository = LocalTripRepository(modelContext: modelContainer.mainContext)
        contentEngine = LocalContentEngine(repository: contentRepository)
        milestoneManager = DefaultMilestoneManager(defaults: defaults)
        themeProvider = ParkThemeProvider(timeOfDayProvider: LiveTimeOfDayProvider())
    }

    // MARK: - Preview / test init

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer

        let defaults = UserDefaults(suiteName: "preview") ?? .standard
        userPreferences = UserPreferences(defaults: defaults)

        let localContent = LocalContentRepository(defaults: defaults)
        contentRepository = localContent

        tripRepository = LocalTripRepository(modelContext: modelContainer.mainContext)
        contentEngine = LocalContentEngine(repository: contentRepository)
        milestoneManager = DefaultMilestoneManager(defaults: defaults)
        themeProvider = ParkThemeProvider(
            park: .magicKingdom,
            timeOfDayProvider: FixedTimeOfDayProvider.day
        )
    }
}
