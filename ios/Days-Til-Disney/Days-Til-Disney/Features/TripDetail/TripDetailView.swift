import SwiftUI

struct TripDetailView: View {
    let tripID: UUID
    let router: AppNavigationRouter

    @Environment(AppContainer.self) private var appContainer
    @Environment(\.parkThemeProvider) private var themeProvider
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TripDetailViewModel?
    @State private var showCelebration = false
    @State private var isInitialLoad = true
    @State private var showShareSheet = false
    @State private var isNotesExpanded = false

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
        // C-1: Prevent the system from inserting a translucent material bar over the gradient.
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.3)) {
                showCelebration = newValue != nil
            }
        }
        .onChange(of: showCelebration) { _, isShown in
            // When the overlay is dismissed (by tapping or the button), clear the VM's state.
            if !isShown { viewModel?.dismissMilestone() }
        }
        // When a share image is ready, present the share sheet.
        .onChange(of: viewModel?.shareImage) { _, image in
            if image != nil { showShareSheet = true }
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            viewModel?.clearShareImage()
        }) {
            if let image = viewModel?.shareImage {
                ShareSheet(image: image)
                    .ignoresSafeArea()
            }
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
                    // C-2: Disable hit-testing so the hero's button tap target is dead on
                    // this screen — the user is already on the detail, there's nowhere to navigate.
                    CountdownHeroView(
                        trip: trip,
                        onTap: {}   // No-op — already on detail screen.
                    )
                    .allowsHitTesting(false)

                    // Trip metadata.
                    tripMetadata(trip: trip)

                    // Packing list shortcut.
                    packingListButton(trip: trip)

                    // Notes / journal section.
                    notesSection(trip: trip, vm: vm)

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

    // MARK: - Packing list button

    @ViewBuilder
    private func packingListButton(trip: Trip) -> some View {
        Button {
            router.navigate(to: .packingList(tripID: trip.id))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bag.fill")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.disneyGold)
                    .frame(width: 22)
                    .accessibilityHidden(true)

                Text("Packing List")
                    .font(DTDFont.titleSecondary)
                    .foregroundStyle(.white)

                Spacer()

                // Progress badge if items exist.
                let items = trip.packingItems ?? []
                let checkedCount = items.filter(\.isChecked).count
                let totalCount = items.count
                if totalCount > 0 {
                    Text("\(checkedCount)/\(totalCount)")
                        .font(DTDFont.captionBold)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(.white.opacity(0.12))
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .padding(.horizontal, 20)
        .accessibilityLabel("Packing List\((trip.packingItems ?? []).isEmpty ? "" : ", \((trip.packingItems ?? []).filter(\.isChecked).count) of \((trip.packingItems ?? []).count) packed")")
        .accessibilityHint("Navigate to packing checklist")
    }

    // MARK: - Notes section

    @ViewBuilder
    private func notesSection(trip: Trip, vm: TripDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row — always visible, tapping expands/collapses.
            Button {
                withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                    isNotesExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "note.text")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.disneyGold)
                        .accessibilityHidden(true)

                    Text("Trip Notes")
                        .font(DTDFont.titleSecondary)
                        .foregroundStyle(.white)

                    Spacer()

                    // Badge showing notes are present when collapsed.
                    if !trip.notes.isEmpty && !isNotesExpanded {
                        Circle()
                            .fill(Color.disneyGold)
                            .frame(width: 8, height: 8)
                            .accessibilityHidden(true)
                    }

                    Image(systemName: isNotesExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isNotesExpanded ? "Trip Notes, collapse" : "Trip Notes, \(trip.notes.isEmpty ? "empty" : "has content"), expand")

            if isNotesExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // Editable text area.
                    ZStack(alignment: .topLeading) {
                        // Placeholder text shown when notes are empty.
                        if trip.notes.isEmpty {
                            Text("Jot down reservation numbers, packing lists, dining bookings, or anything you don't want to forget...")
                                .font(DTDFont.body)
                                .foregroundStyle(.white.opacity(0.35))
                                .padding(.horizontal, 12)
                                .padding(.top, 10)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: Binding(
                            get: { trip.notes },
                            set: { vm.updateNotes($0) }
                        ))
                        .font(DTDFont.body)
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minHeight: 120, alignment: .topLeading)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    if !trip.notes.isEmpty {
                        Text("\(trip.notes.count) characters")
                            .font(DTDFont.caption)
                            .foregroundStyle(.white.opacity(0.35))
                            .padding(.horizontal, 20)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .padding(.horizontal, 20)
    }

    private func metadataPill(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Color.disneyGold)
                .font(.title3)
                .accessibilityHidden(true)
            Text(value)
                .font(DTDFont.bodyMedium)
                .foregroundStyle(.white)
            Text(label)
                .font(DTDFont.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
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
            HStack(spacing: 4) {
                // Share button — visible only when the trip is loaded.
                if case .loaded(let trip, _) = viewModel?.viewState {
                    Button {
                        viewModel?.generateShareImage(for: trip)
                    } label: {
                        if viewModel?.isGeneratingShareImage == true {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }
                    }
                    .accessibilityLabel("Share countdown")
                    .disabled(viewModel?.isGeneratingShareImage == true)
                }

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
}

// MARK: - UIActivityViewController wrapper

/// A thin UIViewControllerRepresentable that presents UIActivityViewController
/// for sharing a UIImage. We use UIKit here because UIActivityViewController
/// gives full OS share sheet capability (AirDrop, Save to Photos, Messages, etc.)
/// that ShareLink cannot replicate for arbitrary image data.
private struct ShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TripDetailView(tripID: Trip.preview.id, router: AppNavigationRouter())
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
            .environment(\.parkThemeProvider, ParkThemeProvider.preview())
    }
}
