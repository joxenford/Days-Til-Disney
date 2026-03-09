import SwiftUI

/// The large, park-themed countdown hero displayed for the primary trip.
/// Shows days when >1 day away, switches to hours/minutes on the final day,
/// and displays a celebration state when daysOut == 0.
struct CountdownHeroView: View {
    let trip: Trip
    let onTap: () -> Void
    /// Called when the user taps "Plan your next adventure" on a past primary trip.
    var onAddTrip: (() -> Void)? = nil

    @Environment(\.parkThemeProvider) private var themeProvider

    @State private var countdownScale: Double = 1.0

    /// Accent color used for glows — prefer the theme's accent, fall back to park palette.
    private var accentColor: Color {
        themeProvider.currentTheme.accentColor
    }

    var body: some View {
        // Always use a 1-second interval so the isFinalDay transition fires promptly at
        // midnight without needing to recompute the schedule. TimelineView pauses
        // automatically when the view is off-screen, so CPU impact is negligible.
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let countdown = trip.startDate.countdownComponents

            Button(action: trip.isPast ? (onAddTrip ?? onTap) : onTap) {
                ZStack {
                    // Card background: subtle park gradient tint over glass material.
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            trip.colorPalette.primary.opacity(0.30),
                                            trip.colorPalette.backgroundGradientEnd.opacity(0.12),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        // Thin accent border for park identity.
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            accentColor.opacity(0.40),
                                            accentColor.opacity(0.10),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }

                    VStack(spacing: 0) {
                        // Castle silhouette header — glows with the park's accent color.
                        CastleSilhouetteView(
                            park: trip.primaryPark,
                            size: 110,
                            color: .white,
                            opacity: 0.80,
                            showGlow: true,
                            glowColor: accentColor
                        )
                        .padding(.top, 28)

                        // Park name.
                        Text(trip.primaryPark.displayName.uppercased())
                            .font(DTDFont.captionBold)
                            .foregroundStyle(.white.opacity(0.65))
                            .tracking(2)
                            .padding(.top, 4)

                        // Trip name.
                        Text(trip.name)
                            .font(DTDFont.titlePrimary)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                        // Countdown display.
                        countdownDisplay(countdown: countdown)
                            .padding(.top, 20)
                            .scaleEffect(countdownScale)

                        // Trip dates.
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.footnote)
                            Text("\(trip.startDate.dayMonthDateString) – \(trip.endDate.dayMonthDateString)")
                                .font(DTDFont.caption)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 12)
                        .padding(.bottom, 28)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            // Two-layer shadow: a deep shadow for elevation, plus a colored bloom for magic.
            .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
            .shadow(color: accentColor.opacity(0.25), radius: 32, y: 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(trip.isPast
                ? "Trip complete. \(trip.name)."
                : countdown.accessibilityDescription
            )
            .accessibilityHint(trip.isPast
                ? "Tap to plan your next adventure"
                : "Tap to view full trip details"
            )
            .onChange(of: countdown.days) { _, _ in
                // Animate the number change when the day flips.
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    countdownScale = 1.08
                }
            }
            .task(id: countdownScale) {
                // Return scale to 1.0 after the bounce — Task cancels automatically
                // when the view disappears or countdownScale changes again.
                guard countdownScale != 1.0 else { return }
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    countdownScale = 1.0
                }
            }
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
            daysDisplay(countdown: countdown)
        }
    }

    private func daysDisplay(countdown: Date.CountdownComponents) -> some View {
        VStack(spacing: 4) {
            Text("\(countdown.days)")
                .font(.system(size: 88, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            Text(countdown.days == 1 ? "DAY" : "DAYS")
                .font(DTDFont.countdownLabel())
                .foregroundStyle(.white.opacity(0.75))
                .tracking(3)
        }
    }

    private func finalDayDisplay(countdown: Date.CountdownComponents) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(countdown.hours)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text("h")
                    .font(DTDFont.titleSecondary)
                    .foregroundStyle(.white.opacity(0.75))

                Text("\(countdown.minutes)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text("m")
                    .font(DTDFont.titleSecondary)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Text("UNTIL MAGIC")
                .font(DTDFont.countdownLabel())
                .foregroundStyle(.white.opacity(0.75))
                .tracking(2)
        }
    }

    private var ongoingDisplay: some View {
        VStack(spacing: 8) {
            Text("TODAY!")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.magicSparkle, accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // Sparkle glow behind the text.
                .shadow(color: Color.magicSparkle.opacity(0.7), radius: 12)

            Text("You're at Disney!")
                .font(DTDFont.headline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var pastDisplay: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.6))

            Text("Trip Complete")
                .font(DTDFont.headline)
                .foregroundStyle(.white.opacity(0.75))

            Text("The memories live on forever.")
                .font(DTDFont.caption)
                .foregroundStyle(.white.opacity(0.55))

            if onAddTrip != nil {
                Label("Plan your next adventure!", systemImage: "plus.circle.fill")
                    .font(DTDFont.bodyMedium)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Preview

#Preview("45 Days") {
    ZStack {
        Color(hex: "#0D2545").ignoresSafeArea()
        CountdownHeroView(trip: Trip.preview, onTap: {})
            .environment(\.parkThemeProvider, ParkThemeProvider.preview())
    }
}

#Preview("Today") {
    ZStack {
        Color(hex: "#880E4F").ignoresSafeArea()
        CountdownHeroView(trip: Trip.previewToday, onTap: {})
            .environment(\.parkThemeProvider, ParkThemeProvider.preview(park: .tokyoDisneyland))
    }
}
