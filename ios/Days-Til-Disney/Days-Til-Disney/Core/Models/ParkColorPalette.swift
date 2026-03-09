import SwiftUI

/// Defines the complete color system for a Disney park's visual identity.
struct ParkColorPalette: Sendable {
    let primary: Color
    let secondary: Color
    let accent: Color
    let backgroundGradientStart: Color
    /// Optional middle stops for richer multi-stop gradients.
    let backgroundGradientMid1: Color
    let backgroundGradientMid2: Color
    let backgroundGradientEnd: Color
    let textOnPrimary: Color

    /// Returns the full ordered gradient stops: start → mid1 → mid2 → end.
    var gradientStops: [Color] {
        [backgroundGradientStart, backgroundGradientMid1, backgroundGradientMid2, backgroundGradientEnd]
    }

    // MARK: - Pre-defined palettes per park

    /// Magic Kingdom — deep royal blue midnight sky fading to sapphire and golden horizon.
    static let magicKingdom = ParkColorPalette(
        primary: Color(hex: "#1A3A6B"),
        secondary: Color(hex: "#C9A84C"),
        accent: Color(hex: "#E8C84A"),
        backgroundGradientStart: Color(hex: "#080E24"),   // Near-black midnight
        backgroundGradientMid1: Color(hex: "#0D2545"),    // Deep royal navy
        backgroundGradientMid2: Color(hex: "#1A3A6B"),    // Royal blue
        backgroundGradientEnd: Color(hex: "#2B5BA0"),     // Bright sapphire horizon
        textOnPrimary: .white
    )

    /// EPCOT — futuristic deep navy transitioning to vivid ocean blue.
    static let epcot = ParkColorPalette(
        primary: Color(hex: "#0077B6"),
        secondary: Color(hex: "#00B4D8"),
        accent: Color(hex: "#90E0EF"),
        backgroundGradientStart: Color(hex: "#03112B"),   // Deep space navy
        backgroundGradientMid1: Color(hex: "#023E8A"),    // Dark future blue
        backgroundGradientMid2: Color(hex: "#0077B6"),    // EPCOT signature blue
        backgroundGradientEnd: Color(hex: "#00B4D8"),     // Bright aqua
        textOnPrimary: .white
    )

    /// Hollywood Studios — noir charcoal to dramatic Hollywood crimson-amber.
    static let hollywoodStudios = ParkColorPalette(
        primary: Color(hex: "#C0392B"),
        secondary: Color(hex: "#F39C12"),
        accent: Color(hex: "#F1C40F"),
        backgroundGradientStart: Color(hex: "#1A0A08"),   // Near-black charcoal
        backgroundGradientMid1: Color(hex: "#7B241C"),    // Deep Hollywood red
        backgroundGradientMid2: Color(hex: "#C0392B"),    // Cinematic crimson
        backgroundGradientEnd: Color(hex: "#E8820C"),     // Warm amber spotlight
        textOnPrimary: .white
    )

    /// Animal Kingdom — rich jungle earth through layered greens to golden savanna.
    static let animalKingdom = ParkColorPalette(
        primary: Color(hex: "#2E7D32"),
        secondary: Color(hex: "#8D6E63"),
        accent: Color(hex: "#FFC107"),
        backgroundGradientStart: Color(hex: "#0B1F0C"),   // Deep jungle shadow
        backgroundGradientMid1: Color(hex: "#1B5E20"),    // Dark forest green
        backgroundGradientMid2: Color(hex: "#2E7D32"),    // Vibrant canopy
        backgroundGradientEnd: Color(hex: "#558B2F"),     // Sunlit savanna green
        textOnPrimary: .white
    )

    /// Disneyland — Sleeping Beauty castle: deep amethyst to lilac dawn.
    static let disneyland = ParkColorPalette(
        primary: Color(hex: "#8E44AD"),
        secondary: Color(hex: "#E91E8C"),
        accent: Color(hex: "#F8BBD9"),
        backgroundGradientStart: Color(hex: "#1A0630"),   // Deep twilight violet
        backgroundGradientMid1: Color(hex: "#4A148C"),    // Rich amethyst
        backgroundGradientMid2: Color(hex: "#7B1FA2"),    // Vivid purple
        backgroundGradientEnd: Color(hex: "#CE93D8"),     // Soft lilac
        textOnPrimary: .white
    )

    /// California Adventure — Pacific sunset: terracotta to blazing orange-gold.
    static let californiaAdventure = ParkColorPalette(
        primary: Color(hex: "#E64A19"),
        secondary: Color(hex: "#FFB300"),
        accent: Color(hex: "#FFE082"),
        backgroundGradientStart: Color(hex: "#3E1000"),   // Deep sunset rust
        backgroundGradientMid1: Color(hex: "#BF360C"),    // Terracotta
        backgroundGradientMid2: Color(hex: "#E64A19"),    // California orange
        backgroundGradientEnd: Color(hex: "#FFB300"),     // Golden hour amber
        textOnPrimary: .white
    )

    /// Tokyo Disneyland — cherry blossom magic: deep crimson to delicate pink.
    static let tokyoDisneyland = ParkColorPalette(
        primary: Color(hex: "#C62828"),
        secondary: Color(hex: "#F48FB1"),
        accent: Color(hex: "#FCE4EC"),
        backgroundGradientStart: Color(hex: "#2D0112"),   // Deep ruby
        backgroundGradientMid1: Color(hex: "#880E4F"),    // Dark cerise
        backgroundGradientMid2: Color(hex: "#C62828"),    // Cherry red
        backgroundGradientEnd: Color(hex: "#E91E63"),     // Blossom pink
        textOnPrimary: .white
    )

    /// Tokyo DisneySea — ocean depths: near-black sea to vibrant teal-blue.
    static let tokyoDisneySea = ParkColorPalette(
        primary: Color(hex: "#1565C0"),
        secondary: Color(hex: "#0288D1"),
        accent: Color(hex: "#80DEEA"),
        backgroundGradientStart: Color(hex: "#020D20"),   // Abyss black-blue
        backgroundGradientMid1: Color(hex: "#0D47A1"),    // Deep sea
        backgroundGradientMid2: Color(hex: "#1565C0"),    // Ocean blue
        backgroundGradientEnd: Color(hex: "#0288D1"),     // Surface shimmer
        textOnPrimary: .white
    )

    /// Disneyland Paris — Enchanted Storybook: deep indigo to soft lavender rose.
    static let disneylandParkParis = ParkColorPalette(
        primary: Color(hex: "#7B1FA2"),
        secondary: Color(hex: "#EC407A"),
        accent: Color(hex: "#F8BBD9"),
        backgroundGradientStart: Color(hex: "#160026"),   // Deep twilight indigo
        backgroundGradientMid1: Color(hex: "#4A148C"),    // Enchanted purple
        backgroundGradientMid2: Color(hex: "#7B1FA2"),    // Story-book violet
        backgroundGradientEnd: Color(hex: "#AB47BC"),     // Lavender
        textOnPrimary: .white
    )

    /// Walt Disney Studios Park Paris — silver screen: dark slate to vivid studio red.
    static let waltDisneyStudiosPark = ParkColorPalette(
        primary: Color(hex: "#D32F2F"),
        secondary: Color(hex: "#FFA000"),
        accent: Color(hex: "#FFE57F"),
        backgroundGradientStart: Color(hex: "#1A0000"),   // Film noir black
        backgroundGradientMid1: Color(hex: "#B71C1C"),    // Deep cinematic red
        backgroundGradientMid2: Color(hex: "#D32F2F"),    // Studio red
        backgroundGradientEnd: Color(hex: "#FF7043"),     // Warm amber-orange
        textOnPrimary: .white
    )

    /// Hong Kong Disneyland — emerald teal contrasted with gold accents.
    static let hongKongDisneylandPark = ParkColorPalette(
        primary: Color(hex: "#00796B"),
        secondary: Color(hex: "#C9A84C"),
        accent: Color(hex: "#FFD54F"),
        backgroundGradientStart: Color(hex: "#001611"),   // Deep jungle teal
        backgroundGradientMid1: Color(hex: "#004D40"),    // Dark emerald
        backgroundGradientMid2: Color(hex: "#00796B"),    // Teal
        backgroundGradientEnd: Color(hex: "#26A69A"),     // Bright seafoam
        textOnPrimary: .white
    )

    /// Shanghai Disneyland — sapphire storybook: dark midnight to vivid cobalt.
    static let shanghaiDisneylandPark = ParkColorPalette(
        primary: Color(hex: "#1A237E"),
        secondary: Color(hex: "#9E9E9E"),
        accent: Color(hex: "#E0E0E0"),
        backgroundGradientStart: Color(hex: "#050A1E"),   // Midnight sapphire
        backgroundGradientMid1: Color(hex: "#0D1757"),    // Deep sapphire
        backgroundGradientMid2: Color(hex: "#1A237E"),    // Cobalt blue
        backgroundGradientEnd: Color(hex: "#3949AB"),     // Bright indigo
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
