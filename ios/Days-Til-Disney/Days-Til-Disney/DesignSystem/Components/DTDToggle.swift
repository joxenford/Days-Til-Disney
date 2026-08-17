import SwiftUI

/// Settings switch. 50×30 track, 24px knob, 3px inset. Accent fill when on
/// (gold in dark mode); the knob springs across.
struct DTDToggle: View {
    @Binding var isOn: Bool
    var accessibilityLabel: String = ""

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? DTDColor.accentInteractive : DTDColor.hairline)
                    .frame(width: 50, height: 30)
                Circle()
                    .fill(DTDColor.knob)
                    .frame(width: 24, height: 24)
                    .padding(.horizontal, 3)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        }
        .buttonStyle(DTDPressStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isOn ? "on" : "off")
    }
}

private struct DTDTogglePreview: View {
    @State private var on = true
    @State private var off = false
    var body: some View {
        VStack(spacing: 20) {
            DTDToggle(isOn: $on, accessibilityLabel: "Milestone notifications")
            DTDToggle(isOn: $off, accessibilityLabel: "iCloud sync")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(DTDColor.bg)
    }
}

#Preview("Light") { DTDTogglePreview() }
#Preview("Dark") { DTDTogglePreview().preferredColorScheme(.dark) }
