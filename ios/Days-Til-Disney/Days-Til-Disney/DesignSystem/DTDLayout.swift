import CoreGraphics

/// "Toy Box" corner radii. Verbatim from
/// `docs/design/toy-box-redesign/design_system/tokens/radii.css`.
/// Use with `RoundedRectangle(cornerRadius:, style: .continuous)` everywhere —
/// nothing square, nothing sharper than `check` (9).
enum DTDRadius {
    static let check: CGFloat   = 9
    static let control: CGFloat = 14   // header icon buttons
    static let chip: CGFloat    = 16   // chip / trip swatch
    static let tileSm: CGFloat  = 22
    static let tile: CGFloat    = 26
    static let card: CGFloat    = 30
    static let hero: CGFloat    = 34   // park panel + share/widget
    static let device: CGFloat  = 44
    static let pill: CGFloat    = 999
}

/// "Toy Box" spacing scale. Verbatim from
/// `docs/design/toy-box-redesign/design_system/tokens/spacing.css`.
enum DTDSpacing {
    static let x1: CGFloat  = 4
    static let x2: CGFloat  = 6
    static let x3: CGFloat  = 8
    static let x4: CGFloat  = 10
    static let x5: CGFloat  = 12   // standard gap between tiles
    static let x6: CGFloat  = 14
    static let x7: CGFloat  = 16
    static let x8: CGFloat  = 18   // compact tile padding
    static let x9: CGFloat  = 20   // screen gutter
    static let x10: CGFloat = 22
    static let x11: CGFloat = 24   // hero tile padding
    static let x12: CGFloat = 26
    static let x14: CGFloat = 30
    static let x16: CGFloat = 36

    static let gutter: CGFloat = 20
    static let tileGap: CGFloat = 12
    static let tapMin: CGFloat = 44
}

/// iPad-only layout tokens (regular width). Verbatim from
/// `docs/design/toy-box-redesign/ipad-adaptation.md` §3. These grow *whitespace and
/// column count* only — components keep their iPhone radii/padding/type. Two-column
/// geometry is driven off the GeometryReader **container** width, never a screen fraction.
enum DTDPadLayout {
    static let space18: CGFloat = 32
    static let space20: CGFloat = 40
    static let space24: CGFloat = 64
    /// Regular-width outer margin (vs 20 on iPhone).
    static let gutterScreen: CGFloat = 40
    /// Clamp for family (a) single-column screens (Add Trip, Settings, Welcome, Packing, Milestone).
    static let maxContentWidth: CGFloat = 680
    /// Gap between the lead and trailing columns in family (b).
    static let colGap: CGFloat = 32
    /// Max width of the panel / lead column in family (b).
    static let panelColMax: CGFloat = 420
}
