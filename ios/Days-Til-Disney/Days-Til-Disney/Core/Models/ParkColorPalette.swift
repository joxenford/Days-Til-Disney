import SwiftUI

/// Defines the complete color system for a Disney park's visual identity.
struct ParkColorPalette: Sendable {
    let primary: Color
    let secondary: Color
    let accent: Color
    let backgroundGradientStart: Color
    let backgroundGradientEnd: Color
    let textOnPrimary: Color

    // MARK: - Pre-defined palettes per park

    static let magicKingdom = ParkColorPalette(
        primary: Color(hex: "#1A3A6B"),           // Royal blue
        secondary: Color(hex: "#C9A84C"),         // Gold
        accent: Color(hex: "#E8C84A"),            // Bright gold
        backgroundGradientStart: Color(hex: "#0D2545"),
        backgroundGradientEnd: Color(hex: "#2B5BA0"),
        textOnPrimary: .white
    )

    static let epcot = ParkColorPalette(
        primary: Color(hex: "#0077B6"),           // Future blue
        secondary: Color(hex: "#00B4D8"),         // Aqua
        accent: Color(hex: "#90E0EF"),            // Light aqua
        backgroundGradientStart: Color(hex: "#023E8A"),
        backgroundGradientEnd: Color(hex: "#0096C7"),
        textOnPrimary: .white
    )

    static let hollywoodStudios = ParkColorPalette(
        primary: Color(hex: "#C0392B"),           // Hollywood red
        secondary: Color(hex: "#F39C12"),         // Golden amber
        accent: Color(hex: "#F1C40F"),            // Yellow
        backgroundGradientStart: Color(hex: "#7B241C"),
        backgroundGradientEnd: Color(hex: "#C0392B"),
        textOnPrimary: .white
    )

    static let animalKingdom = ParkColorPalette(
        primary: Color(hex: "#2E7D32"),           // Safari green
        secondary: Color(hex: "#8D6E63"),         // Earth brown
        accent: Color(hex: "#FFC107"),            // Amber
        backgroundGradientStart: Color(hex: "#1B5E20"),
        backgroundGradientEnd: Color(hex: "#4CAF50"),
        textOnPrimary: .white
    )

    static let disneyland = ParkColorPalette(
        primary: Color(hex: "#8E44AD"),           // Sleeping Beauty purple
        secondary: Color(hex: "#E91E8C"),         // Pink
        accent: Color(hex: "#F8BBD9"),            // Light pink
        backgroundGradientStart: Color(hex: "#4A148C"),
        backgroundGradientEnd: Color(hex: "#CE93D8"),
        textOnPrimary: .white
    )

    static let californiaAdventure = ParkColorPalette(
        primary: Color(hex: "#E64A19"),           // California sunset orange
        secondary: Color(hex: "#FFB300"),         // Amber gold
        accent: Color(hex: "#FFE082"),            // Light gold
        backgroundGradientStart: Color(hex: "#BF360C"),
        backgroundGradientEnd: Color(hex: "#FF7043"),
        textOnPrimary: .white
    )

    static let tokyoDisneyland = ParkColorPalette(
        primary: Color(hex: "#C62828"),           // Deep red
        secondary: Color(hex: "#F48FB1"),         // Cherry blossom pink
        accent: Color(hex: "#FCE4EC"),            // Blossom white-pink
        backgroundGradientStart: Color(hex: "#880E4F"),
        backgroundGradientEnd: Color(hex: "#E91E63"),
        textOnPrimary: .white
    )

    static let tokyoDisneySea = ParkColorPalette(
        primary: Color(hex: "#1565C0"),           // Deep sea blue
        secondary: Color(hex: "#0288D1"),         // Ocean blue
        accent: Color(hex: "#80DEEA"),            // Sea foam
        backgroundGradientStart: Color(hex: "#0D47A1"),
        backgroundGradientEnd: Color(hex: "#1976D2"),
        textOnPrimary: .white
    )

    static let disneylandParkParis = ParkColorPalette(
        primary: Color(hex: "#7B1FA2"),           // Lavender purple
        secondary: Color(hex: "#EC407A"),         // Rose
        accent: Color(hex: "#F8BBD9"),            // Soft rose
        backgroundGradientStart: Color(hex: "#4A148C"),
        backgroundGradientEnd: Color(hex: "#AB47BC"),
        textOnPrimary: .white
    )

    static let waltDisneyStudiosPark = ParkColorPalette(
        primary: Color(hex: "#D32F2F"),           // Studio red
        secondary: Color(hex: "#FFA000"),         // Amber
        accent: Color(hex: "#FFE57F"),            // Golden
        backgroundGradientStart: Color(hex: "#B71C1C"),
        backgroundGradientEnd: Color(hex: "#EF5350"),
        textOnPrimary: .white
    )

    static let hongKongDisneylandPark = ParkColorPalette(
        primary: Color(hex: "#00796B"),           // Teal
        secondary: Color(hex: "#C9A84C"),         // Gold
        accent: Color(hex: "#FFD54F"),            // Light gold
        backgroundGradientStart: Color(hex: "#004D40"),
        backgroundGradientEnd: Color(hex: "#26A69A"),
        textOnPrimary: .white
    )

    static let shanghaiDisneylandPark = ParkColorPalette(
        primary: Color(hex: "#1A237E"),           // Sapphire blue
        secondary: Color(hex: "#9E9E9E"),         // Silver
        accent: Color(hex: "#E0E0E0"),            // Light silver
        backgroundGradientStart: Color(hex: "#0D1757"),
        backgroundGradientEnd: Color(hex: "#3949AB"),
        textOnPrimary: .white
    )

    // MARK: - Time-of-Day Overlay Colors

    struct TimeOfDayOverlay {
        let gradientStart: Color
        let gradientEnd: Color
        let opacity: Double
    }

    static let dawnOverlay = TimeOfDayOverlay(
        gradientStart: Color(hex: "#FF9966"),
        gradientEnd: Color(hex: "#FFB347"),
        opacity: 0.25
    )

    static let dayOverlay = TimeOfDayOverlay(
        gradientStart: .clear,
        gradientEnd: .clear,
        opacity: 0.0
    )

    static let duskOverlay = TimeOfDayOverlay(
        gradientStart: Color(hex: "#FF6B35"),
        gradientEnd: Color(hex: "#8E44AD"),
        opacity: 0.30
    )

    static let nightOverlay = TimeOfDayOverlay(
        gradientStart: Color(hex: "#1a1a2e"),
        gradientEnd: Color(hex: "#16213E"),
        opacity: 0.45
    )
}
