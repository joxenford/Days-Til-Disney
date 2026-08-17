import SwiftUI

// MARK: - Main view

struct ParkDashboardView: View {
    let tripID: UUID
    let parks: [DisneyPark]
    let initialPark: DisneyPark

    @Environment(AppContainer.self) private var appContainer

    @State private var viewModel: ParkDashboardViewModel?

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            if let vm = viewModel {
                dashboardContent(vm: vm)
            } else {
                ProgressView().tint(DTDColor.accentInteractive)
            }
        }
        .navigationTitle("Wait times")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar { toolbarContent }
        .task {
            let vm = ParkDashboardViewModel.make(
                tripID: tripID,
                parks: parks,
                initialPark: initialPark,
                from: appContainer
            )
            viewModel = vm
            await vm.onAppear()
        }
    }

    // MARK: - Content router

    @ViewBuilder
    private func dashboardContent(vm: ParkDashboardViewModel) -> some View {
        switch vm.viewState {
        case .loading:
            loadingView
        case .error(let message):
            errorView(message: message, vm: vm)
        case .loaded:
            loadedView(vm: vm)
        }
    }

    private var loadingView: some View {
        VStack(spacing: DTDSpacing.x7) {
            ProgressView()
                .tint(DTDColor.accentInteractive)
                .scaleEffect(1.4)
            Text("Loading live park data...")
                .font(DTDFont.prose)
                .foregroundStyle(DTDColor.textMuted)
        }
    }

    private func errorView(message: String, vm: ParkDashboardViewModel) -> some View {
        VStack(spacing: DTDSpacing.x11) {
            Text("Live data unavailable")
                .font(DTDFont.title)
                .foregroundStyle(DTDColor.textPrimary)
            Text(message)
                .font(DTDFont.prose)
                .foregroundStyle(DTDColor.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            DTDButton("Try again", full: false) {
                Task { await vm.refresh() }
            }
        }
    }

    // MARK: - Loaded

    @ViewBuilder
    private func loadedView(vm: ParkDashboardViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: DTDSpacing.tileGap) {
                if vm.parks.count > 1 {
                    parkPicker(vm: vm)
                }

                summaryPanel(vm: vm)
                sortPills(vm: vm)
                attractionsSection(vm: vm)

                if !vm.shows.isEmpty {
                    showsSection(vm: vm)
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, DTDSpacing.gutter)
            .padding(.top, DTDSpacing.x7)
        }
        .refreshable { await vm.refresh() }
    }

    // MARK: - Park picker

    private func parkPicker(vm: ParkDashboardViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DTDSpacing.x3) {
                ForEach(vm.parks) { park in
                    DTDChip(park.displayName, selected: park == vm.selectedPark) {
                        vm.selectPark(park)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Summary panel (deep tone — the single sanctioned fixed-scheme site)

    private func summaryPanel(vm: ParkDashboardViewModel) -> some View {
        let shortest = vm.sortedAttractions
            .filter { $0.status == .operating }
            .compactMap { $0.standbyWaitMinutes }
            .min()

        return HStack(spacing: 0) {
            summaryStat(value: "\(vm.operatingCount)", label: "OPEN")
            summaryStat(value: vm.averageWait.map { "\($0)" } ?? "—", label: "AVG MIN")
            summaryStat(value: shortest.map { "\($0)" } ?? "—", label: "SHORTEST")
        }
        .padding(.vertical, DTDSpacing.x9)
        .padding(.horizontal, DTDSpacing.x11)
        // The dashboard always wants the deep tone regardless of app scheme — a deliberate
        // constant, NOT a colorScheme branch (the one sanctioned fixed-scheme panel).
        .background(vm.selectedPark.colorPalette.panelColor(for: .dark))
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.card, style: .continuous))
    }

    private func summaryStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .tracking(-1.5)
                .foregroundStyle(.white)
            Text(label)
                .font(DTDFont.labelSmall)
                .tracking(0.6)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sort pills

    private func sortPills(vm: ParkDashboardViewModel) -> some View {
        HStack(spacing: DTDSpacing.x3) {
            ForEach(AttractionSortOrder.allCases) { order in
                let active = vm.sortOrder == order
                Button {
                    vm.sortOrder = order
                } label: {
                    Text(order.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(active ? DTDColor.goldInk : DTDColor.textMuted)
                        .padding(.vertical, DTDSpacing.x3)
                        .padding(.horizontal, DTDSpacing.x6)
                        .background(active ? DTDColor.gold : DTDColor.surface)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(DTDPressStyle())
                .accessibilityAddTraits(active ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Attractions

    @ViewBuilder
    private func attractionsSection(vm: ParkDashboardViewModel) -> some View {
        let attractions = vm.sortedAttractions
        if attractions.isEmpty {
            Text("No attraction data available.")
                .font(DTDFont.prose)
                .foregroundStyle(DTDColor.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: DTDSpacing.x4) {
                ForEach(attractions) { attraction in
                    AttractionRow(attraction: attraction)
                }
            }
        }
    }

    // MARK: - Shows

    private func showsSection(vm: ParkDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x4) {
            SectionLabel("Shows")
                .padding(.top, DTDSpacing.x2)
            ForEach(vm.shows) { show in
                ShowRow(show: show)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            DTDIconButton(glyph: "↻", accessibilityLabel: "Refresh") {
                Task { await viewModel?.refresh() }
            }
        }
    }
}

// MARK: - Attraction row

private struct AttractionRow: View {
    let attraction: LiveAttraction

    var body: some View {
        HStack(spacing: DTDSpacing.x5) {
            VStack(alignment: .leading, spacing: 2) {
                Text(attraction.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(attraction.status == .operating ? DTDColor.textPrimary : DTDColor.textFaint)
                    .lineLimit(2)
                if let meta {
                    Text(meta)
                        .font(DTDFont.prose)
                        .foregroundStyle(isGoldMeta ? DTDColor.goldLabel : DTDColor.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            WaitPill(minutes: attraction.standbyWaitMinutes, status: attraction.status)
        }
        .padding(.vertical, DTDSpacing.x7)
        .padding(.horizontal, DTDSpacing.x8)
        .background(DTDColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Only renders fields `LiveAttraction` actually has — no land/area field.
    private var meta: String? {
        if let ll = attraction.lightningLaneReturnWindow {
            return "Lightning Lane \(ll.displayString)"
        }
        if let paid = attraction.paidLightningLanePrice {
            return "Premier Access \(paid.displayPrice)"
        }
        return nil
    }

    private var isGoldMeta: Bool {
        attraction.lightningLaneReturnWindow != nil || attraction.paidLightningLanePrice != nil
    }

    private var accessibilityLabel: String {
        var parts = [attraction.name]
        switch attraction.status {
        case .operating:
            if let wait = attraction.standbyWaitMinutes {
                parts.append("\(wait) minute wait")
            } else {
                parts.append("walk-on, no wait")
            }
        case .closed:        parts.append("closed")
        case .refurbishment: parts.append("under refurbishment")
        case .down:          parts.append("temporarily down")
        }
        if let ll = attraction.lightningLaneReturnWindow {
            parts.append("Lightning Lane, return \(ll.displayString)")
        }
        return parts.joined(separator: ". ")
    }
}

// MARK: - Show row

private struct ShowRow: View {
    let show: LiveShow

    var body: some View {
        HStack(spacing: DTDSpacing.x5) {
            VStack(alignment: .leading, spacing: 2) {
                Text(show.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(show.status == .operating ? DTDColor.textPrimary : DTDColor.textFaint)
                    .lineLimit(2)
                if let next = show.nextShowTime {
                    Text("Next \(next.formatted(date: .omitted, time: .shortened))")
                        .font(DTDFont.prose)
                        .foregroundStyle(DTDColor.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if show.status != .operating {
                Text(show.status == .refurbishment ? "REFURB" : show.status.displayLabel.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(DTDColor.textMuted)
                    .padding(.vertical, 6)
                    .padding(.horizontal, DTDSpacing.x5)
                    .background(DTDColor.surfaceRaised)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, DTDSpacing.x7)
        .padding(.horizontal, DTDSpacing.x8)
        .background(DTDColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel({
            var parts = [show.name]
            if let next = show.nextShowTime {
                parts.append("next show at \(next.formatted(date: .omitted, time: .shortened))")
            }
            return parts.joined(separator: ". ")
        }())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ParkDashboardView(
            tripID: Trip.previewToday.id,
            parks: [.magicKingdom, .epcot],
            initialPark: .magicKingdom
        )
        .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
        .environment(\.parkThemeProvider, ParkThemeProvider.preview())
    }
}
