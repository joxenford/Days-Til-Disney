import SwiftUI

struct HomeView: View {
    @Environment(AppContainer.self) private var appContainer
    @Environment(\.parkTheme) private var themeProvider
    @State private var viewModel: HomeViewModel?
    @State private var showCelebration = false
    @State private var pastTripsExpanded = false

    let router: AppNavigationRouter

    var body: some View {
        ZStack {
            // Layer 0: Park-themed gradient fills the entire screen.
            GradientBackgroundView()

            // Layer 1: Star field (visible at dusk/night, invisible during the day).
            StarFieldView()

            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            // Create the VM once on first appearance and load data.
            let vm = HomeViewModel.make(from: appContainer)
            viewModel = vm
            await vm.onAppear()
        }
        .onAppear {
            // Re-load data when returning from a navigation push (e.g. after adding/editing a trip).
            // .task only runs once; .onAppear fires every time the view becomes visible.
            guard let vm = viewModel else { return }
            Task { await vm.onRefresh() }
        }
        .onChange(of: viewModel?.activeMilestone) { _, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                showCelebration = newValue != nil
            }
        }
        .onChange(of: showCelebration) { _, isShown in
            // When the overlay is dismissed (by tapping or the button), clear the VM's state.
            if !isShown { viewModel?.dismissMilestone() }
        }
        .overlay {
            if showCelebration, let vm = viewModel, let event = vm.activeMilestone {
                CelebrationOverlay(event: event, isPresented: $showCelebration)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
    }

    // MARK: - Content states

    @ViewBuilder
    private func contentView(vm: HomeViewModel) -> some View {
        switch vm.viewState {
        case .loading:
            loadingView

        case .empty:
            EmptyTripsView {
                router.navigate(to: .addTrip)
            }

        case .loaded(let primary, let secondary, let past):
            loadedView(vm: vm, primary: primary, secondary: secondary, past: past)

        case .error(let message):
            ErrorStateView(message: message) {
                Task { await vm.onRefresh() }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading your magic...")
                .font(DTDFont.body)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    @ViewBuilder
    private func loadedView(vm: HomeViewModel, primary: Trip?, secondary: [Trip], past: [Trip]) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Hero countdown for primary trip.
                if let primary {
                    CountdownHeroView(
                        trip: primary,
                        onTap: { router.navigate(to: .tripDetail(tripID: primary.id)) },
                        onAddTrip: { router.navigate(to: .addTrip) }
                    )
                }

                // Daily content card.
                if let content = vm.dailyContent {
                    DailyContentCardView(content: content)
                        .padding(.horizontal, 20)
                }

                // Secondary trip cards (upcoming and ongoing).
                if !secondary.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other Trips")
                            .font(DTDFont.titleSecondary)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)

                        ForEach(secondary) { trip in
                            TripCardView(
                                trip: trip,
                                onTap: { router.navigate(to: .tripDetail(tripID: trip.id)) },
                                onSetPrimary: { Task { await vm.setPrimaryTrip(id: trip.id) } },
                                onEdit: { router.navigate(to: .editTrip(tripID: trip.id)) },
                                onDelete: { Task { await vm.deleteTrip(id: trip.id) } }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }

                // Collapsible past trips section.
                if !past.isEmpty {
                    pastTripsSection(vm: vm, past: past)
                }

                // Bottom padding for tab bar / home indicator.
                Spacer().frame(height: 40)
            }
            .padding(.top, 16)
        }
        .refreshable { await vm.onRefresh() }
    }

    @ViewBuilder
    private func pastTripsSection(vm: HomeViewModel, past: [Trip]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Disclosure header.
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
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

            // Expandable trip cards.
            if pastTripsExpanded {
                ForEach(past) { trip in
                    TripCardView(
                        trip: trip,
                        onTap: { router.navigate(to: .tripDetail(tripID: trip.id)) },
                        onSetPrimary: { Task { await vm.setPrimaryTrip(id: trip.id) } },
                        onEdit: { router.navigate(to: .editTrip(tripID: trip.id)) },
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
            Text("Days 'Til Disney")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button {
                    router.navigate(to: .addTrip)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
                .accessibilityLabel("Add new trip")

                Button {
                    router.navigate(to: .settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.white.opacity(0.85))
                        .font(.title3)
                }
                .accessibilityLabel("Settings")
            }
        }
    }
}

// MARK: - Empty state

private struct EmptyTripsView: View {
    let onAddTrip: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            CastleSilhouetteView(
                park: .magicKingdom,
                size: 160,
                color: .white,
                opacity: 0.85,
                showGlow: true,
                glowColor: Color.magicSparkle
            )

            VStack(spacing: 12) {
                Text("Your adventure awaits!")
                    .font(DTDFont.titlePrimary)
                    .foregroundStyle(.white)

                Text("Add your first Disney trip to start the countdown.")
                    .font(DTDFont.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: onAddTrip) {
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
    }
}

// MARK: - Error state

private struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
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

            Button(action: onRetry) {
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

// MARK: - Preview

#Preview {
    HomeView(router: AppNavigationRouter())
        .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
        .environment(\.parkTheme, ParkThemeProvider.preview(park: .magicKingdom))
}
