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
        VStack(alignment: .leading, spacing: 0) {
            // Header row.
            HStack(spacing: 10) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.disneyGold)
                    .accessibilityHidden(true)

                Text("Today at the Park")
                    .font(DTDFont.titleSecondary)
                    .foregroundStyle(.white)

                Spacer()

                Button(action: onViewAll) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(DTDFont.captionBold)
                            .foregroundStyle(Color.disneyGold)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.disneyGold.opacity(0.8))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View all live park data")
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .background(.white.opacity(0.12))
                .padding(.horizontal, 16)

            // Body.
            cardBody
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    trip.colorPalette.primary.opacity(0.18),
                                    Color.clear,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.20), radius: 12, y: 4)
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
                    .tint(.white)
                    .scaleEffect(0.85)
                Spacer()
            }
            .frame(minHeight: 60)

        case .failed:
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(.white.opacity(0.5))
                    .accessibilityHidden(true)
                Text("Live data unavailable")
                    .font(DTDFont.body)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Button {
                    Task { await retryFetch() }
                } label: {
                    Text("Retry")
                        .font(DTDFont.captionBold)
                        .foregroundStyle(Color.disneyGold)
                }
                .buttonStyle(.plain)
            }

        case .loaded(_, let display):
            loadedBody(display: display)
        }
    }

    /// Renders the loaded state. All sorting/filtering was done once at fetch time
    /// via `LoadedDisplay.init(data:)` — this method just reads the pre-computed values.
    @ViewBuilder
    private func loadedBody(display: LoadedDisplay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Shortest waits.
            if !display.shortest.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Shortest Waits")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .textCase(.uppercase)
                        .tracking(1)

                    ForEach(display.shortest) { attraction in
                        compactAttractionRow(attraction: attraction, emphasise: .short)
                    }
                }
            }

            // Longest waits (only show if there are rides with waits).
            if !display.longest.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Longest Waits")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .textCase(.uppercase)
                        .tracking(1)

                    ForEach(display.longest) { attraction in
                        compactAttractionRow(attraction: attraction, emphasise: .long)
                    }
                }
            }

            // Next show.
            if let show = display.nextShow, let time = show.nextShowTime {
                Divider()
                    .background(.white.opacity(0.10))

                HStack(spacing: 10) {
                    Image(systemName: "theatermasks.fill")
                        .font(.footnote)
                        .foregroundStyle(Color.disneyGold)
                        .accessibilityHidden(true)
                    Text(show.name)
                        .font(DTDFont.captionBold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Text(time.formatted(date: .omitted, time: .shortened))
                        .font(DTDFont.captionBold)
                        .foregroundStyle(Color.disneyGold)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(show.name), next show at \(time.formatted(date: .omitted, time: .shortened))")
            }

            // Operating count footer — uses pre-computed count, no re-scan of the array.
            Text("\(display.operatingCount) rides operating")
                .font(DTDFont.caption)
                .foregroundStyle(.white.opacity(0.45))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityHidden(true)
        }
    }

    private enum WaitEmphasis { case short, long }

    private func compactAttractionRow(attraction: LiveAttraction, emphasise: WaitEmphasis) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(emphasise == .short ? Color(hex: "#4CAF50") : Color(hex: "#FF6B6B"))
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)

            Text(attraction.name)
                .font(DTDFont.captionBold)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)

            Spacer()

            if let wait = attraction.standbyWaitMinutes {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(wait)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(
                            emphasise == .short ? Color(hex: "#4CAF50") : Color(hex: "#FF6B6B")
                        )
                    Text("min")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            } else {
                Text("Walk-on")
                    .font(DTDFont.captionBold)
                    .foregroundStyle(Color(hex: "#4CAF50"))
            }
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
        Color(hex: "#0D2545").ignoresSafeArea()
        LiveParkCard(
            trip: Trip.previewToday,
            onViewAll: {}
        )
        .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
        .padding(.horizontal, 20)
    }
}
