package com.thinkupllc.daystildisney.engine.theme

import androidx.compose.ui.graphics.Color
import com.thinkupllc.daystildisney.core.model.ParkColorPalette

/**
 * The complete visual theme for a Disney park at a specific time of day.
 * Computed by [ParkThemeProvider] from a [DisneyPark] and [TimeOfDay].
 *
 * This is what Views bind to — everything needed to render the full themed UI.
 */
data class ParkTheme(
    /** Core park brand palette. */
    val palette: ParkColorPalette,
    /** Time-of-day adjusted gradient start color. */
    val gradientStart: Color,
    /** Time-of-day adjusted gradient end color. */
    val gradientEnd: Color,
    /** Overlay tint applied on top of the gradient (stars, sunrise glow, etc). */
    val ambientOverlay: Color,
    /** Whether to show star/sparkle particles (night and dawn modes). */
    val showStarField: Boolean,
    /** The time-of-day context used to compute this theme. */
    val timeOfDay: TimeOfDay,
) {
    /** The gradient as a list for use with Brush.verticalGradient. */
    val gradientColors: List<Color>
        get() = listOf(gradientStart, gradientEnd)
}
