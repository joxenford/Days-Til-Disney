import SwiftUI

/// A fixed-size card view rendered to a UIImage for sharing.
///
/// This view is intentionally self-contained — it takes only the data it needs
/// (not the full Trip model) so it can be rendered off-screen by ImageRenderer
/// without any SwiftData context.
///
/// `ImageRenderer` does NOT inherit `@Environment(\.colorScheme)`, so the park
/// fill is threaded in as an already-resolved `panelColor` (see `init(trip:scheme:)`).
/// This keeps the exported PNG deterministic regardless of the renderer's traits.
struct ShareCountdownCard: View {
    let tripName: String
    let parkDisplayName: String
    let daysUntilStart: Int
    let startDate: Date
    let endDate: Date
    let nights: Int
    let isToday: Bool
    let isPast: Bool
    let panelColor: Color

    // Exactly 4:5 at 3x scale — 1080×1350px on device = 360×450pt.
    static let width: CGFloat = 360
    static let height: CGFloat = 450

    var body: some View {
        ZStack {
            panelColor

            VStack(alignment: .leading, spacing: 0) {
                Text(parkDisplayName.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                Spacer(minLength: 0)

                hero

                infoBlock
                    .padding(.top, 14)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.top, 18)

                Text("COUNTDOWN TO MAGIC")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.top, 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(width: ShareCountdownCard.width, height: ShareCountdownCard.height)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    // MARK: - Subviews

    @ViewBuilder
    private var hero: some View {
        if isPast {
            Text("Trip\ncomplete")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .tracking(-2)
                .lineSpacing(0)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
        } else if isToday {
            Text("Today is\nthe day")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .tracking(-2)
                .lineSpacing(0)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(daysUntilStart)")
                    .font(.system(size: 106, weight: .black, design: .rounded))
                    .tracking(-7)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                Text(daysUntilStart == 1 ? "day to go" : "days to go")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(DTDColor.gold)
            }
        }
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tripName)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .tracking(-0.3)
                .foregroundStyle(.white)
                .lineLimit(2)
            Text(dateRangeText)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dateRangeText: String {
        let range = "\(startDate.dayMonthDateString) — \(endDate.dayMonthDateString)"
        return "\(range) · \(nights) \(nights == 1 ? "night" : "nights")"
    }
}

// MARK: - Convenience init from Trip

extension ShareCountdownCard {
    /// Creates a card pre-populated from a Trip. `scheme` resolves the park panel
    /// fill explicitly because `ImageRenderer` does not inherit `colorScheme` —
    /// thread the sharing screen's scheme through so the export matches the app.
    init(trip: Trip, scheme: ColorScheme = .light) {
        self.tripName = trip.name
        self.parkDisplayName = trip.primaryPark.displayName
        self.daysUntilStart = trip.daysUntilStart
        self.startDate = trip.startDate
        self.endDate = trip.endDate
        self.nights = trip.durationDays
        self.isToday = trip.isToday
        self.isPast = trip.isPast
        self.panelColor = trip.colorPalette.panelColor(for: scheme)
    }
}

// MARK: - Rendering

extension ShareCountdownCard {
    /// Renders the card to a share-ready image. `scheme` is threaded explicitly
    /// because `ImageRenderer` does not inherit `colorScheme` — pass the sharing
    /// screen's scheme so the export matches what the user is looking at.
    @MainActor
    static func rendered(trip: Trip, scheme: ColorScheme) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCountdownCard(trip: trip, scheme: scheme))
        // Render at 3x for crisp social-share quality.
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// MARK: - UIActivityViewController wrapper

/// A thin UIViewControllerRepresentable that presents UIActivityViewController
/// for sharing a UIImage. Shared by Trip Detail and the milestone screen.
struct ShareSheet: UIViewControllerRepresentable {
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

#Preview("Share Card — Countdown") {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        ShareCountdownCard(trip: .preview)
    }
}

#Preview("Share Card — Today") {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        ShareCountdownCard(trip: .previewToday)
    }
}
