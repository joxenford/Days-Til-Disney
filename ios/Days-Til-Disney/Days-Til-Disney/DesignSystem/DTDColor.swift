import SwiftUI
import UIKit

/// Semantic "Toy Box" colour roles. Values are verbatim from
/// `docs/design/toy-box-redesign/design_system/tokens/colors.css`.
///
/// Theme-aware roles resolve automatically via a dynamic `UIColor`, so **no call
/// site ever branches on `colorScheme`** — a single `DTDColor.bg` renders correctly
/// in light and dark. (Park-panel fills are the one explicit-scheme exception; see
/// `ParkColorPalette.panelColor(for:)`.)
enum DTDColor {

    /// A `Color` that resolves `light`/`dark` hex from the render trait environment.
    private static func themed(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }

    // MARK: - Surfaces
    static let bg             = themed(light: "#F3F3F1", dark: "#15151A")
    static let surface        = themed(light: "#E7E7E3", dark: "#202028")
    static let surfaceRaised  = themed(light: "#FFFFFF", dark: "#26262E")
    static let surfaceControl = themed(light: "#E4E4E0", dark: "#26262E")
    static let hairline       = themed(light: "#D2D2CD", dark: "#2E2E38")

    // MARK: - Text
    static let textPrimary = themed(light: "#1B1B1F", dark: "#F1F1EF")
    static let textMuted   = themed(light: "#5F5F66", dark: "#9A99A2")
    static let textFaint   = themed(light: "#63636A", dark: "#93929B")
    static let textDone    = themed(light: "#6E6E75", dark: "#93929B")

    // MARK: - Interactive
    /// Toggle track, checkbox fill, progress fill. Navy on light, gold on dark.
    static let accentInteractive = themed(light: "#1A3A6B", dark: "#E8C84A")
    /// Glyph/text sitting on an `accentInteractive` fill.
    static let onAccent          = themed(light: "#FFFFFF", dark: "#3E3208")
    /// Switch knob.
    static let knob              = themed(light: "#F3F3F1", dark: "#15151A")

    // MARK: - Gold
    static let gold      = Color(hex: "#E8C84A")
    static let goldDeep  = Color(hex: "#C9A84C")
    static let goldInk   = Color(hex: "#3E3208")
    /// "TODAY'S FACT" / LL·ILL meta text. Darkened gold on light, full gold on dark.
    static let goldLabel = themed(light: "#7A6420", dark: "#E8C84A")

    // MARK: - Wait-time text roles (large text, 3:1 minimum — do not shrink)
    static let waitShort = themed(light: "#2E7D32", dark: "#4CAF50")
    static let waitMid   = themed(light: "#7A6420", dark: "#E8C84A")
    static let waitLong  = themed(light: "#C0392B", dark: "#FF6B6B")

    // MARK: - Status fills (surface-agnostic dots/badges — not theme-varying)
    static let statusOperating = Color(hex: "#4CAF50")
    static let statusClosed    = Color(hex: "#F44336")
    static let statusRefurb    = Color(hex: "#FF9800")
    static let statusLongWait  = Color(hex: "#FF6B6B")

    // MARK: - On-park transparencies (over a park panel)
    /// Chips / badges pill fill.
    static let onParkBadge   = Color.white.opacity(0.18)
    /// 1.5px outline on unselected on-park rows.
    static let onParkOutline = Color.white.opacity(0.35)
}
