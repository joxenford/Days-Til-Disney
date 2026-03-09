import SwiftUI

// MARK: - Route definitions

/// All navigable destinations in the app.
enum AppRoute: Hashable {
    case home
    case tripDetail(tripID: UUID)
    case addTrip
    case editTrip(tripID: UUID)
    case settings
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
struct AppNavigationRouter: View {
    @Environment(UserPreferences.self) private var preferences
    @State private var navigationPath = NavigationPath()
    @State private var rootScreen: RootScreen = .splash

    var body: some View {
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
                    DispatchQueue.main.async {
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
            NavigationStack(path: $navigationPath) {
                HomeView(router: self)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(router: self)

        case .tripDetail(let tripID):
            TripDetailView(tripID: tripID, router: self)

        case .addTrip:
            AddEditTripView(mode: .add, router: self)

        case .editTrip(let tripID):
            AddEditTripView(mode: .edit(tripID: tripID), router: self)

        case .settings:
            SettingsView()
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
