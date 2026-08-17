import SwiftUI

/// Two- or three-way choice; used for the theme picker (Light / Dark / System).
/// Active segment = ink fill, page-colour label. Labels are sentence case and short.
struct SegmentedControl: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let active = option == selection
                Button {
                    selection = option
                } label: {
                    Text(option)
                        .font(DTDFont.bodyStrong)
                        .foregroundStyle(active ? DTDColor.bg : DTDColor.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(active ? DTDColor.textPrimary : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.control - 4, style: .continuous))
                        .contentShape(Rectangle())
                }
                .buttonStyle(DTDPressStyle())
            }
        }
        .padding(4)
        .background(DTDColor.surfaceControl)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.control, style: .continuous))
    }
}

private struct SegmentedControlPreview: View {
    @State private var value = "Dark"
    var body: some View {
        SegmentedControl(options: ["Light", "Dark", "System"], selection: $value)
            .padding()
            .background(DTDColor.bg)
    }
}

#Preview("Light") { SegmentedControlPreview() }
#Preview("Dark") { SegmentedControlPreview().preferredColorScheme(.dark) }
