package com.thinkupllc.daystildisney.core.util

import androidx.compose.ui.graphics.Color

/**
 * Parses a hex color string into a Compose [Color].
 * Supports formats: "#RRGGBB", "#AARRGGBB", "RRGGBB", "AARRGGBB".
 *
 * @throws IllegalArgumentException if the string is not a valid hex color.
 */
fun String.toComposeColor(): Color {
    val cleaned = this.trimStart('#')
    return when (cleaned.length) {
        6 -> Color(android.graphics.Color.parseColor("#FF$cleaned"))
        8 -> Color(android.graphics.Color.parseColor("#$cleaned"))
        else -> throw IllegalArgumentException("Invalid hex color string: $this")
    }
}

/**
 * Returns a [Color] with its alpha component multiplied by [factor].
 * Useful for creating translucent variants of brand colors.
 */
fun Color.withAlphaFactor(factor: Float): Color =
    this.copy(alpha = (this.alpha * factor).coerceIn(0f, 1f))

/**
 * Linearly interpolates between two [Color] values.
 * @param other The target color.
 * @param fraction 0.0 = fully this color, 1.0 = fully [other].
 */
fun Color.lerp(other: Color, fraction: Float): Color {
    val f = fraction.coerceIn(0f, 1f)
    return Color(
        red = this.red + (other.red - this.red) * f,
        green = this.green + (other.green - this.green) * f,
        blue = this.blue + (other.blue - this.blue) * f,
        alpha = this.alpha + (other.alpha - this.alpha) * f,
    )
}
