import SwiftUI

/// 36px rounded-square header button carrying a typographic glyph (`+ ‹ ••• ↻ › ✓`) —
/// **not** an SF Symbol. `accessibilityLabel` is required so no glyph-only button ships
/// unlabeled (preserves `buttons["Settings"]` etc. for the UITests).
struct DTDIconButton: View {
    enum Tone {
        case loud    // ink fill — the primary add action
        case quiet   // surface-control fill
    }

    let glyph: String
    let accessibilityLabel: String
    var tone: Tone = .quiet
    let action: () -> Void

    init(glyph: String, accessibilityLabel: String, tone: Tone = .quiet, action: @escaping () -> Void) {
        self.glyph = glyph
        self.accessibilityLabel = accessibilityLabel
        self.tone = tone
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(glyph)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(tone == .loud ? DTDColor.bg : DTDColor.textPrimary)
                .frame(width: 36, height: 36)
                .background(tone == .loud ? DTDColor.textPrimary : DTDColor.surfaceControl)
                .clipShape(RoundedRectangle(cornerRadius: DTDRadius.control, style: .continuous))
                .frame(width: DTDSpacing.tapMin, height: DTDSpacing.tapMin) // 44px hit area
                .contentShape(Rectangle())
        }
        .buttonStyle(DTDPressStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview("Light") {
    HStack(spacing: 12) {
        DTDIconButton(glyph: "‹", accessibilityLabel: "Back") {}
        DTDIconButton(glyph: "+", accessibilityLabel: "Add trip", tone: .loud) {}
        DTDIconButton(glyph: "•••", accessibilityLabel: "Settings") {}
        DTDIconButton(glyph: "↻", accessibilityLabel: "Refresh") {}
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    HStack(spacing: 12) {
        DTDIconButton(glyph: "‹", accessibilityLabel: "Back") {}
        DTDIconButton(glyph: "+", accessibilityLabel: "Add trip", tone: .loud) {}
        DTDIconButton(glyph: "•••", accessibilityLabel: "Settings") {}
        DTDIconButton(glyph: "↻", accessibilityLabel: "Refresh") {}
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
