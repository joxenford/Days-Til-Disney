import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct DaysTilDisneyEntry: TimelineEntry {
    let date: Date
    let trip: WidgetTripEntry?

    static let placeholder = DaysTilDisneyEntry(
        date: .now,
        trip: WidgetTripEntry(
            tripID: UUID(),
            tripName: "Magic Trip",
            daysUntilStart: 42,
            isToday: false,
            isOngoing: false,
            isPast: false,
            startDate: Calendar.current.date(byAdding: .day, value: 42, to: .now) ?? .now,
            primaryPark: .magicKingdom,
            colorPalette: DisneyPark.magicKingdom.colorPalette
        )
    )
}

// MARK: - Timeline Provider

struct DaysTilDisneyTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = DaysTilDisneyEntry
    typealias Intent = SelectTripIntent

    func placeholder(in context: Context) -> DaysTilDisneyEntry {
        .placeholder
    }

    func snapshot(for configuration: SelectTripIntent, in context: Context) async -> DaysTilDisneyEntry {
        let trip = WidgetDataProvider.entry(for: configuration.trip?.id)
        return DaysTilDisneyEntry(date: .now, trip: trip)
    }

    func timeline(for configuration: SelectTripIntent, in context: Context) async -> Timeline<DaysTilDisneyEntry> {
        let trip = WidgetDataProvider.entry(for: configuration.trip?.id)
        let entry = DaysTilDisneyEntry(date: .now, trip: trip)

        // Refresh at midnight (when the day count changes) or in 1 hour, whichever is sooner.
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        let oneHour = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        let refreshDate = min(midnight, oneHour)

        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
}

// MARK: - Widget Definition

struct DaysTilDisneyWidget: Widget {
    let kind = "DaysTilDisneyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectTripIntent.self,
            provider: DaysTilDisneyTimelineProvider()
        ) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    if let trip = entry.trip {
                        LinearGradient(
                            colors: trip.colorPalette.gradientStops,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color(hex: "#0D2545"), Color(hex: "#1A1147")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
        }
        .configurationDisplayName("Countdown to Magic")
        .description("Count down the days to your next trip.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Entry View (routes to size-specific views)

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DaysTilDisneyEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(trip: entry.trip)
        case .systemMedium:
            MediumWidgetView(trip: entry.trip)
        case .accessoryCircular:
            AccessoryCircularWidgetView(trip: entry.trip)
        case .accessoryRectangular:
            AccessoryRectangularWidgetView(trip: entry.trip)
        default:
            SmallWidgetView(trip: entry.trip)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let trip: WidgetTripEntry?

    var body: some View {
        if let trip {
            ZStack(alignment: .bottomTrailing) {
                // Hero mark watermark — larger and more ghostly for legibility.
                WidgetHeroMark(size: 70)
                    .opacity(0.12)
                    .offset(x: 10, y: 10)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.primaryPark.emoji)
                        .font(.title3)

                    Spacer()

                    if trip.isToday {
                        Text("TODAY!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else if trip.isPast {
                        Text("Complete")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    } else {
                        Text("\(trip.daysUntilStart)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(trip.daysUntilStart == 1 ? "day" : "days")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Text(trip.tripName)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(widgetAccessibilityLabel(trip: trip))
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let trip: WidgetTripEntry?

    var body: some View {
        if let trip {
            ZStack(alignment: .trailing) {
                // Hero mark on the right — partially clipped for a sense of grandeur.
                WidgetHeroMark(size: 100)
                    .opacity(0.2)
                    .offset(x: 30, y: 15)
                    .accessibilityHidden(true)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.primaryPark.emoji)
                            .font(.title3)

                        Spacer()

                        if trip.isToday {
                            Text("TODAY!")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        } else if trip.isPast {
                            Text("Complete")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(trip.daysUntilStart)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(trip.daysUntilStart == 1 ? "day" : "days")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }

                        Text(trip.tripName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)

                        Text(trip.startDate.formatted(.dateTime.month(.wide).day().year()))
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(widgetAccessibilityLabel(trip: trip))
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - Lock Screen: Circular

struct AccessoryCircularWidgetView: View {
    let trip: WidgetTripEntry?

    var body: some View {
        if let trip {
            VStack(spacing: 1) {
                if trip.isToday {
                    Text(trip.primaryPark.emoji)
                        .font(.caption)
                    Text("NOW")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                } else if trip.isPast {
                    // Show a checkmark instead of "0" — "0" is meaningless for a completed trip.
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                    Text("Done")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                } else {
                    Text(trip.primaryPark.emoji)
                        .font(.caption)
                    Text("\(trip.daysUntilStart)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("days")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(widgetAccessibilityLabel(trip: trip))
        } else {
            VStack {
                Image(systemName: "sparkles")
                Text("—")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .accessibilityLabel("Countdown to Magic. No trip configured.")
        }
    }
}

// MARK: - Lock Screen: Rectangular

struct AccessoryRectangularWidgetView: View {
    let trip: WidgetTripEntry?

    var body: some View {
        if let trip {
            HStack(spacing: 8) {
                VStack(alignment: .center, spacing: 0) {
                    if trip.isToday {
                        Text("NOW")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    } else {
                        Text("\(trip.isPast ? 0 : trip.daysUntilStart)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                    }
                    Text(trip.isToday ? "" : "days")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                }
                .frame(minWidth: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(trip.primaryPark.emoji) \(trip.tripName)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                    Text(trip.startDate.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .opacity(0.7)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(widgetAccessibilityLabel(trip: trip))
        } else {
            HStack {
                Image(systemName: "sparkles")
                    .accessibilityHidden(true)
                Text("Add a trip!")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .accessibilityLabel("Countdown to Magic. Add a trip to start your countdown.")
        }
    }
}

// MARK: - Shared accessibility helper

/// Generates a single descriptive VoiceOver label for any widget size.
private func widgetAccessibilityLabel(trip: WidgetTripEntry) -> String {
    if trip.isPast {
        return "\(trip.tripName). Trip complete."
    } else if trip.isToday {
        return "\(trip.tripName). Today is the day!"
    } else {
        let days = trip.daysUntilStart
        return "\(trip.tripName). \(days) \(days == 1 ? "day" : "days") until your trip."
    }
}

// MARK: - Empty State

// H-5: Improved visual hierarchy — app name as primary label, action text below.
struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Countdown to Magic")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            WidgetHeroMark(size: 44)
                .opacity(0.5)
                .accessibilityHidden(true)
            Text("Add a trip!")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Countdown to Magic. Add a trip to start your countdown.")
    }
}

// MARK: - Wish hero mark (self-contained for widget extension)

struct WidgetHeroMark: View {
    let size: CGFloat

    var body: some View {
        WidgetWishStarShape()
            .fill(.white)
            .frame(width: size, height: size)
    }
}

/// The "Wish" shooting-star mark optimized for small widget sizes.
///
/// SYNC NOTE: This shape is intentionally duplicated from `WishStar.path(in:)` in
/// `Days-Til-Disney/DesignSystem/Components/CastleSilhouetteView.swift`.
/// The widget extension cannot import from the main app target, so both shapes
/// must be maintained independently. If you change the path coordinates here,
/// update the corresponding shape in CastleSilhouetteView.swift as well.
struct WidgetWishStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Single continuous outline: a sparkle head (top / right / left tips) whose
        // lower-left arm is elongated into a tapering comet trail.
        let w = rect.width
        let h = rect.height
        let m = min(w, h)
        var path = Path()

        let cx = w * 0.60
        let cy = h * 0.40
        let arm = m * 0.30
        let waist = m * 0.085

        let n    = CGPoint(x: cx,        y: cy - arm)
        let e    = CGPoint(x: cx + arm,  y: cy)
        let wl   = CGPoint(x: cx - arm,  y: cy)
        let tail = CGPoint(x: w * 0.10,  y: h * 0.92)

        let vNE = CGPoint(x: cx + waist,       y: cy - waist)
        let vES = CGPoint(x: cx + waist,       y: cy + waist)
        let vTW = CGPoint(x: cx - waist * 1.3, y: cy + waist * 0.7)
        let vWN = CGPoint(x: cx - waist,       y: cy - waist)

        path.move(to: n)
        path.addQuadCurve(to: e,    control: vNE)
        path.addQuadCurve(to: tail, control: vES)
        path.addQuadCurve(to: wl,   control: vTW)
        path.addQuadCurve(to: n,    control: vWN)
        path.closeSubpath()

        return path
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    DaysTilDisneyWidget()
} timeline: {
    DaysTilDisneyEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    DaysTilDisneyWidget()
} timeline: {
    DaysTilDisneyEntry.placeholder
}

#Preview("Circular", as: .accessoryCircular) {
    DaysTilDisneyWidget()
} timeline: {
    DaysTilDisneyEntry.placeholder
}

#Preview("Rectangular", as: .accessoryRectangular) {
    DaysTilDisneyWidget()
} timeline: {
    DaysTilDisneyEntry.placeholder
}
