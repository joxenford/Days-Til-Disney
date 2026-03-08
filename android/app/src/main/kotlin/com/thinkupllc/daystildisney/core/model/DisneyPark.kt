package com.thinkupllc.daystildisney.core.model

import androidx.compose.ui.graphics.Color

/**
 * All 12 Disney theme parks across all six resorts.
 * Each park carries its display metadata and color palette so the theme
 * engine can drive the full visual experience from a single enum value.
 */
enum class DisneyPark(
    val displayName: String,
    val resort: DisneyResort,
    /** Asset name used to load the castle/icon drawable. No extension — resolved at runtime. */
    val iconAssetName: String,
    val colorPalette: ParkColorPalette,
) {
    // ----- Walt Disney World -----

    MAGIC_KINGDOM(
        displayName = "Magic Kingdom",
        resort = DisneyResort.WALT_DISNEY_WORLD,
        iconAssetName = "castle_magic_kingdom",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF1A3A6B),          // Royal blue
            secondary = Color(0xFFB8962E),         // Gold
            accent = Color(0xFFE8C547),            // Bright gold
            backgroundGradientStart = Color(0xFF0D1B3E),
            backgroundGradientEnd = Color(0xFF1A3A6B),
            textOnPrimary = Color.White,
        ),
    ),

    EPCOT(
        displayName = "EPCOT",
        resort = DisneyResort.WALT_DISNEY_WORLD,
        iconAssetName = "castle_epcot",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF0077B6),           // EPCOT blue
            secondary = Color(0xFF48CAE4),         // Light teal
            accent = Color(0xFFADE8F4),            // Pale aqua
            backgroundGradientStart = Color(0xFF023E8A),
            backgroundGradientEnd = Color(0xFF0096C7),
            textOnPrimary = Color.White,
        ),
    ),

    HOLLYWOOD_STUDIOS(
        displayName = "Hollywood Studios",
        resort = DisneyResort.WALT_DISNEY_WORLD,
        iconAssetName = "castle_hollywood_studios",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF8B1A1A),           // Deep red
            secondary = Color(0xFFD4A017),         // Hollywood gold
            accent = Color(0xFFFF6B35),            // Warm orange
            backgroundGradientStart = Color(0xFF2C0A0A),
            backgroundGradientEnd = Color(0xFF8B1A1A),
            textOnPrimary = Color.White,
        ),
    ),

    ANIMAL_KINGDOM(
        displayName = "Animal Kingdom",
        resort = DisneyResort.WALT_DISNEY_WORLD,
        iconAssetName = "castle_animal_kingdom",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF2D6A4F),           // Forest green
            secondary = Color(0xFF8B5E3C),         // Earth brown
            accent = Color(0xFF95D5B2),            // Sage green
            backgroundGradientStart = Color(0xFF1B4332),
            backgroundGradientEnd = Color(0xFF2D6A4F),
            textOnPrimary = Color.White,
        ),
    ),

    // ----- Disneyland Resort -----

    DISNEYLAND(
        displayName = "Disneyland",
        resort = DisneyResort.DISNEYLAND_RESORT,
        iconAssetName = "castle_disneyland",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF8E44AD),           // Purple
            secondary = Color(0xFFF1A7D0),         // Pink
            accent = Color(0xFFFFD700),            // Gold
            backgroundGradientStart = Color(0xFF4A235A),
            backgroundGradientEnd = Color(0xFF8E44AD),
            textOnPrimary = Color.White,
        ),
    ),

    CALIFORNIA_ADVENTURE(
        displayName = "Disney California Adventure",
        resort = DisneyResort.DISNEYLAND_RESORT,
        iconAssetName = "castle_california_adventure",
        colorPalette = ParkColorPalette(
            primary = Color(0xFFD35400),           // Warm orange
            secondary = Color(0xFF2980B9),         // Sky blue
            accent = Color(0xFFF39C12),            // Sunburst yellow
            backgroundGradientStart = Color(0xFF7D3C00),
            backgroundGradientEnd = Color(0xFFD35400),
            textOnPrimary = Color.White,
        ),
    ),

    // ----- Tokyo Disney Resort -----

    TOKYO_DISNEYLAND(
        displayName = "Tokyo Disneyland",
        resort = DisneyResort.TOKYO_DISNEY_RESORT,
        iconAssetName = "castle_tokyo_disneyland",
        colorPalette = ParkColorPalette(
            primary = Color(0xFFCB4154),           // Cherry blossom red
            secondary = Color(0xFFFFC5C5),         // Sakura pink
            accent = Color(0xFFFFE4E1),            // Pale blush
            backgroundGradientStart = Color(0xFF7B1530),
            backgroundGradientEnd = Color(0xFFCB4154),
            textOnPrimary = Color.White,
        ),
    ),

    TOKYO_DISNEYSEA(
        displayName = "Tokyo DisneySea",
        resort = DisneyResort.TOKYO_DISNEY_RESORT,
        iconAssetName = "castle_tokyo_disneysea",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF1B3A5C),           // Deep ocean blue
            secondary = Color(0xFF2E86AB),         // Mediterranean blue
            accent = Color(0xFF48CAE4),            // Aqua
            backgroundGradientStart = Color(0xFF0A1628),
            backgroundGradientEnd = Color(0xFF1B3A5C),
            textOnPrimary = Color.White,
        ),
    ),

    // ----- Disneyland Paris -----

    DISNEYLAND_PARK_PARIS(
        displayName = "Disneyland Park Paris",
        resort = DisneyResort.DISNEYLAND_PARIS,
        iconAssetName = "castle_disneyland_paris",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF9B59B6),           // Lavender purple
            secondary = Color(0xFFE8A0BF),         // Rose pink
            accent = Color(0xFFE8D5F5),            // Soft violet
            backgroundGradientStart = Color(0xFF4C1B6B),
            backgroundGradientEnd = Color(0xFF9B59B6),
            textOnPrimary = Color.White,
        ),
    ),

    WALT_DISNEY_STUDIOS_PARK(
        displayName = "Walt Disney Studios Park",
        resort = DisneyResort.DISNEYLAND_PARIS,
        iconAssetName = "castle_wds_paris",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF2C3E50),           // Dark slate
            secondary = Color(0xFFE74C3C),         // Studio red
            accent = Color(0xFFF39C12),            // Spotlight yellow
            backgroundGradientStart = Color(0xFF1A252F),
            backgroundGradientEnd = Color(0xFF2C3E50),
            textOnPrimary = Color.White,
        ),
    ),

    // ----- Hong Kong Disneyland -----

    HONG_KONG_DISNEYLAND_PARK(
        displayName = "Hong Kong Disneyland",
        resort = DisneyResort.HONG_KONG_DISNEYLAND,
        iconAssetName = "castle_hong_kong",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF008080),           // Teal
            secondary = Color(0xFFB8962E),         // Gold
            accent = Color(0xFF4ECDC4),            // Bright teal
            backgroundGradientStart = Color(0xFF004040),
            backgroundGradientEnd = Color(0xFF008080),
            textOnPrimary = Color.White,
        ),
    ),

    // ----- Shanghai Disneyland -----

    SHANGHAI_DISNEYLAND_PARK(
        displayName = "Shanghai Disneyland",
        resort = DisneyResort.SHANGHAI_DISNEYLAND,
        iconAssetName = "castle_shanghai",
        colorPalette = ParkColorPalette(
            primary = Color(0xFF1A237E),           // Sapphire blue
            secondary = Color(0xFF9E9E9E),         // Silver
            accent = Color(0xFF90CAF9),            // Light blue
            backgroundGradientStart = Color(0xFF0D1340),
            backgroundGradientEnd = Color(0xFF1A237E),
            textOnPrimary = Color.White,
        ),
    );
}
