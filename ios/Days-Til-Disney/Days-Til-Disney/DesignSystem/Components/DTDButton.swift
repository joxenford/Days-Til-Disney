import SwiftUI

/// Full-width block action — the only button shape besides `DTDIconButton`.
/// Sentence case, no icons, no shadow. Stacked pairs use a 12px gap.
struct DTDButton: View {
    enum Variant {
        case primary          // ink fill, page-colour label
        case secondary        // surface fill, ink label
        case onPark           // page-colour fill on a park panel (affirmative)
        case outlineOnPark    // 1.5px white border on a park panel (secondary)
    }

    let title: String
    var variant: Variant = .primary
    var full: Bool = true
    let action: () -> Void

    init(_ title: String, variant: Variant = .primary, full: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.full = full
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DTDFont.bodyStrong)
                .foregroundStyle(foreground)
                .frame(maxWidth: full ? .infinity : nil)
                .padding(.vertical, 15)
                .padding(.horizontal, DTDSpacing.x10)
                .background(background)
                .overlay(
                    RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous)
                        .strokeBorder(DTDColor.onParkOutline, lineWidth: variant == .outlineOnPark ? 1.5 : 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous))
        }
        .buttonStyle(DTDPressStyle())
    }

    private var foreground: Color {
        switch variant {
        case .primary:       return DTDColor.bg
        case .secondary:     return DTDColor.textPrimary
        case .onPark:        return DTDColor.textPrimary
        case .outlineOnPark: return .white
        }
    }

    @ViewBuilder private var background: some View {
        switch variant {
        case .primary:       DTDColor.textPrimary
        case .secondary:     DTDColor.surface
        case .onPark:        DTDColor.bg
        case .outlineOnPark: Color.clear
        }
    }
}

#Preview("Light") {
    VStack(spacing: 12) {
        DTDButton("Create your first trip") {}
        DTDButton("I'll do this later", variant: .secondary) {}
        DTDButton("Disabled", variant: .primary) {}.disabled(true)
        ParkPanel(park: .magicKingdom, label: "MAGIC KINGDOM") {
            VStack(spacing: 12) {
                DTDButton("Let's go", variant: .onPark) {}
                DTDButton("Share it", variant: .outlineOnPark) {}
            }
        }
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(spacing: 12) {
        DTDButton("Create your first trip") {}
        DTDButton("I'll do this later", variant: .secondary) {}
        DTDButton("Disabled", variant: .primary) {}.disabled(true)
        ParkPanel(park: .magicKingdom, label: "MAGIC KINGDOM") {
            VStack(spacing: 12) {
                DTDButton("Let's go", variant: .onPark) {}
                DTDButton("Share it", variant: .outlineOnPark) {}
            }
        }
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
