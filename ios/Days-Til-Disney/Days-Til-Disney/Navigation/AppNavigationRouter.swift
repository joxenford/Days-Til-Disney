import SwiftUI

// MARK: - Route definitions

/// All navigable destinations in the app.
enum AppRoute: Hashable {
    case tripDetail(tripID: UUID)
    case addTrip
    case editTrip(tripID: UUID)
    case settings
    case packingList(tripID: UUID)
    /// Live wait times and show schedule for a specific park during an ongoing trip.
    case parkDashboard(tripID: UUID, park: DisneyPark, allParks: [DisneyPark])
    /// Milestone celebration screen. Carries only the trip; `MilestoneView` resolves
    /// `daysUntilStart`, `primaryPark`, and the matching `Milestone` from the trip.
    case milestone(tripID: UUID)
}

// MARK: - Root screen states

private enum RootScreen {
    case splash
    case onboarding
    case home
}

// MARK: - Router

/// Root navigation container using NavigationStack for path-based routing.
/// Handles splash → onboarding (first launch) or splash → home (returning user).
/// On iPad (horizontalSizeClass == .regular) the home screen is replaced by the
/// two-column `iPadHomeLayout`; on iPhone the existing single-column path is unchanged.
struct AppNavigationRouter: View {
    @Environment(UserPreferences.self) private var preferences
    @Environment(AppContainer.self) private var appContainer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var navigationPath = NavigationPath()
    @State private var rootScreen: RootScreen = .splash

    var body: some View {
        Group {
            switch rootScreen {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        rootScreen = preferences.hasCompletedOnboarding ? .home : .onboarding
                    }
                }

            case .onboarding:
                // The WelcomeView is presented outside the NavigationStack so it occupies
                // the full screen without a nav bar. When the user taps "Create Your First
                // Trip" we flip to .home and immediately push .addTrip onto the stack.
                WelcomeView(
                    onCreateTrip: {
                        preferences.hasCompletedOnboarding = true
                        rootScreen = .home
                        // Append after the state change so the NavigationStack exists.
                        // Task { @MainActor in } is safer than DispatchQueue.main.async —
                        // it participates in Swift Concurrency and is easier to reason about.
                        Task { @MainActor in
                            navigationPath.append(AppRoute.addTrip)
                        }
                    },
                    onSkip: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            preferences.hasCompletedOnboarding = true
                            rootScreen = .home
                        }
                    }
                )

            case .home:
                if horizontalSizeClass == .regular {
                    // iPad: two-column layout.  The right column owns its own NavigationStack
                    // so detail pushes fill the right pane while the hero stays on the left.
                    iPadHomeLayout(router: self)
                } else {
                    // iPhone: unchanged single-column NavigationStack.
                    NavigationStack(path: $navigationPath) {
                        HomeView(router: self)
                            .navigationDestination(for: AppRoute.self) { route in
                                destination(for: route)
                            }
                    }
                }
            }
        }
        // Deep-link handling: when a notification is tapped, the handler sets
        // pendingTripID. We consume it here by navigating to the trip detail view.
        // The `Task { @MainActor in }` wrapper defers the navigation one run-loop
        // so that if we are still on the splash screen the rootScreen flip can
        // complete before we attempt to push onto the NavigationStack.
        .onChange(of: appContainer.notificationDeepLinkHandler.pendingTripID) { _, tripID in
            guard let tripID else { return }
            appContainer.notificationDeepLinkHandler.clearPendingTrip()
            Task { @MainActor in
                // Ensure we are on the home screen before pushing.
                if rootScreen != .home {
                    preferences.hasCompletedOnboarding = true
                    rootScreen = .home
                }
                // Clear any existing navigation stack so we land cleanly on the
                // trip detail rather than stacking on top of whatever was open.
                navigationPath.removeLast(navigationPath.count)
                navigationPath.append(AppRoute.tripDetail(tripID: tripID))
            }
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .tripDetail(let tripID):
            TripDetailView(tripID: tripID, router: self)

        case .addTrip:
            AddEditTripView(mode: .add, router: self)

        case .editTrip(let tripID):
            AddEditTripView(mode: .edit(tripID: tripID), router: self)

        case .settings:
            SettingsView()

        case .packingList(let tripID):
            PackingListView(tripID: tripID)

        case .parkDashboard(let tripID, let park, let allParks):
            ParkDashboardView(tripID: tripID, parks: allParks, initialPark: park)

        case .milestone(let tripID):
            MilestoneView(tripID: tripID)
        }
    }

    // MARK: - Navigation actions (called by ViewModels / Views)

    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
