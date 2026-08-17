import SwiftUI

/// Neutral tile carrying one number. Used in pairs. Radius 26, padding 18/20.
struct StatTile<Content: View>: View {
    let label: String
    let value: String
    var sub: String?
    var caption: String?
    @ViewBuilder let content: () -> Content

    init(label: String,
         value: String,
         sub: String? = nil,
         caption: String? = nil,
         @ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
        self.label = label
        self.value = value
        self.sub = sub
        self.caption = caption
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x4) {
            SectionLabel(label)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).dtdNumeral(.stat)
                if let sub {
                    // Denominator = parent numeral at half size, text-faint (Typography.swift:175).
                    Text(sub)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(DTDColor.textFaint)
                }
            }
            .foregroundStyle(DTDColor.textPrimary)
            if let caption {
                Text(caption)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                    .lineLimit(2)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }
}

#Preview("Light") {
    HStack(spacing: 12) {
        StatTile(label: "Packed", value: "12", sub: "/38") {
            DTDProgressBar(value: 12, total: 38).padding(.top, 4)
        }
        StatTile(label: "Next up", value: "30", caption: "days → one month to go")
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    HStack(spacing: 12) {
        StatTile(label: "Packed", value: "12", sub: "/38") {
            DTDProgressBar(value: 12, total: 38).padding(.top, 4)
        }
        StatTile(label: "Next up", value: "30", caption: "days → one month to go")
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
