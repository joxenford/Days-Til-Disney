import SwiftUI

// MARK: - Card view state (local, not shared with dashboard)

private enum LiveParkCardState {
    case idle
    case loading
    /// Carries the raw data plus pre-computed display collections so that
    /// `loadedBody` does not re-sort and re-filter on every layout pass.
    case loaded(ParkLiveData, LoadedDisplay)
    case failed
}

/// Display-ready collections derived once from `ParkLiveData` at fetch time.
private struct LoadedDisplay {
    let operatingCount: Int
    let shortest: [LiveAttraction]   // up to 3, sorted ascending by wait
    let longest: [LiveAttraction]    // up to 2, sorted descending by wait
    let nextShow: LiveShow?

    init(data: ParkLiveData) {
        let operating = data.operatingAttractions
        operatingCount = operating.count
        shortest = Array(
            operating
                .filter { $0.standbyWaitMinutes != nil }
                .sorted { ($0.standbyWaitMinutes ?? 0) < ($1.standbyWaitMinutes ?? 0) }
                .prefix(3)
        )
        longest = Array(
            operating
                .filter { $0.standbyWaitMinutes != nil }
                .sorted { ($0.standbyWaitMinutes ?? 0) > ($1.standbyWaitMinutes ?? 0) }
                .prefix(2)
        )
        nextShow = data.shows
            .filter { $0.nextShowTime != nil }
            .sorted { ($0.nextShowTime ?? .distantFuture) < ($1.nextShowTime ?? .distantFuture) }
            .first
    }
}

// MARK: - LiveParkCard

/// A compact "Today at the Park" card shown in TripDetailView when a trip is ongoing.
/// Displays the top 3 shortest waits, the 2 longest waits, and the next show time.
/// Tapping "View All" navigates to the full ParkDashboardView.
struct LiveParkCard: View {
    let trip: Trip
    let onViewAll: () -> Void

    @Environment(AppContainer.self) private var appContainer

    @State private var cardState: LiveParkCardState = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x5) {
            // Header row.
            HStack {
                SectionLabel("Today at the park")
                Spacer(minLength: 0)
                Button(action: onViewAll) {
                    Text("View all ›")
                        .font(DTDFont.prose)
                        .fontWeight(.semibold)
                        .foregroundStyle(DTDColor.accentInteractive)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View all live park data")
            }

            cardBody
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
        .task {
            await fetchIfNeeded()
        }
    }

    // MARK: - Body states

    @ViewBuilder
    private var cardBody: some View {
        switch cardState {
        case .idle, .loading:
            HStack {
                Spacer()
                ProgressView()
                    .tint(DTDColor.accentInteractive)
                    .scaleEffect(0.85)
                Spacer()
            }
            .frame(minHeight: 60)

        case .failed:
            HStack(spacing: DTDSpacing.x4) {
                Text("Live data unavailable")
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                Spacer()
                Button {
                    Task { await retryFetch() }
                } label: {
                    Text("Retry")
                        .font(DTDFont.prose)
                        .fontWeight(.semibold)
                        .foregroundStyle(DTDColor.accentInteractive)
                }
                .buttonStyle(.plain)
            }

        case .loaded(_, let display):
            loadedBody(display: display)
        }
    }

    /// Renders the loaded state. All sorting/filtering was done once at fetch time.
    @ViewBuilder
    private func loadedBody(display: LoadedDisplay) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x5) {
            if !display.shortest.isEmpty {
                VStack(alignment: .leading, spacing: DTDSpacing.x2) {
                    SectionLabel("Shortest waits")
                    ForEach(display.shortest) { attraction in
                        compactAttractionRow(attraction: attraction)
                    }
                }
            }

            if !display.longest.isEmpty {
                VStack(alignment: .leading, spacing: DTDSpacing.x2) {
                    SectionLabel("Longest waits")
                    ForEach(display.longest) { attraction in
                        compactAttractionRow(attraction: attraction)
                    }
                }
            }

            if let show = display.nextShow, let time = show.nextShowTime {
                Divider().overlay(DTDColor.hairline)
                HStack {
                    Text(show.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(DTDColor.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(time.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(DTDColor.goldLabel)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(show.name), next show at \(time.formatted(date: .omitted, time: .shortened))")
            }

            Text("\(display.operatingCount) rides operating")
                .font(DTDFont.prose)
                .foregroundStyle(DTDColor.textFaint)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityHidden(true)
        }
    }

    private func compactAttractionRow(attraction: LiveAttraction) -> some View {
        HStack(spacing: DTDSpacing.x3) {
            Text(attraction.name)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(DTDColor.textPrimary)
                .lineLimit(1)
            Spacer()
            WaitPill(minutes: attraction.standbyWaitMinutes, status: attraction.status)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel({
            let waitStr = attraction.standbyWaitMinutes.map { "\($0) minute wait" } ?? "walk-on"
            return "\(attraction.name), \(waitStr)"
        }())
    }

    // MARK: - Data fetching

    private func fetchIfNeeded() async {
        guard case .idle = cardState else { return }
        cardState = .loading
        do {
            let data = try await appContainer.liveParkDataService.fetchLiveData(for: trip.primaryPark)
            cardState = .loaded(data, LoadedDisplay(data: data))
        } catch {
            cardState = .failed
        }
    }

    private func retryFetch() async {
        appContainer.liveParkDataService.clearCache(for: trip.primaryPark)
        cardState = .loading
        do {
            let data = try await appContainer.liveParkDataService.fetchLiveData(for: trip.primaryPark)
            cardState = .loaded(data, LoadedDisplay(data: data))
        } catch {
            cardState = .failed
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        LiveParkCard(
            trip: Trip.previewToday,
            onViewAll: {}
        )
        .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
        .padding(.horizontal, 20)
    }
}
