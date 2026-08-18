import SwiftUI

/// Small uppercase label titling a tile or section. 12/700, never sentence case.
/// Gold tone is reserved for the daily content card.
struct SectionLabel: View {
    enum Tone {
        case muted
        case gold
        case onPark
    }

    let text: String
    var loose: Bool = false
    var tone: Tone = .muted

    init(_ text: String, loose: Bool = false, tone: Tone = .muted) {
        self.text = text
        self.loose = loose
        self.tone = tone
    }

    var body: some View {
        Text(text)
            .font(DTDFont.labelUpper)
            .textCase(.uppercase)
            .tracking(loose ? 2.4 : 1.4)
            .foregroundStyle(color)
    }

    private var color: Color {
        switch tone {
        case .muted:  return DTDColor.textMuted
        case .gold:   return DTDColor.goldLabel
        case .onPark: return .white.opacity(0.78)
        }
    }
}

#Preview("Light") {
    VStack(alignment: .leading, spacing: 12) {
        SectionLabel("Packed")
        SectionLabel("Today's fact", tone: .gold)
        SectionLabel("3 of 8 milestones reached", loose: true)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: 12) {
        SectionLabel("Packed")
        SectionLabel("Today's fact", tone: .gold)
        SectionLabel("3 of 8 milestones reached", loose: true)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
