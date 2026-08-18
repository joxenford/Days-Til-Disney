import SwiftUI

/// Full-bleed milestone celebration screen — the flat Toy Box replacement for the
/// dropped 70-particle celebration overlay. One park-coloured surface carrying the
/// oversized numeral, the gold milestone title, and the 8-segment progress strip.
/// Reached via the `.milestone(tripID:)` route from the Home "Next up" tile (on demand)
/// and from the milestone trigger (`activeMilestone`) on Home / iPad Home / Trip Detail.
struct MilestoneView: View {
    let tripID: UUID

    @Environment(AppContainer.self) private var appContainer
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.dismiss) private var dismiss

    @State private var trip: Trip?

    var body: some View {
        ZStack {
            // Full-bleed backdrop: the same resolved panel colour bled to every edge so the
            // single ParkPanel below reads edge-to-edge (its rounded corners fall on matching
            // colour). Neutral bg while the trip is still loading.
            backdrop
                .ignoresSafeArea()

            if let trip {
                content(for: trip)
            } else {
                ProgressView().tint(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // Transparent bar keeps the system back/swipe escape over the full-bleed colour.
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            // Read-only trip fetch — no new ViewModel API (guardrail); resolves park,
            // daysUntilStart, and the matching milestone locally.
            trip = try? await appContainer.tripRepository.fetchTrip(by: tripID)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func content(for trip: Trip) -> some View {
        let park = trip.primaryPark
        let daysOut = trip.daysUntilStart
        let milestone = Self.milestone(for: daysOut)

        // Milestone is the one numeral that grows on iPad: it anchors the sole full-bleed
        // park screen, so 172 reads lost on a 13" canvas. Grow to ~230 (wider tracking) on
        // regular width; the iPhone size holds on compact. The type block is clamped so it
        // reads composed rather than sprawling across the full width.
        let isRegular = hSize == .regular
        GeometryReader { geo in
            ScrollView {
                ParkPanel(park: park) {
                    VStack(alignment: .leading, spacing: DTDSpacing.x7) {
                        SectionLabel("Milestone · \(park.displayName)", loose: true, tone: .onPark)
                            .textCase(.uppercase)

                        CountdownNumeral(value: milestone.daysOut,
                                         size: .milestone,
                                         pointSize: isRegular ? 230 : nil,
                                         trackingOverride: isRegular ? -16 : nil)

                        Text(milestone.title)
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .tracking(-1.4)
                            .lineSpacing(3)
                            .foregroundStyle(DTDColor.gold)

                        Text(milestone.subtitle)
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .lineSpacing(9)
                            .foregroundStyle(.white.opacity(0.88))

                        MilestoneStrip(daysOut: daysOut, onPark: true)
                            .padding(.top, DTDSpacing.x2)

                        VStack(spacing: DTDSpacing.x3) {
                            DTDButton("Let's go", variant: .onPark) { dismiss() }
                            DTDButton("Share it", variant: .outlineOnPark) { dismiss() }
                        }
                        .padding(.top, DTDSpacing.x4)
                    }
                }
                // Clamp the type block on regular-width iPad (full-bleed colour still bleeds
                // to every edge via `backdrop`); no-op on compact.
                .dtdContentColumn()
                .frame(minHeight: geo.size.height, alignment: .center)
            }
        }
    }

    private var backdrop: Color {
        if let trip {
            return trip.primaryPark.colorPalette.panelColor(for: colorScheme)
        }
        return DTDColor.bg
    }

    // MARK: - Milestone resolution

    /// The milestone this screen celebrates for a trip at `daysOut`:
    /// the exact threshold if today lands on one (the trigger case), otherwise the next
    /// milestone the countdown will reach; falls back to "Today is the day!" once in-park/past.
    static func milestone(for daysOut: Int) -> Milestone {
        if let exact = Milestone.matching(daysOut: daysOut) { return exact }
        if let next = Milestone.all.filter({ $0.daysOut < daysOut }).max(by: { $0.daysOut < $1.daysOut }) {
            return next
        }
        return Milestone.all.last ?? Milestone.all[0]
    }
}

// MARK: - Milestone haptic

/// The celebration haptic relocated out of the deleted particle overlay. Fired at the
/// milestone *trigger* sites (not on manual browsing) the instant `activeMilestone` resolves.
enum MilestoneHaptic {
    static func fire(_ type: Milestone.CelebrationType) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = type.isHeavyHaptic ? .heavy : .medium
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

#Preview("Light") {
    NavigationStack {
        MilestoneView(tripID: Trip.preview.id)
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}

#Preview("Dark") {
    NavigationStack {
        MilestoneView(tripID: Trip.preview.id)
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
    .preferredColorScheme(.dark)
}
