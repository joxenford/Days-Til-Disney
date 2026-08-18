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
    // Unchanged — placed widgets must keep resolving.
    let kind = "DaysTilDisneyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectTripIntent.self,
            provider: DaysTilDisneyTimelineProvider()
        ) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countdown to Magic")
        .description("Count down the days to your next trip.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Entry View (routes to size-specific views)

// Toy Box: flat park `panelColor` container (no gradient), radius handled by the
// widget system. Foundation tokens (Typography/DTDColor) are not widget-target
// members and the widget numeral sizes aren't in the shared `Numeral` enum, so
// numerals are hand-rolled `.system(size:weight:.black,design:.rounded)` per the
// existing SYNC-NOTE precedent. `panelColor(for:)` comes free from ParkColorPalette.
struct WidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    let entry: DaysTilDisneyEntry

    var body: some View {
        content
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder
    private var content: some View {
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

    /// Home-screen families get the flat park panel; lock-screen accessory families
    /// keep the system's translucent/vibrant background (no park fill on the lock screen).
    @ViewBuilder
    private var background: some View {
        switch family {
        case .accessoryCircular, .accessoryRectangular:
            AccessoryWidgetBackground()
        default:
            if let trip = entry.trip {
                trip.colorPalette.panelColor(for: colorScheme)
            } else {
                Color(hex: colorScheme == .dark ? "#15151A" : "#F3F3F1")
            }
        }
    }
}

// MARK: - Small Widget (countdown)

// ponytail: only the countdown small variant ships. The design's "packing" small
// variant needs packed/total counts that WidgetTripEntry doesn't carry and a
// variant selector — data plumbing beyond this presentational restyle. Add the
// entry fields + an intent parameter when the packing widget is greenlit.
struct SmallWidgetView: View {
    let trip: WidgetTripEntry?

    var body: some View {
        if let trip {
            VStack(alignment: .leading, spacing: 0) {
                Text(trip.primaryPark.displayName.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                Spacer(minLength: 0)

                if trip.isToday {
                    Text("Today!")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.4)
                } else if trip.isPast {
                    Text("Complete")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.4)
                } else {
                    Text("\(trip.daysUntilStart)")
                        .font(.system(size: 62, weight: .black, design: .rounded))
                        .tracking(-4)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                    Text(trip.daysUntilStart == 1 ? "day to go" : "days to go")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(trip.tripName.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)

                    if trip.isToday {
                        Text("Today!")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.4)
                    } else if trip.isPast {
                        Text("Complete")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.4)
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(trip.daysUntilStart)")
                                .font(.system(size: 80, weight: .black, design: .rounded))
                                .tracking(-5)
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.4)
                                .lineLimit(1)
                            Text(trip.daysUntilStart == 1 ? "day" : "days")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }

                Spacer(minLength: 12)

                Text(trip.startDate.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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
                    Text("NOW")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                } else if trip.isPast {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                    Text("DONE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.2)
                } else {
                    Text("\(trip.daysUntilStart)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(-1.5)
                        .minimumScaleFactor(0.5)
                    Text("DAYS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.2)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(widgetAccessibilityLabel(trip: trip))
        } else {
            VStack(spacing: 1) {
                Text("—")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                Text("DAYS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.2)
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
            HStack(spacing: 12) {
                if trip.isToday {
                    Text("NOW")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(-1.5)
                } else {
                    Text("\(trip.isPast ? 0 : trip.daysUntilStart)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(-1.5)
                        .minimumScaleFactor(0.5)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.tripName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    Text(trip.startDate.formatted(.dateTime.day().month(.abbreviated)))
                        .font(.system(size: 12))
                        .opacity(0.8)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(widgetAccessibilityLabel(trip: trip))
        } else {
            Text("Add a trip to start your countdown.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
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

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Countdown to Magic")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Add a trip!")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Countdown to Magic. Add a trip to start your countdown.")
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
