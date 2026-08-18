import SwiftUI

/// The countdown itself. Left-aligned, never outlined, never per-digit animated;
/// the unit sits on the numeral's baseline. Keeps the day-flip spring bump.
struct CountdownNumeral: View {
    enum Size {
        case hero, screen, milestone

        var role: DTDFont.Numeral {
            switch self {
            case .hero: return .hero
            case .screen: return .screen
            case .milestone: return .milestone
            }
        }
    }

    let value: Int
    var unit: String?
    var size: Size = .hero
    var onPark: Bool = true
    /// Explicit point-size override — used only for the iPad milestone screen, where the
    /// numeral grows to its share of the taller full-bleed panel (~220–240) rather than the
    /// fixed role size. `nil` keeps the role's iPhone size. When set, `trackingOverride`
    /// supplies the wider tracking the larger glyph needs.
    var pointSize: CGFloat? = nil
    var trackingOverride: CGFloat? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bump: CGFloat = 1

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 8) {
            numeralText
                .scaleEffect(bump, anchor: .bottomLeading)
            if let unit {
                Text(unit)
                    .font(DTDFont.title)
                    .foregroundStyle(foreground.opacity(0.7))
            }
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: value) { _, _ in
            guard !reduceMotion else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { bump = 1.08 }
        }
        .task(id: bump) {
            guard bump != 1 else { return }
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { bump = 1 }
        }
    }

    @ViewBuilder
    private var numeralText: some View {
        if let pointSize {
            Text("\(value)")
                .font(.system(size: pointSize, weight: .black, design: .rounded))
                .tracking(trackingOverride ?? size.role.tracking)
                .minimumScaleFactor(0.3)
                .allowsTightening(true)
        } else {
            Text("\(value)")
                .dtdNumeral(size.role)
        }
    }

    private var foreground: Color {
        onPark ? .white : DTDColor.textPrimary
    }
}

#Preview("Light") {
    VStack(alignment: .leading, spacing: 24) {
        CountdownNumeral(value: 45, unit: "days", onPark: false)
        CountdownNumeral(value: 3, unit: "of 7 days", size: .screen, onPark: false)
        ParkPanel(park: .hollywoodStudios, label: "HOLLYWOOD STUDIOS") {
            CountdownNumeral(value: 45, unit: "days")
        }
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: 24) {
        CountdownNumeral(value: 45, unit: "days", onPark: false)
        CountdownNumeral(value: 3, unit: "of 7 days", size: .screen, onPark: false)
        ParkPanel(park: .hollywoodStudios, label: "HOLLYWOOD STUDIOS") {
            CountdownNumeral(value: 45, unit: "days")
        }
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
