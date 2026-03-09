import SwiftUI

struct TripDetailView: View {
    let tripID: UUID
    let router: AppNavigationRouter

    @Environment(AppContainer.self) private var appContainer
    @Environment(\.parkThemeProvider) private var themeProvider
    @State private var viewModel: TripDetailViewModel?
    @State private var showCelebration = false
    @State private var isInitialLoad = true

    var body: some View {
        ZStack {
            GradientBackgroundView()
            StarFieldView()

            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar { toolbarContent }
        .task {
            let vm = TripDetailViewModel.make(tripID: tripID, from: appContainer)
            viewModel = vm
            await vm.onAppear()
            isInitialLoad = false
        }
        .onAppear {
            guard !isInitialLoad, let vm = viewModel else { return }
            Task { await vm.onAppear() }
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

    // MARK: - Content

    @ViewBuilder
    private func contentView(vm: TripDetailViewModel) -> some View {
        switch vm.viewState {
        case .loading:
            ProgressView().tint(.white)

        case .notFound:
            VStack(spacing: 16) {
                Text("Trip not found")
                    .font(DTDFont.titlePrimary)
                    .foregroundStyle(.white)
                Button("Go Back") { router.navigateBack() }
                    .foregroundStyle(Color.disneyGold)
            }

        case .error(let message):
            VStack(spacing: 16) {
                Text("Error: \(message)")
                    .font(DTDFont.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Go Back") { router.navigateBack() }
                    .foregroundStyle(Color.disneyGold)
            }

        case .loaded(let trip, let content):
            ScrollView {
                VStack(spacing: 24) {
                    // Large castle hero.
                    CastleSilhouetteView(
                        park: trip.primaryPark,
                        size: 180,
                        color: .white,
                        opacity: 0.55
                    )
                    .padding(.top, 24)

                    // Trip name.
                    Text(trip.name)
                        .font(DTDFont.displayMedium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Full countdown display.
                    CountdownHeroView(
                        trip: trip,
                        onTap: {}   // No-op — already on detail screen.
                    )

                    // Trip metadata.
                    tripMetadata(trip: trip)

                    // Content feed.
                    if !content.isEmpty {
                        contentFeed(content: content)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
    }

    @ViewBuilder
    private func tripMetadata(trip: Trip) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 32) {
                metadataPill(
                    icon: "calendar",
                    label: "Start",
                    value: trip.startDate.dayMonthDateString
                )
                metadataPill(
                    icon: "calendar.badge.checkmark",
                    label: "End",
                    value: trip.endDate.dayMonthDateString
                )
                metadataPill(
                    icon: "moon.zzz",
                    label: "Nights",
                    value: "\(trip.durationDays)"
                )
            }

            if trip.parks.count > 1 {
                HStack(spacing: 8) {
                    ForEach(trip.parks) { park in
                        Text(park.displayName)
                            .font(DTDFont.captionBold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(trip.colorPalette.primary.opacity(0.4))
                            .clipShape(Capsule())
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Parks: \(trip.parks.map(\.displayName).joined(separator: ", "))")
            }
        }
        .padding(.horizontal, 20)
    }

    private func metadataPill(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Color.disneyGold)
                .font(.title3)
            Text(value)
                .font(DTDFont.bodyMedium)
                .foregroundStyle(.white)
            Text(label)
                .font(DTDFont.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    @ViewBuilder
    private func contentFeed(content: [DailyContent]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Disney Tips for Your Trip")
                .font(DTDFont.titleSecondary)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            ForEach(content) { item in
                DailyContentCardView(content: item)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                router.navigate(to: .editTrip(tripID: tripID))
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.white)
                    .font(.title3)
            }
            .accessibilityLabel("Edit trip")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TripDetailView(tripID: Trip.preview.id, router: AppNavigationRouter())
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
            .environment(\.parkThemeProvider, ParkThemeProvider.preview())
    }
}
