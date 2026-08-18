import SwiftUI

/// Centralized typography definitions for DaysTilDisney.
/// All font choices respect Dynamic Type by using `.font(.custom(..., size:, relativeTo:))`.
enum DTDFont {
    // MARK: - Countdown display

    /// The giant number shown in the countdown hero (e.g., "45").
    static func countdownNumber(size: CGFloat = 96) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    /// "DAYS" label beneath the countdown number.
    static func countdownLabel(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    /// Large countdown number for the primary days display (88pt equivalent).
    static var countdownLarge: Font {
        .system(size: 88, weight: .black, design: .rounded)
    }

    /// Smaller countdown number for hours/minutes or secondary contexts (64pt equivalent).
    static var countdownSmall: Font {
        .system(size: 64, weight: .black, design: .rounded)
    }

    // MARK: - Display / hero text

    /// Large display text used for milestone messages ("100 Days of Magic!").
    static var displayLarge: Font {
        .system(.largeTitle, design: .rounded, weight: .bold)
    }

    static var displayMedium: Font {
        .system(.title, design: .rounded, weight: .bold)
    }

    // MARK: - UI chrome

    static var titlePrimary: Font {
        .system(.title2, design: .rounded, weight: .semibold)
    }

    static var titleSecondary: Font {
        .system(.title3, design: .rounded, weight: .medium)
    }

    static var headline: Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }

    static var body: Font {
        .system(.body, design: .default, weight: .regular)
    }

    static var bodyMedium: Font {
        .system(.body, design: .default, weight: .medium)
    }

    static var caption: Font {
        .system(.caption, design: .default, weight: .regular)
    }

    static var captionBold: Font {
        .system(.caption, design: .default, weight: .semibold)
    }

    static var label: Font {
        .system(.footnote, design: .rounded, weight: .medium)
    }

    // MARK: - Toy Box type scale
    // Values verbatim from docs/design/toy-box-redesign/design_system/tokens/typography.css.
    // Outfit → SF Pro Rounded (.rounded); Karla prose → .default. Weight map:
    // 800 → .black, 700 → .bold, 600 → .semibold, 500 → .medium, 400 → .regular.

    /// Oversized geometric numeral roles — the app's loudest element. Fixed size by
    /// design (numerals never reflow with Dynamic Type); apply via `.dtdNumeral(_:)`
    /// so tracking + shrink-to-fit are bundled and no call site hand-rolls `.tracking`.
    enum Numeral {
        case hero        // 118, home countdown
        case screen      // 96, trip detail / in-park
        case milestone   // 172
        case stat        // 40, stat tiles
        case inline      // 26, wait times / list badges

        var size: CGFloat {
            switch self {
            case .hero: return 118
            case .screen: return 96
            case .milestone: return 172
            case .stat: return 40
            case .inline: return 26
            }
        }

        /// Tracking in points (≈px). Numerals are tight.
        var tracking: CGFloat {
            switch self {
            case .hero: return -7
            case .screen: return -6
            case .milestone: return -12
            case .stat: return -2
            case .inline: return -1
            }
        }
        // Leading (0.84 hero/screen, 0.82 milestone, 1.0 stat/inline) is inert for the
        // single-glyph numerals these roles render, so it is documented but not applied.
    }

    static func numeral(_ role: Numeral) -> Font {
        .system(size: role.size, weight: .black, design: .rounded)
    }

    // MARK: - Structural + prose roles

    /// Welcome headline. 38 / .black / -1.4.
    static var display: Font { .system(size: 38, weight: .black, design: .rounded) }
    /// Trip name on a panel. 24 / .semibold / -0.4.
    static var title: Font { .system(size: 24, weight: .semibold, design: .rounded) }
    /// Daily-fact heading. 23 / .bold / -0.4.
    static var heading: Font { .system(size: 23, weight: .bold, design: .rounded) }
    /// Buttons, row titles. 17 / .semibold.
    static var bodyStrong: Font { .system(size: 17, weight: .semibold, design: .rounded) }
    /// Karla prose. 15 / .regular — Dynamic-Type-relative (scales).
    static var prose: Font { .system(.subheadline, design: .default, weight: .regular) }
    /// Uppercase section/eyebrow label. 12 / .bold / +1.4 tracking (apply at call site).
    static var labelUpper: Font { .system(size: 12, weight: .bold, design: .rounded) }
    /// Small uppercase label. 11 / .bold.
    static var labelSmall: Font { .system(size: 11, weight: .bold, design: .rounded) }
}

// MARK: - View extension helpers

extension View {
    func countdownStyle() -> some View {
        self.font(DTDFont.countdownNumber())
             .minimumScaleFactor(0.3)
             .allowsTightening(true)
    }

    func displayStyle() -> some View {
        self.font(DTDFont.displayLarge)
    }

    /// Applies a Toy Box numeral role: fixed-size rounded-black font + its tracking,
    /// with shrink-to-fit so large text/long values tighten instead of clipping.
    func dtdNumeral(_ role: DTDFont.Numeral) -> some View {
        self.font(DTDFont.numeral(role))
            .tracking(role.tracking)
            .minimumScaleFactor(0.3)
            .allowsTightening(true)
    }
}
