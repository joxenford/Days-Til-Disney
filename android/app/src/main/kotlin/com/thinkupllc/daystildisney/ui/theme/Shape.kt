package com.thinkupllc.daystildisney.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes
import androidx.compose.ui.unit.dp

/**
 * App shape scale.
 * Rounded corners throughout to match the friendly, magical aesthetic.
 */
val DisneyShapes = Shapes(
    // Small chips, badges, icon buttons
    extraSmall = RoundedCornerShape(4.dp),
    // Input fields, small cards
    small = RoundedCornerShape(8.dp),
    // Content cards, bottom sheets
    medium = RoundedCornerShape(16.dp),
    // Trip cards, the countdown hero container
    large = RoundedCornerShape(24.dp),
    // Full-screen overlays, celebration sheets
    extraLarge = RoundedCornerShape(32.dp),
)
