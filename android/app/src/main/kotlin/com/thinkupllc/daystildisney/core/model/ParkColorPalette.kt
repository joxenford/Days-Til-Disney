package com.thinkupllc.daystildisney.core.model

import androidx.compose.ui.graphics.Color

/**
 * Complete color palette for a Disney park.
 * Used by the theme engine to drive the entire visual presentation.
 *
 * All colors are Compose [Color] values so they can be used directly
 * in Composables without conversion.
 */
data class ParkColorPalette(
    /** The dominant brand color — buttons, accents, highlights. */
    val primary: Color,
    /** Complementary color — secondary surfaces, headers. */
    val secondary: Color,
    /** Pop color for calls-to-action and milestone celebrations. */
    val accent: Color,
    /** Gradient start (top of background). */
    val backgroundGradientStart: Color,
    /** Gradient end (bottom of background). */
    val backgroundGradientEnd: Color,
    /** Text color drawn on top of [primary] surfaces. */
    val textOnPrimary: Color,
    /** Text color drawn on top of background gradients. */
    val textOnBackground: Color = Color.White,
    /** Castle / icon silhouette tint color. */
    val silhouetteColor: Color = Color.White.copy(alpha = 0.9f),
)
