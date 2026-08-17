import SwiftUI

/// THE single park-coloured surface — one per screen, everything else stays neutral.
/// Fill resolves via `park.colorPalette.panelColor(for:)` reading `@Environment(\.colorScheme)`:
/// park primary on light, the deep tone on dark. **Never gradient, never raw primary.**
struct ParkPanel<Content: View>: View {
    let park: DisneyPark
    var label: String?
    var badge: String?
    var compact: Bool = false
    @ViewBuilder let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme

    init(park: DisneyPark,
         label: String? = nil,
         badge: String? = nil,
         compact: Bool = false,
         @ViewBuilder content: @escaping () -> Content) {
        self.park = park
        self.label = label
        self.badge = badge
        self.compact = compact
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x7) {
            if label != nil || badge != nil {
                HStack(alignment: .center) {
                    if let label {
                        SectionLabel(label, tone: .onPark)
                    }
                    Spacer(minLength: 0)
                    if let badge {
                        Text(badge)
                            .font(DTDFont.labelSmall)
                            .textCase(.uppercase)
                            .tracking(1.4)
                            .foregroundStyle(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(DTDColor.onParkBadge)
                            .clipShape(Capsule())
                    }
                }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(compact ? DTDSpacing.x8 : DTDSpacing.x11)
        .background(park.colorPalette.panelColor(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.hero, style: .continuous))
    }
}

#Preview("Light") {
    VStack(spacing: 16) {
        ParkPanel(park: .magicKingdom, label: "MAGIC KINGDOM", badge: "PRIMARY") {
            CountdownNumeral(value: 45, unit: "days")
        }
        ParkPanel(park: .epcot, label: "EPCOT", badge: "IN PARK", compact: true) {
            CountdownNumeral(value: 3, unit: "of 7 days", size: .screen)
        }
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(spacing: 16) {
        ParkPanel(park: .magicKingdom, label: "MAGIC KINGDOM", badge: "PRIMARY") {
            CountdownNumeral(value: 45, unit: "days")
        }
        ParkPanel(park: .epcot, label: "EPCOT", badge: "IN PARK", compact: true) {
            CountdownNumeral(value: 3, unit: "of 7 days", size: .screen)
        }
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
