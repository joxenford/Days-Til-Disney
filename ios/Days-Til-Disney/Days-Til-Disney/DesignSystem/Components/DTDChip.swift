import SwiftUI

/// Pill for park names, resorts, dates and filter rows. Selected chips invert to ink —
/// selection is never signalled by a colour swap.
struct DTDChip: View {
    enum Tone {
        case surface   // sits on the page
        case onPark    // sits inside a park panel
    }

    let label: String
    var tone: Tone = .surface
    var selected: Bool = false
    var action: (() -> Void)?

    init(_ label: String, tone: Tone = .surface, selected: Bool = false, action: (() -> Void)? = nil) {
        self.label = label
        self.tone = tone
        self.selected = selected
        self.action = action
    }

    var body: some View {
        if let action {
            Button(action: action) { pill }.buttonStyle(DTDPressStyle())
        } else {
            pill
        }
    }

    private var pill: some View {
        // ponytail: chip type scale (14/600) has no foundation token — hand-rolled.
        Text(label)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(foreground)
            .padding(.vertical, 9)
            .padding(.horizontal, DTDSpacing.x7)
            .background(background)
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch (tone, selected) {
        case (.surface, false): return DTDColor.textPrimary
        case (.surface, true):  return DTDColor.bg          // inverts to page colour
        case (.onPark, false):  return .white
        // ponytail: white pill on a park panel → fixed near-black ink (no neutral-ink token).
        case (.onPark, true):   return Color(hex: "#1B1B1F")
        }
    }

    @ViewBuilder private var background: some View {
        switch (tone, selected) {
        case (.surface, false): DTDColor.surfaceControl
        case (.surface, true):  DTDColor.textPrimary
        case (.onPark, false):  DTDColor.onParkBadge
        case (.onPark, true):   Color.white
        }
    }
}

#Preview("Light") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            DTDChip("Magic Kingdom")
            DTDChip("EPCOT", selected: true)
            DTDChip("Animal Kingdom")
        }
        ParkPanel(park: .disneyland, label: "DISNEYLAND") {
            HStack(spacing: 8) {
                DTDChip("Fantasyland", tone: .onPark)
                DTDChip("Tomorrowland", tone: .onPark, selected: true)
            }
        }
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            DTDChip("Magic Kingdom")
            DTDChip("EPCOT", selected: true)
            DTDChip("Animal Kingdom")
        }
        ParkPanel(park: .disneyland, label: "DISNEYLAND") {
            HStack(spacing: 8) {
                DTDChip("Fantasyland", tone: .onPark)
                DTDChip("Tomorrowland", tone: .onPark, selected: true)
            }
        }
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
