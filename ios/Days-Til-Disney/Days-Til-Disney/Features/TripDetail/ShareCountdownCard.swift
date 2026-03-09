import SwiftUI

/// A fixed-size card view rendered to a UIImage for sharing.
///
/// This view is intentionally self-contained — it takes only the data it needs
/// (not the full Trip model) so it can be rendered off-screen by ImageRenderer
/// without any SwiftData context.
struct ShareCountdownCard: View {
    let tripName: String
    let parkEmoji: String
    let parkDisplayName: String
    let daysUntilStart: Int
    let startDate: Date
    let isToday: Bool
    let isPast: Bool
    let gradientColors: [Color]
    let accentColor: Color
    let park: DisneyPark

    // H-4: Exactly 4:5 ratio at 3x scale — 1080×1350px on device = 360×450pt.
    // Instagram and most social platforms crop to 4:5 portrait, so this renders pixel-perfect.
    static let width: CGFloat = 360
    static let height: CGFloat = 450

    var body: some View {
        ZStack {
            // Background gradient.
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )

            // Subtle radial vignette to add depth.
            RadialGradient(
                colors: [.clear, .black.opacity(0.35)],
                center: .center,
                startRadius: ShareCountdownCard.width * 0.3,
                endRadius: ShareCountdownCard.width * 0.85
            )

            // Castle watermark — large and ethereal behind everything.
            CastleSilhouetteView(
                park: park,
                size: ShareCountdownCard.width * 0.85,
                color: .white,
                opacity: 0.07
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .offset(y: 30)

            // Main card content.
            VStack(spacing: 0) {
                Spacer()

                // Park emoji.
                Text(parkEmoji)
                    .font(.system(size: 52))
                    .padding(.bottom, 8)

                // Countdown number — the hero element.
                countdownDisplay
                    .padding(.bottom, 20)

                // Trip name.
                Text(tripName)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 6)

                // Park name.
                Text(parkDisplayName)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.bottom, 16)

                // Start date pill.
                datePill
                    .padding(.bottom, 0)

                Spacer()

                // App attribution footer.
                footer
            }
            .padding(.horizontal, 24)
        }
        .frame(width: ShareCountdownCard.width, height: ShareCountdownCard.height)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        // Gold accent border.
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accentColor.opacity(0.8), accentColor.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var countdownDisplay: some View {
        if isPast {
            VStack(spacing: 2) {
                Text("Trip Complete")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("What a magical adventure!")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
            }
        } else if isToday {
            VStack(spacing: 2) {
                Text("TODAY")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: accentColor.opacity(0.6), radius: 16, x: 0, y: 0)
                Text("The magic begins!")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
            }
        } else {
            VStack(spacing: 0) {
                Text("\(daysUntilStart)")
                    .font(.system(size: 112, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: accentColor.opacity(0.5), radius: 20, x: 0, y: 4)
                    // Tighten the line height so the number sits snug above "DAYS".
                    .padding(.bottom, -8)
                Text("DAYS")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(6)
            }
        }
    }

    private var datePill: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.caption)
                .foregroundStyle(accentColor)
            Text(startDate.dayMonthDateString)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(.white.opacity(0.12), in: Capsule())
        .overlay {
            Capsule().strokeBorder(accentColor.opacity(0.4), lineWidth: 1)
        }
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Image(systemName: "wand.and.stars")
                .font(.caption2)
                .foregroundStyle(accentColor.opacity(0.7))
            Text("Days Til Disney")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(.bottom, 18)
    }
}

// MARK: - Convenience init from Trip

extension ShareCountdownCard {
    /// Creates a card pre-populated from a Trip, using the park's raw gradient colors
    /// (no time-of-day blend) so the image always looks vivid regardless of render time.
    init(trip: Trip) {
        self.tripName = trip.name
        self.parkEmoji = trip.primaryPark.emoji
        self.parkDisplayName = trip.primaryPark.displayName
        self.daysUntilStart = trip.daysUntilStart
        self.startDate = trip.startDate
        self.isToday = trip.isToday
        self.isPast = trip.isPast
        self.gradientColors = trip.colorPalette.gradientStops
        self.accentColor = trip.colorPalette.accent
        self.park = trip.primaryPark
    }
}

// MARK: - Preview

#Preview("Share Card — Magic Kingdom") {
    ZStack {
        Color(hex: "#111111").ignoresSafeArea()
        ShareCountdownCard(trip: .preview)
            .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
    }
}

#Preview("Share Card — Today") {
    ZStack {
        Color(hex: "#111111").ignoresSafeArea()
        ShareCountdownCard(trip: .previewToday)
            .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
    }
}
