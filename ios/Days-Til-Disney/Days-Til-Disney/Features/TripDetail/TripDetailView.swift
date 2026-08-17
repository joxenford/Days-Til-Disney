import SwiftUI

struct TripDetailView: View {
    let tripID: UUID
    let router: AppNavigationRouter

    @Environment(AppContainer.self) private var appContainer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TripDetailViewModel?
    @State private var isInitialLoad = true
    @State private var showShareSheet = false
    @State private var isNotesExpanded = false

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView().tint(DTDColor.accentInteractive)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        // Keep the flat bg showing through — no translucent material bar.
        .toolbarBackground(.hidden, for: .navigationBar)
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
            // Reaching a milestone pushes the full-bleed MilestoneView (replaces the dropped
            // particle overlay). Haptic fires the instant it resolves, then the flag clears.
            guard let event = newValue else { return }
            MilestoneHaptic.fire(event.celebrationType)
            router.navigate(to: .milestone(tripID: event.tripID))
            viewModel?.dismissMilestone()
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
    }

    // MARK: - Content

    @ViewBuilder
    private func contentView(vm: TripDetailViewModel) -> some View {
        switch vm.viewState {
        case .loading:
            VStack(spacing: DTDSpacing.x7) {
                ProgressView()
                    .tint(DTDColor.accentInteractive)
                    .scaleEffect(1.4)
                Text("Loading your magic...")
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
            }

        case .notFound:
            VStack(spacing: DTDSpacing.x7) {
                Text("Trip not found")
                    .font(DTDFont.title)
                    .foregroundStyle(DTDColor.textPrimary)
                DTDButton("Go back", full: false) { router.navigateBack() }
            }

        case .error(let message):
            VStack(spacing: DTDSpacing.x11) {
                Text("Something went wrong")
                    .font(DTDFont.title)
                    .foregroundStyle(DTDColor.textPrimary)
                Text(message)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                DTDButton("Go back", full: false) { router.navigateBack() }
            }

        case .loaded(let trip, let content):
            ScrollView {
                VStack(spacing: DTDSpacing.tileGap) {
                    heroPanel(trip: trip)
                    metricTiles(trip: trip)

                    // Packing list shortcut — hidden during the trip (not useful in the park).
                    if !trip.isOngoing {
                        packingRow(trip: trip)
                    }

                    // Live park data card — only shown while the trip is in progress.
                    if trip.isOngoing {
                        LiveParkCard(
                            trip: trip,
                            onViewAll: {
                                router.navigate(to: .parkDashboard(
                                    tripID: trip.id,
                                    park: trip.primaryPark,
                                    allParks: trip.parks
                                ))
                            }
                        )
                    }

                    notesCard(trip: trip, vm: vm)

                    if !content.isEmpty {
                        tipsSection(content: content)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, DTDSpacing.gutter)
                .padding(.top, DTDSpacing.x7)
            }
        }
    }

    // MARK: - Hero panel (the one ParkPanel)

    private func heroPanel(trip: Trip) -> some View {
        ParkPanel(park: trip.primaryPark, label: trip.primaryPark.displayName.uppercased()) {
            VStack(alignment: .leading, spacing: DTDSpacing.x5) {
                CountdownNumeral(value: trip.daysUntilStart, unit: "days", size: .screen)

                Text(trip.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .tracking(-0.4)
                    .foregroundStyle(.white)

                if trip.parks.count > 1 {
                    HStack(spacing: DTDSpacing.x2) {
                        ForEach(trip.parks) { park in
                            Text(park.displayName)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, DTDSpacing.x5)
                                .background(DTDColor.onParkBadge)
                                .clipShape(Capsule())
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Parks: \(trip.parks.map(\.displayName).joined(separator: ", "))")
                }
            }
        }
    }

    // MARK: - Metric tiles (START / END / NIGHTS)

    private func metricTiles(trip: Trip) -> some View {
        HStack(spacing: DTDSpacing.tileGap) {
            metricTile(label: "Start", value: trip.startDate.dayMonthDateString)
            metricTile(label: "End", value: trip.endDate.dayMonthDateString)
            metricTile(label: "Nights", value: "\(trip.durationDays)")
        }
    }

    private func metricTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x1) {
            SectionLabel(label)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(DTDColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x7)
        .padding(.horizontal, DTDSpacing.x8)
        .background(DTDColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous))
    }

    // MARK: - Packing row

    private func packingRow(trip: Trip) -> some View {
        let items = trip.packingItems ?? []
        let total = items.count
        let packed = items.filter(\.isChecked).count

        return Button {
            router.navigate(to: .packingList(tripID: trip.id))
        } label: {
            HStack(spacing: DTDSpacing.x6) {
                VStack(alignment: .leading, spacing: DTDSpacing.x2) {
                    HStack {
                        Text("Packing list")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(DTDColor.textPrimary)
                        Spacer(minLength: 0)
                        if total > 0 {
                            Text("\(packed) of \(total)")
                                .font(DTDFont.prose)
                                .fontWeight(.semibold)
                                .foregroundStyle(DTDColor.textMuted)
                        }
                    }
                    if total > 0 {
                        DTDProgressBar(value: packed, total: total)
                    }
                }
                Text("›")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundStyle(DTDColor.textFaint)
            }
            .padding(.vertical, DTDSpacing.x8)
            .padding(.horizontal, DTDSpacing.x9)
            .background(DTDColor.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Packing list\(total == 0 ? "" : ", \(packed) of \(total) packed")")
        .accessibilityHint("Navigate to packing checklist")
    }

    // MARK: - Notes card

    @ViewBuilder
    private func notesCard(trip: Trip, vm: TripDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                    isNotesExpanded.toggle()
                }
            } label: {
                HStack {
                    SectionLabel("Trip notes")
                    Spacer(minLength: 0)
                    if !trip.notes.isEmpty && !isNotesExpanded {
                        Circle()
                            .fill(DTDColor.gold)
                            .frame(width: 8, height: 8)
                            .accessibilityHidden(true)
                    }
                    Text("›")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(DTDColor.textFaint)
                        .rotationEffect(.degrees(isNotesExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isNotesExpanded ? "Trip Notes, collapse" : "Trip Notes, \(trip.notes.isEmpty ? "empty" : "has content"), expand")

            if isNotesExpanded {
                ZStack(alignment: .topLeading) {
                    if trip.notes.isEmpty {
                        Text("Jot down reservation numbers, dining bookings, or anything you don't want to forget…")
                            .font(DTDFont.prose)
                            .foregroundStyle(DTDColor.textFaint)
                            .padding(.horizontal, 6)
                            .padding(.top, 10)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: Binding(
                        get: { trip.notes },
                        set: { vm.updateNotes($0) }
                    ))
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 120, alignment: .topLeading)
                    .tint(DTDColor.accentInteractive)
                }
                .padding(.top, DTDSpacing.x5)
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if !trip.notes.isEmpty {
                Text(trip.notes)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textPrimary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DTDSpacing.x5)
            }
        }
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }

    // MARK: - Tips

    private func tipsSection(content: [DailyContent]) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x5) {
            SectionLabel("Tips for this trip")
                .padding(.top, DTDSpacing.x2)
            ForEach(content) { item in
                DailyContentCardView(content: item)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: DTDSpacing.x3) {
                // Share button — visible only when the trip is loaded.
                if case .loaded(let trip, _) = viewModel?.viewState {
                    Button {
                        viewModel?.generateShareImage(for: trip)
                    } label: {
                        if viewModel?.isGeneratingShareImage == true {
                            ProgressView().tint(DTDColor.textPrimary)
                        } else {
                            Text("Share")
                                .font(DTDFont.body)
                                .foregroundStyle(DTDColor.textPrimary)
                        }
                    }
                    .accessibilityLabel("Share countdown")
                    .disabled(viewModel?.isGeneratingShareImage == true)
                }

                Button {
                    router.navigate(to: .editTrip(tripID: tripID))
                } label: {
                    Text("Edit")
                        .font(DTDFont.body)
                        .foregroundStyle(DTDColor.textPrimary)
                }
                .accessibilityLabel("Edit trip")
            }
        }
    }
}

// MARK: - UIActivityViewController wrapper

/// A thin UIViewControllerRepresentable that presents UIActivityViewController
/// for sharing a UIImage.
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
