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
        .configurationDisplayName("Days 'Til Disney")
        .description("Count down the days to your Disney trip.")
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
                // Castle watermark — larger and more ghostly for legibility.
                WidgetCastleSilhouette(size: 70)
                    .opacity(0.12)
                    .offset(x: 10, y: 10)

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
                // Castle on the right — partially clipped for a sense of grandeur.
                WidgetCastleSilhouette(size: 100)
                    .opacity(0.2)
                    .offset(x: 30, y: 15)

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
                } else {
                    Text(trip.primaryPark.emoji)
                        .font(.caption)
                    Text("\(trip.isPast ? 0 : trip.daysUntilStart)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("days")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                }
            }
        } else {
            VStack {
                Image(systemName: "sparkles")
                Text("—")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
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
        } else {
            HStack {
                Image(systemName: "sparkles")
                Text("Add a Disney trip!")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
        }
    }
}

// MARK: - Empty State

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 8) {
            WidgetCastleSilhouette(size: 60)
                .opacity(0.4)
            Text("Add a trip!")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

// MARK: - Castle Silhouette (self-contained for widget extension)

struct WidgetCastleSilhouette: View {
    let size: CGFloat

    var body: some View {
        WidgetFallbackCastleShape()
            .fill(.white)
            .frame(width: size, height: size)
    }
}

/// Cinderella Castle–inspired silhouette optimized for small widget sizes.
/// Clean lines, no fine details that become noise at 60-70pt.
/// Kept in sync with `FallbackCastleShape` in CastleSilhouetteView.swift.
struct WidgetFallbackCastleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // ── Outline traced clockwise from bottom-left ──

        // Left wall.
        path.move(to: CGPoint(x: w * 0.13, y: h))
        path.addLine(to: CGPoint(x: w * 0.13, y: h * 0.65))

        // Left outer turret — clean triangular spire.
        path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.20, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.65))

        // Left peaked roofline.
        path.addLine(to: CGPoint(x: w * 0.29, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.31, y: h * 0.57))
        path.addLine(to: CGPoint(x: w * 0.33, y: h * 0.65))

        // Left secondary spire — flanking the center.
        path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.13))
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.65))

        // ── Central spire — dominant, reaches the top ──
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.0))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.30))

        // Right secondary spire — slightly taller for asymmetry.
        path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.32))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.11))
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.32))
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.65))

        // Right peaked roofline.
        path.addLine(to: CGPoint(x: w * 0.67, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.69, y: h * 0.58))
        path.addLine(to: CGPoint(x: w * 0.71, y: h * 0.65))

        // Right outer turret — slightly wider for asymmetry.
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.80, y: h * 0.17))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.65))

        // Right wall.
        path.addLine(to: CGPoint(x: w * 0.87, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.87, y: h))

        // ── Gothic pointed arch gate ──
        path.addLine(to: CGPoint(x: w * 0.60, y: h))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.75),
            control: CGPoint(x: w * 0.57, y: h * 0.80)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.40, y: h),
            control: CGPoint(x: w * 0.43, y: h * 0.80)
        )
        path.addLine(to: CGPoint(x: w * 0.13, y: h))

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
