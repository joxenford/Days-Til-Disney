import SwiftUI

/// Two-column iPad layout.
///
/// LEFT column  — park-themed gradient + star field + `CountdownHeroView` for the primary trip.
/// RIGHT column — `NavigationStack` containing the trip list, daily content, and past trips.
///
/// The split is only presented when `horizontalSizeClass == .regular` (iPad).  The iPhone
/// `NavigationStack` path in `AppNavigationRouter` is left completely untouched.
struct iPadHomeLayout: View {
    @Environment(AppContainer.self) private var appContainer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let router: AppNavigationRouter

    // The iPad layout owns its own right-column navigation path so detail pushes
    // fill the right pane while the hero stays visible on the left.
    @State private var rightPath = NavigationPath()
    @State private var viewModel: HomeViewModel?
    @State private var isInitialLoad = true

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                leftColumn(width: geo.size.width * 0.42)
                Divider()
                    .background(.white.opacity(0.15))
                rightColumn
            }
        }
        .ignoresSafeArea(edges: .all)
        .task {
            let vm = HomeViewModel.make(from: appContainer)
            viewModel = vm
            await vm.onAppear()
            isInitialLoad = false
        }
        .onAppear {
            guard !isInitialLoad, let vm = viewModel else { return }
            Task { await vm.onRefresh() }
        }
        .onChange(of: viewModel?.activeMilestone) { _, newValue in
            // Reaching a milestone pushes the full-bleed MilestoneView onto the right-column
            // stack (replaces the dropped particle overlay). Haptic fires the instant it
            // resolves, then the VM flag is cleared.
            guard let event = newValue else { return }
            MilestoneHaptic.fire(event.celebrationType)
            rightPath.append(AppRoute.milestone(tripID: event.tripID))
            viewModel?.dismissMilestone()
        }
    }

    // MARK: - Left column

    private func leftColumn(width: CGFloat) -> some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()
            heroContent
        }
        // Width is 42% of the actual available container width from GeometryReader,
        // so Split View and Slide Over are handled correctly.
        .frame(width: width)
        .clipped()
    }

    @ViewBuilder
    private var heroContent: some View {
        if let vm = viewModel {
            switch vm.viewState {
            case .loaded(let primary, _, _):
                if let primary {
                    ScrollView(showsIndicators: false) {
                        CountdownHeroView(
                            trip: primary,
                            onTap: { rightPath.append(AppRoute.tripDetail(tripID: primary.id)) },
                            onAddTrip: { rightPath.append(AppRoute.addTrip) }
                        )
                        .padding(.vertical, 40)
                    }
                } else {
                    emptyHeroPlaceholder
                }
            case .empty:
                emptyHeroPlaceholder
            default:
                ProgressView().tint(.white)
            }
        } else {
            ProgressView().tint(.white)
        }
    }

    private var emptyHeroPlaceholder: some View {
        VStack(spacing: 20) {
            Text("Countdown to Magic")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    // MARK: - Right column

    private var rightColumn: some View {
        NavigationStack(path: $rightPath) {
            HomeRightPanelView(
                viewModel: viewModel,
                isInitialLoad: isInitialLoad,
                onNavigate: { route in rightPath.append(route) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        // Re-use the same destination views as the iPhone router but wired to the iPad
        // right-column navigation path (via a local router shim).
        switch route {
        case .tripDetail(let tripID):
            TripDetailView(tripID: tripID, router: router)

        case .addTrip:
            AddEditTripView(mode: .add, router: router)

        case .editTrip(let tripID):
            AddEditTripView(mode: .edit(tripID: tripID), router: router)

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

}

// MARK: - Right-panel view

/// The scrollable content shown in the right column of the iPad layout.
/// Mirrors the trip-list + daily content + past-trips content from `HomeView.loadedView`
/// but without the `CountdownHeroView` (which lives in the left column).
///
/// DUPLICATION NOTE: The `.empty`, `.error`, and `pastTripsSection` implementations here
/// are intentionally kept in sync with the corresponding sections in `HomeView.swift`.
/// They cannot share code through a common view because `HomeView` uses `router.navigate`
/// while this panel uses `onNavigate` closures that target the right-column NavigationStack.
/// If you update the empty state, error state, or past-trips section in `HomeView.swift`,
/// make the matching change here as well.
private struct HomeRightPanelView: View {
    let viewModel: HomeViewModel?
    let isInitialLoad: Bool
    let onNavigate: (AppRoute) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pastTripsExpanded = false

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    panelContent(vm: vm)
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // C-1: Prevent the system from inserting a translucent material bar over the gradient.
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar { toolbarContent }
    }

    // MARK: - Content states

    @ViewBuilder
    private func panelContent(vm: HomeViewModel) -> some View {
        switch vm.viewState {
        case .loading:
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)

        case .empty:
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text("Your adventure awaits!")
                        .font(DTDFont.titlePrimary)
                        .foregroundStyle(.white)
                    Text("Add your first trip to start the countdown.")
                        .font(DTDFont.body)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Button { onNavigate(.addTrip) } label: {
                    Label("Add Your First Trip", systemImage: "plus.circle.fill")
                        .font(DTDFont.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 40)
                }
                .accessibilityLabel("Add your first trip")
            }

        case .loaded(let primary, let secondary, let past):
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Daily content card — shown at the top of the right panel.
                    if let content = vm.dailyContent {
                        DailyContentCardView(content: content)
                            .padding(.horizontal, 20)
                    }

                    // Secondary trip cards.
                    if !secondary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "suitcase.fill")
                                    .font(DTDFont.titleSecondary)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .accessibilityHidden(true)
                                Text("Other Trips")
                                    .font(DTDFont.titleSecondary)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 20)

                            ForEach(secondary) { trip in
                                TripCardView(
                                    trip: trip,
                                    onTap: { onNavigate(.tripDetail(tripID: trip.id)) },
                                    onSetPrimary: { Task { await vm.setPrimaryTrip(id: trip.id) } },
                                    onEdit: { onNavigate(.editTrip(tripID: trip.id)) },
                                    onDelete: { Task { await vm.deleteTrip(id: trip.id) } }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Primary trip card (so it's still accessible in the list).
                    if let primary {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Primary Trip")
                                .font(DTDFont.titleSecondary)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)

                            TripCardView(
                                trip: primary,
                                onTap: { onNavigate(.tripDetail(tripID: primary.id)) },
                                onSetPrimary: {},
                                onEdit: { onNavigate(.editTrip(tripID: primary.id)) },
                                onDelete: { Task { await vm.deleteTrip(id: primary.id) } }
                            )
                            .padding(.horizontal, 20)
                        }
                    }

                    // Collapsible past trips.
                    if !past.isEmpty {
                        pastTripsSection(vm: vm, past: past)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
            .refreshable { await vm.onRefresh() }

        case .error(let message):
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Something went wrong")
                    .font(DTDFont.titleSecondary)
                    .foregroundStyle(.white)
                Text(message)
                    .font(DTDFont.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button { Task { await vm.onRefresh() } } label: {
                    Text("Try Again")
                        .font(DTDFont.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Past trips section

    @ViewBuilder
    private func pastTripsSection(vm: HomeViewModel, past: [Trip]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.75)) {
                    pastTripsExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Past Trips (\(past.count))")
                        .font(DTDFont.titleSecondary)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .rotationEffect(.degrees(pastTripsExpanded ? 90 : 0))
                }
                .padding(.horizontal, 20)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Past Trips, \(past.count) trip\(past.count == 1 ? "" : "s")")
            .accessibilityHint(pastTripsExpanded ? "Tap to collapse" : "Tap to expand")
            .accessibilityAddTraits(.isButton)

            if pastTripsExpanded {
                ForEach(past) { trip in
                    TripCardView(
                        trip: trip,
                        onTap: { onNavigate(.tripDetail(tripID: trip.id)) },
                        onSetPrimary: { Task { await vm.setPrimaryTrip(id: trip.id) } },
                        onEdit: { onNavigate(.editTrip(tripID: trip.id)) },
                        onDelete: { Task { await vm.deleteTrip(id: trip.id) } }
                    )
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            // H-1: Use DTDFont.headline — rounded, semibold, Dynamic Type aware.
            Text("Countdown to Magic")
                .font(DTDFont.headline)
                .foregroundStyle(.white)
                .fixedSize()
                .accessibilityHidden(true)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button { onNavigate(.addTrip) } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
                .accessibilityLabel("Add new trip")

                Button { onNavigate(.settings) } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.white.opacity(0.85))
                        .font(.title3)
                }
                .accessibilityLabel("Settings")
            }
        }
    }
}
