import SwiftUI

/// Secondary/past trip in the Home list. The park colour appears only as the 44px swatch;
/// past trips render dimmed to 60%.
struct TripRow: View {
    let name: String
    var meta: String?
    let park: DisneyPark
    var dimmed: Bool = false
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: DTDSpacing.x6) {
                // Swatch is the raw park primary (TripRow.d.ts), not the panel resolver —
                // a park-identity dot, not a park panel.
                RoundedRectangle(cornerRadius: DTDRadius.chip, style: .continuous)
                    .fill(park.colorPalette.primary)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(DTDFont.bodyStrong)
                        .foregroundStyle(DTDColor.textPrimary)
                        .lineLimit(1)
                    if let meta {
                        Text(meta)
                            .font(DTDFont.prose)
                            .foregroundStyle(DTDColor.textMuted)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                Text("›")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(DTDColor.textFaint)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(DTDPressStyle())
        .opacity(dimmed ? 0.6 : 1)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    VStack(spacing: 12) {
        TripRow(name: "Tokyo Adventure", meta: "Day 3 of 7 — you're there!", park: .tokyoDisneyland)
        TripRow(name: "Disneyland Summer 2024", meta: "Complete", park: .disneyland, dimmed: true)
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(spacing: 12) {
        TripRow(name: "Tokyo Adventure", meta: "Day 3 of 7 — you're there!", park: .tokyoDisneyland)
        TripRow(name: "Disneyland Summer 2024", meta: "Complete", park: .disneyland, dimmed: true)
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
