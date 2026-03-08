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

// MARK: - Router

/// Root navigation container using NavigationStack for path-based routing.
/// Handles the splash → home transition and all subsequent navigation.
struct AppNavigationRouter: View {
    @Environment(UserPreferences.self) private var preferences
    @State private var navigationPath = NavigationPath()
    @State private var showSplash = true

    var body: some View {
        if showSplash {
            SplashView {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        } else {
            NavigationStack(path: $navigationPath) {
                HomeView(router: self)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
        }
    }

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
