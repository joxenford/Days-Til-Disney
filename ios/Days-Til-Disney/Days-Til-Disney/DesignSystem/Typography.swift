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
}
