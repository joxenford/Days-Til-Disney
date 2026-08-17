import SwiftUI

/// Packing-list row. Checked = park-accent fill + `on-accent` check, struck label in
/// `text-done` (≥4.5:1 — never a lighter grey).
struct DTDCheckbox: View {
    let label: String
    var checked: Bool = false
    var size: CGFloat = 24
    let onToggle: () -> Void

    init(_ label: String, checked: Bool = false, size: CGFloat = 24, onToggle: @escaping () -> Void) {
        self.label = label
        self.checked = checked
        self.size = size
        self.onToggle = onToggle
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DTDSpacing.x5) {
                box
                Text(label)
                    .font(DTDFont.bodyStrong)
                    .foregroundStyle(checked ? DTDColor.textDone : DTDColor.textPrimary)
                    .strikethrough(checked, color: DTDColor.textDone)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(DTDPressStyle())
        .accessibilityLabel(label)
        .accessibilityValue(checked ? "checked" : "unchecked")
    }

    @ViewBuilder private var box: some View {
        RoundedRectangle(cornerRadius: DTDRadius.check, style: .continuous)
            .fill(checked ? DTDColor.accentInteractive : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: DTDRadius.check, style: .continuous)
                    .strokeBorder(DTDColor.hairline, lineWidth: checked ? 0 : 2)
            )
            .overlay {
                if checked {
                    Text("✓")
                        .font(.system(size: size * 0.62, weight: .bold, design: .rounded))
                        .foregroundStyle(DTDColor.onAccent)
                }
            }
            .frame(width: size, height: size)
    }
}

#Preview("Light") {
    VStack(alignment: .leading, spacing: 14) {
        DTDCheckbox("Sunscreen (SPF 50+)", checked: true) {}
        DTDCheckbox("Comfortable walking shoes") {}
        DTDCheckbox("Portable charger", size: 20) {}
    }
    .padding()
    .background(DTDColor.surfaceRaised)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: 14) {
        DTDCheckbox("Sunscreen (SPF 50+)", checked: true) {}
        DTDCheckbox("Comfortable walking shoes") {}
        DTDCheckbox("Portable charger", size: 20) {}
    }
    .padding()
    .background(DTDColor.surfaceRaised)
    .preferredColorScheme(.dark)
}
