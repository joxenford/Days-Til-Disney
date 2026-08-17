import SwiftUI

struct HomeView: View {
    @Environment(AppContainer.self) private var appContainer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: HomeViewModel?
    @State private var showCelebration = false
    @State private var pastTripsExpanded = false
    /// Tracks whether the initial load via `.task` has completed.
    /// `.onAppear` skips the first fire so only return-from-navigation refreshes run.
    @State private var isInitialLoad = true

    let router: AppNavigationRouter

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView()
                        .tint(DTDColor.accentInteractive)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // Keep the flat bg showing through — no translucent material bar.
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar { toolbarContent }
        .task {
            // Create the VM once on first appearance and load data.
            let vm = HomeViewModel.make(from: appContainer)
            viewModel = vm
            await vm.onAppear()
            isInitialLoad = false
        }
        .onAppear {
            // Re-load data when returning from a navigation push (e.g. after adding/editing a trip).
            // .task only runs once; .onAppear fires every time the view becomes visible.
            // isInitialLoad guards against a redundant refresh racing with the .task load.
            guard !isInitialLoad, let vm = viewModel else { return }
            Task { await vm.onRefresh() }
        }
        .onChange(of: viewModel?.activeMilestone) { _, newValue in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.3)) {
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
                .tint(DTDColor.accentInteractive)
                .scaleEffect(1.4)
            Text("Loading your magic...")
                .font(DTDFont.prose)
                .foregroundStyle(DTDColor.textMuted)
        }
    }

    @ViewBuilder
    private func loadedView(vm: HomeViewModel, primary: Trip?, secondary: [Trip], past: [Trip]) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Hero countdown for primary trip, with its packing + milestone stat tiles.
                if let primary {
                    CountdownHeroView(
                        trip: primary,
                        onTap: { router.navigate(to: .tripDetail(tripID: primary.id)) },
                        onAddTrip: { router.navigate(to: .addTrip) }
                    )

                    statTiles(for: primary)
                        .padding(.horizontal, 20)
                }

                // Daily content card.
                if let content = vm.dailyContent {
                    DailyContentCardView(content: content)
                        .padding(.horizontal, 20)
                }

                // Secondary trip cards (upcoming and ongoing).
                if !secondary.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("Other trips")
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
                withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.75)) {
                    pastTripsExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    SectionLabel("Past trips (\(past.count))")

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(DTDColor.textFaint)
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
            // Plain wordmark. Fixed 19pt (never grows with Dynamic Type, so it can't
            // clip at AX5) and left queryable so the UITest can find the staticText.
            Text("Countdown to Magic")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .tracking(-0.3)
                .foregroundStyle(DTDColor.textPrimary)
                .lineLimit(1)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: DTDSpacing.x3) {
                DTDIconButton(glyph: "+", accessibilityLabel: "Add new trip", tone: .loud) {
                    router.navigate(to: .addTrip)
                }
                // The "•••" button is the toolbar Settings entry — label kept as "Settings".
                DTDIconButton(glyph: "•••", accessibilityLabel: "Settings") {
                    router.navigate(to: .settings)
                }
            }
        }
    }

    // MARK: - Stat tiles (Home)

    /// The Packed + Next-up tile pair beneath the hero. Both derive from the trip
    /// (packing items / milestone thresholds) — no ViewModel API added.
    @ViewBuilder
    private func statTiles(for trip: Trip) -> some View {
        HStack(spacing: DTDSpacing.tileGap) {
            packedTile(for: trip)
            nextUpTile(for: trip)
        }
    }

    @ViewBuilder
    private func packedTile(for trip: Trip) -> some View {
        let items = trip.packingItems ?? []
        let total = items.count
        let packed = items.filter(\.isChecked).count

        Button {
            router.navigate(to: .packingList(tripID: trip.id))
        } label: {
            StatTile(label: "Packed",
                     value: "\(packed)",
                     sub: total > 0 ? "/\(total)" : nil) {
                if total > 0 {
                    DTDProgressBar(value: packed, total: total).padding(.top, DTDSpacing.x1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func nextUpTile(for trip: Trip) -> some View {
        // Next milestone the countdown will reach (largest threshold still below today's count).
        // Non-navigating in Wave A — the milestone screen + route land in Phase 4.10.
        let daysOut = trip.daysUntilStart
        if let next = Milestone.all.filter({ $0.daysOut < daysOut }).max(by: { $0.daysOut < $1.daysOut }) {
            StatTile(label: "Next up",
                     value: "\(next.daysOut)",
                     caption: "days → \(next.title)")
        } else {
            StatTile(label: "Next up",
                     value: "—",
                     caption: trip.isPast ? "trip complete" : "you're there now!")
        }
    }
}

// MARK: - Empty state

private struct EmptyTripsView: View {
    let onAddTrip: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Neutral surface panel (no park colour when there's nothing to count down to).
            VStack(alignment: .leading, spacing: 0) {
                Text("00")
                    .dtdNumeral(.screen)
                    .foregroundStyle(DTDColor.textFaint)

                Text("Nothing to count down to — yet.")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .tracking(-0.6)
                    .foregroundStyle(DTDColor.textPrimary)
                    .padding(.top, DTDSpacing.x7)

                Text("Pick your park and your dates. Everything else fills itself in.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(4)
                    .foregroundStyle(DTDColor.textMuted)
                    .padding(.top, DTDSpacing.x4)

                DTDButton("Add a trip", action: onAddTrip)
                    .padding(.top, DTDSpacing.x9)
                    .accessibilityLabel("Add a trip")
            }
            .padding(.vertical, DTDSpacing.x14)
            .padding(.horizontal, DTDSpacing.x12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DTDRadius.hero, style: .continuous)
                    .fill(DTDColor.surface)
            )

            HStack(spacing: DTDSpacing.tileGap) {
                StatTile(label: "Parks", value: "12", caption: "across 6 resorts")
                StatTile(label: "Tips", value: "1/day", caption: "once a trip exists")
            }
        }
        .padding(.horizontal, DTDSpacing.gutter)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                .foregroundStyle(DTDColor.textMuted)

            Text("Something went wrong")
                .font(DTDFont.title)
                .foregroundStyle(DTDColor.textPrimary)

            Text(message)
                .font(DTDFont.prose)
                .foregroundStyle(DTDColor.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            DTDButton("Try again", full: false, action: onRetry)
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView(router: AppNavigationRouter())
        .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
        .environment(\.parkThemeProvider, ParkThemeProvider.preview(park: .magicKingdom))
}
