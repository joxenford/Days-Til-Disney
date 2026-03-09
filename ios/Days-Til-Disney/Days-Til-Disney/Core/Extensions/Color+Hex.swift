import SwiftUI

extension Color {
    /// Initialize a Color from a CSS-style hex string.
    /// Accepts formats: "#RRGGBB", "RRGGBB", "#RRGGBBAA", "RRGGBBAA"
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                         .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        let length = cleaned.count
        let r, g, b, a: Double

        switch length {
        case 6:
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8)  & 0xFF) / 255.0
            b = Double(rgb         & 0xFF) / 255.0
            a = 1.0
        case 8:
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8)  & 0xFF) / 255.0
            a = Double(rgb         & 0xFF) / 255.0
        default:
            // Fallback to a neutral gray for malformed strings.
            r = 0.5; g = 0.5; b = 0.5; a = 1.0
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

    /// Returns a hex string representation of this color.
    /// Note: Only reliable for colors created from hex or with known RGB components.
    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    // MARK: - Color blending

    /// Blends this color toward `other` by `strength` (0 = unchanged, 1 = fully `other`).
    /// Uses UIColor component math for accurate sRGB blending.
    func blended(with other: Color, strength: Double) -> Color {
        let t = min(max(strength, 0), 1)
        let base = UIColor(self)
        let overlay = UIColor(other)

        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        var or_: CGFloat = 0, og: CGFloat = 0, ob: CGFloat = 0, oa: CGFloat = 0

        base.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        overlay.getRed(&or_, green: &og, blue: &ob, alpha: &oa)

        let r = br + (or_ - br) * CGFloat(t)
        let g = bg + (og - bg) * CGFloat(t)
        let b = bb + (ob - bb) * CGFloat(t)
        let a = ba + (oa - ba) * CGFloat(t)
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }

    // MARK: - Semantic Disney colors

    /// A sparkly gold used across park theming.
    static let disneyGold = Color(hex: "#C9A84C")

    /// The "magic" shimmer accent used in celebrations.
    static let magicSparkle = Color(hex: "#FFE780")

    /// Deep Disney night sky for dark backgrounds.
    static let disneySkyNight = Color(hex: "#0D1B3E")
}
