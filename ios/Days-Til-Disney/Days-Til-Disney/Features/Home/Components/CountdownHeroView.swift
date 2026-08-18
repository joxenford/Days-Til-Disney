import SwiftUI

/// The large, park-themed countdown hero displayed for the primary trip.
/// Shows days when >1 day away, switches to hours/minutes on the final day,
/// and displays a celebration/ongoing state when the trip is under way.
///
/// Toy Box: one `ParkPanel` (the single park-coloured surface on Home), oversized
/// left-aligned numeral, white-on-panel text. No gradient, shadow, or blur.
struct CountdownHeroView: View {
    let trip: Trip
    let onTap: () -> Void
    /// Called when the user taps "Plan your next adventure" on a past primary trip.
    var onAddTrip: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AppContainer.self) private var appContainer

    /// Shortest standby wait fetched for the live teaser. nil while loading or if unavailable.
    @State private var shortestWait: Int? = nil
    @State private var liveFetchAttempted = false

    var body: some View {
        // Always use a 1-second interval so the isFinalDay transition fires promptly at
        // midnight without needing to recompute the schedule. TimelineView pauses
        // automatically when the view is off-screen, so CPU impact is negligible.
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let countdown = trip.startDate.countdownComponents

            Button(action: trip.isPast ? (onAddTrip ?? onTap) : onTap) {
                ParkPanel(park: trip.primaryPark,
                          label: trip.primaryPark.displayName,
                          badge: "PRIMARY") {
                    VStack(alignment: .leading, spacing: DTDSpacing.x5) {
                        countdownDisplay(countdown: countdown)

                        // Trip name.
                        Text(trip.name)
                            .font(DTDFont.title)
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        // Trip dates + nights.
                        Text(datesLine)
                            .font(DTDFont.prose)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DTDSpacing.gutter)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(trip.isPast
                ? "Trip complete. \(trip.name)."
                : countdown.accessibilityDescription
            )
            .accessibilityHint(trip.isPast
                ? "Tap to plan your next adventure"
                : "Tap to view full trip details"
            )
        }
    }

    // MARK: - Countdown display

    @ViewBuilder
    private func countdownDisplay(countdown: Date.CountdownComponents) -> some View {
        if trip.isPast {
            pastDisplay
        } else if trip.isOngoing {
            ongoingDisplay
        } else if countdown.isFinalDay {
            finalDayDisplay(countdown: countdown)
        } else {
            // The day-flip spring bump lives inside CountdownNumeral (bumps on value change).
            CountdownNumeral(value: countdown.days,
                             unit: countdown.days == 1 ? "day" : "days",
                             size: .hero,
                             onPark: true)
        }
    }

    private func finalDayDisplay(countdown: Date.CountdownComponents) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x1) {
            HStack(alignment: .lastTextBaseline, spacing: DTDSpacing.x2) {
                Text("\(countdown.hours)").dtdNumeral(.screen)
                Text("h").font(DTDFont.title).foregroundStyle(.white.opacity(0.7))
                Text("\(countdown.minutes)").dtdNumeral(.screen)
                Text("m").font(DTDFont.title).foregroundStyle(.white.opacity(0.7))
            }
            .foregroundStyle(.white)

            // .textCase(.uppercase) so VoiceOver reads "until magic" not "U-N-T-I-L".
            Text("until magic")
                .font(DTDFont.labelUpper)
                .foregroundStyle(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(1.4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ongoingDisplay: some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x3) {
            // "Day X of Y" counter.
            HStack(alignment: .lastTextBaseline, spacing: DTDSpacing.x2) {
                Text("Day").font(DTDFont.title).foregroundStyle(.white.opacity(0.75))
                Text("\(ongoingDayNumber)").dtdNumeral(.screen).foregroundStyle(.white)
                Text("of \(trip.durationDays)").font(DTDFont.title).foregroundStyle(.white.opacity(0.75))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Day \(ongoingDayNumber) of \(trip.durationDays)")

            Text("You're at the parks!")
                .font(DTDFont.bodyStrong)
                .foregroundStyle(.white.opacity(0.85))

            // Live wait teaser — only shown after a successful fetch.
            if let wait = shortestWait {
                HStack(spacing: DTDSpacing.x2) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .accessibilityHidden(true)
                    Text("Shortest wait: \(wait) min")
                        .font(DTDFont.bodyStrong)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, DTDSpacing.x5)
                .padding(.vertical, DTDSpacing.x2)
                .background(DTDColor.onParkBadge)
                .clipShape(Capsule())
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .accessibilityLabel("Shortest current wait: \(wait) minutes")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task(id: trip.id) {
            // Only fetch once per view instance; cache handles freshness.
            guard !liveFetchAttempted, trip.isOngoing else { return }
            liveFetchAttempted = true
            if let data = try? await appContainer.liveParkDataService.fetchLiveData(for: trip.primaryPark) {
                let minWait = data.operatingAttractions
                    .compactMap(\.standbyWaitMinutes)
                    .min()
                withAnimation(reduceMotion ? .none : .easeIn(duration: 0.3)) {
                    shortestWait = minWait
                }
            }
        }
    }

    /// 1-based day number within the trip (1 on start day, durationDays on end day).
    private var ongoingDayNumber: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: trip.startDate)
        let today = calendar.startOfDay(for: Date())
        let elapsed = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, elapsed + 1)
    }

    private var pastDisplay: some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x3) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.9))

            Text("Trip complete")
                .font(DTDFont.title)
                .foregroundStyle(.white)

            Text("The memories live on forever.")
                .font(DTDFont.prose)
                .foregroundStyle(.white.opacity(0.78))

            if onAddTrip != nil {
                // Visual affordance only — the whole hero Button routes to onAddTrip for past trips.
                Text("Plan your next adventure")
                    .font(DTDFont.bodyStrong)
                    .foregroundStyle(DTDColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(DTDColor.bg)
                    .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous))
                    .padding(.top, DTDSpacing.x1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private var datesLine: String {
        let base = "\(trip.startDate.dayMonthDateString) – \(trip.endDate.dayMonthDateString)"
        let nights = max(0, trip.durationDays - 1)
        guard nights > 0 else { return base }
        return "\(base) · \(nights) night\(nights == 1 ? "" : "s")"
    }
}

// MARK: - Preview

#Preview("45 Days") {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        CountdownHeroView(trip: Trip.preview, onTap: {})
            .environment(\.parkThemeProvider, ParkThemeProvider.preview())
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}

#Preview("Today") {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        CountdownHeroView(trip: Trip.previewToday, onTap: {})
            .environment(\.parkThemeProvider, ParkThemeProvider.preview(park: .tokyoDisneyland))
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}
