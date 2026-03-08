package com.thinkupllc.daystildisney.engine.theme

import androidx.compose.ui.graphics.Color
import com.thinkupllc.daystildisney.core.model.DisneyPark
import com.thinkupllc.daystildisney.core.util.lerp
import javax.inject.Inject

/**
 * Computes a [ParkTheme] for a given park and time of day.
 * The time-of-day adjustment applies a subtle ambient color blend over the
 * park's base palette — preserving brand identity while evoking the mood.
 */
class ParkThemeProvider @Inject constructor(
    private val timeOfDayProvider: TimeOfDayProvider,
) {
    fun getTheme(park: DisneyPark): ParkTheme {
        return getTheme(park, timeOfDayProvider.getCurrentTimeOfDay())
    }

    fun getTheme(park: DisneyPark, timeOfDay: TimeOfDay): ParkTheme {
        val palette = park.colorPalette
        val (gradientStart, gradientEnd, overlay, showStars) = computeAmbient(
            timeOfDay = timeOfDay,
            baseStart = palette.backgroundGradientStart,
            baseEnd = palette.backgroundGradientEnd,
        )
        return ParkTheme(
            palette = palette,
            gradientStart = gradientStart,
            gradientEnd = gradientEnd,
            ambientOverlay = overlay,
            showStarField = showStars,
            timeOfDay = timeOfDay,
        )
    }

    /**
     * Computes the time-of-day ambient colors by blending the park's base gradient
     * with ambient overlay colors.
     */
    private fun computeAmbient(
        timeOfDay: TimeOfDay,
        baseStart: Color,
        baseEnd: Color,
    ): AmbientColors {
        return when (timeOfDay) {
            TimeOfDay.DAWN -> AmbientColors(
                gradientStart = baseStart.lerp(Color(0xFFFF8C69), 0.25f),  // Soft salmon sunrise
                gradientEnd = baseEnd.lerp(Color(0xFFFFB347), 0.20f),      // Warm orange
                overlay = Color(0x22FF8C00),                                // Faint sunrise glow
                showStarField = true,
            )
            TimeOfDay.DAY -> AmbientColors(
                gradientStart = baseStart,
                gradientEnd = baseEnd,
                overlay = Color.Transparent,
                showStarField = false,
            )
            TimeOfDay.DUSK -> AmbientColors(
                gradientStart = baseStart.lerp(Color(0xFFFF6B35), 0.20f),  // Warm sunset orange
                gradientEnd = baseEnd.lerp(Color(0xFF6A0572), 0.25f),      // Deep purple horizon
                overlay = Color(0x22FF4500),                                // Orange glow
                showStarField = false,
            )
            TimeOfDay.NIGHT -> AmbientColors(
                gradientStart = baseStart.lerp(Color(0xFF0A0A2A), 0.50f),  // Deep midnight blue
                gradientEnd = baseEnd.lerp(Color(0xFF1A0A3A), 0.40f),      // Dark indigo
                overlay = Color(0x11FFFFFF),                                // Faint starlight
                showStarField = true,
            )
        }
    }

    private data class AmbientColors(
        val gradientStart: Color,
        val gradientEnd: Color,
        val overlay: Color,
        val showStarField: Boolean,
    )
}
