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
                ProgressView().tint(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading live park data...")
                .font(DTDFont.body)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    // MARK: - Error

    private func errorView(message: String, vm: ParkDashboardViewModel) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.55))
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("Live Data Unavailable")
                    .font(DTDFont.titlePrimary)
                    .foregroundStyle(.white)
                Text(message)
                    .font(DTDFont.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task { await vm.refresh() }
            } label: {
                Text("Try Again")
                    .font(DTDFont.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.disneyGold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Loaded

    @ViewBuilder
    private func loadedView(vm: ParkDashboardViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Park picker for multi-park trips.
                if vm.parks.count > 1 {
                    parkPicker(vm: vm)
                }

                // Summary banner.
                summaryBanner(vm: vm)

                // Sort picker.
                sortPicker(vm: vm)

                // Attractions section.
                attractionsSection(vm: vm)

                // Shows section.
                if !vm.shows.isEmpty {
                    showsSection(vm: vm)
                }

                Spacer().frame(height: 40)
            }
            .padding(.top, 16)
        }
        .refreshable {
            await vm.refresh()
        }
    }

    // MARK: - Park picker

    private func parkPicker(vm: ParkDashboardViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.parks) { park in
                    let isSelected = park == vm.selectedPark
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.selectPark(park)
                        }
                    } label: {
                        Text(park.displayName)
                            .font(DTDFont.captionBold)
                            .foregroundStyle(isSelected ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.disneyGold : Color.white.opacity(0.15))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Summary banner

    private func summaryBanner(vm: ParkDashboardViewModel) -> some View {
        HStack(spacing: 0) {
            summaryStatCell(
                icon: "figure.walk",
                value: "\(vm.operatingCount)",
                label: "Rides Open"
            )

            Divider()
                .frame(height: 36)
                .background(.white.opacity(0.2))

            if let avg = vm.averageWait {
                summaryStatCell(
                    icon: "clock.fill",
                    value: "\(avg) min",
                    label: "Avg Wait"
                )
            } else {
                summaryStatCell(
                    icon: "clock.fill",
                    value: "—",
                    label: "Avg Wait"
                )
            }

            if let updated = vm.lastUpdated {
                Divider()
                    .frame(height: 36)
                    .background(.white.opacity(0.2))

                summaryStatCell(
                    icon: "arrow.clockwise",
                    value: updated.formatted(date: .omitted, time: .shortened),
                    label: "Updated"
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel({
            var parts = ["\(vm.operatingCount) rides open"]
            if let avg = vm.averageWait { parts.append("average wait \(avg) minutes") }
            return parts.joined(separator: ", ")
        }())
    }

    private func summaryStatCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(Color.disneyGold)
                .accessibilityHidden(true)
            Text(value)
                .font(DTDFont.bodyMedium)
                .foregroundStyle(.white)
            Text(label)
                .font(DTDFont.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sort picker

    private func sortPicker(vm: ParkDashboardViewModel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
                .accessibilityHidden(true)

            ForEach(AttractionSortOrder.allCases) { order in
                let isActive = vm.sortOrder == order
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.sortOrder = order
                    }
                } label: {
                    Text(order.rawValue)
                        .font(DTDFont.caption)
                        .foregroundStyle(isActive ? .black : .white.opacity(0.75))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isActive ? Color.disneyGold : Color.white.opacity(0.10))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Attractions section

    @ViewBuilder
    private func attractionsSection(vm: ParkDashboardViewModel) -> some View {
        let attractions = vm.sortedAttractions
        if attractions.isEmpty {
            Text("No attraction data available.")
                .font(DTDFont.body)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 20)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.disneyGold)
                        .font(DTDFont.titleSecondary)
                        .accessibilityHidden(true)
                    Text("Attractions")
                        .font(DTDFont.titleSecondary)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)

                ForEach(attractions) { attraction in
                    AttractionRowCard(attraction: attraction)
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Shows section

    private func showsSection(vm: ParkDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "theatermasks.fill")
                    .foregroundStyle(Color.disneyGold)
                    .font(DTDFont.titleSecondary)
                    .accessibilityHidden(true)
                Text("Shows")
                    .font(DTDFont.titleSecondary)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)

            ForEach(vm.shows) { show in
                ShowRowCard(show: show)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if let vm = viewModel {
                VStack(spacing: 2) {
                    Text(vm.selectedPark.displayName)
                        .font(DTDFont.headline)
                        .foregroundStyle(.white)
                    Text("Live Wait Times")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
        }
    }
}

// MARK: - Attraction row card

private struct AttractionRowCard: View {
    let attraction: LiveAttraction

    var body: some View {
        HStack(spacing: 14) {
            // Status indicator dot.
            Circle()
                .fill(attraction.status.badgeColor)
                .frame(width: 10, height: 10)
                .shadow(color: attraction.status.badgeColor.opacity(0.6), radius: 4)
                .accessibilityHidden(true)

            // Name.
            Text(attraction.name)
                .font(DTDFont.bodyMedium)
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Right side: wait time or status badge.
            trailingContent
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DTDColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(attraction.status.cardTint)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var trailingContent: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if attraction.status == .operating {
                if let wait = attraction.standbyWaitMinutes {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(wait)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(waitTimeColor(wait))
                        Text("min")
                            .font(DTDFont.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                } else {
                    Text("Walk-on")
                        .font(DTDFont.captionBold)
                        .foregroundStyle(Color(hex: "#4CAF50"))
                }

                // Lightning Lane info.
                if let ll = attraction.lightningLaneReturnWindow {
                    Text("LL: \(ll.displayString)")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.65))
                } else if let paid = attraction.paidLightningLanePrice {
                    Text("ILL: \(paid.displayPrice)")
                        .font(DTDFont.caption)
                        .foregroundStyle(Color.disneyGold.opacity(0.9))
                }
            } else {
                StatusBadge(status: attraction.status)
            }
        }
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
        case .closed:       parts.append("closed")
        case .refurbishment: parts.append("under refurbishment")
        case .down:         parts.append("temporarily down")
        }
        if let ll = attraction.lightningLaneReturnWindow {
            parts.append("Lightning Lane available, return \(ll.displayString)")
        }
        return parts.joined(separator: ". ")
    }

    private func waitTimeColor(_ minutes: Int) -> Color {
        switch minutes {
        case ..<20:  return Color(hex: "#4CAF50")   // green
        case ..<45:  return Color.disneyGold
        default:     return Color(hex: "#FF6B6B")   // red-ish
        }
    }
}

// MARK: - Show row card

private struct ShowRowCard: View {
    let show: LiveShow

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "music.note.list")
                .font(.body)
                .foregroundStyle(Color.disneyGold)
                .frame(width: 22)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(show.name)
                    .font(DTDFont.bodyMedium)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if let next = show.nextShowTime {
                    Text("Next: \(next.formatted(date: .omitted, time: .shortened))")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }

                if show.allShowTimes.count > 1 {
                    let remaining = show.allShowTimes.filter { $0 > Date() }
                    if remaining.count > 1 {
                        Text(remaining.map { $0.formatted(date: .omitted, time: .shortened) }.joined(separator: " · "))
                            .font(DTDFont.caption)
                            .foregroundStyle(.white.opacity(0.45))
                            .lineLimit(2)
                    }
                }
            }

            Spacer()

            StatusBadge(status: show.status)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DTDColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
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

// MARK: - Status badge

private struct StatusBadge: View {
    let status: AttractionStatus

    var body: some View {
        Text(status.displayLabel)
            .font(DTDFont.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(status.badgeColor.opacity(0.85))
            )
    }
}

// MARK: - AttractionStatus visual helpers

private extension AttractionStatus {
    var badgeColor: Color {
        switch self {
        case .operating:     return Color(hex: "#4CAF50")
        case .closed:        return Color(hex: "#F44336")
        case .refurbishment: return Color(hex: "#FF9800")
        case .down:          return Color(hex: "#FF9800")
        }
    }

    /// Subtle tinted fill layered over the glass card background.
    var cardTint: Color {
        switch self {
        case .operating:     return Color.clear
        case .closed:        return Color(hex: "#F44336").opacity(0.05)
        case .refurbishment: return Color(hex: "#FF9800").opacity(0.05)
        case .down:          return Color(hex: "#FF9800").opacity(0.05)
        }
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
