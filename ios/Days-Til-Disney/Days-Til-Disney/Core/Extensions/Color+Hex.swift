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

    // MARK: - Semantic Disney colors

    /// A sparkly gold used across park theming.
    static let disneyGold = Color(hex: "#C9A84C")

    /// The "magic" shimmer accent used in celebrations.
    static let magicSparkle = Color(hex: "#FFE780")

    /// Deep Disney night sky for dark backgrounds.
    static let disneySkyNight = Color(hex: "#0D1B3E")
}
