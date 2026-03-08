package com.thinkupllc.daystildisney.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import com.thinkupllc.daystildisney.engine.theme.ParkTheme
import com.thinkupllc.daystildisney.ui.theme.LocalParkTheme

/**
 * A full-screen gradient background driven by the active [ParkTheme].
 * The gradient colors animate smoothly when the theme changes (e.g., at midnight
 * when the time-of-day shifts, or when the user switches trips).
 *
 * Falls back to a deep navy default when no park theme is available.
 */
@Composable
fun GradientBackground(
    modifier: Modifier = Modifier,
    parkTheme: ParkTheme? = LocalParkTheme.current,
    content: @Composable BoxScope.() -> Unit,
) {
    val gradientStart = parkTheme?.gradientStart ?: Color(0xFF0D1B3E)
    val gradientEnd = parkTheme?.gradientEnd ?: Color(0xFF1A3A6B)

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(gradientStart, gradientEnd)
                )
            ),
        content = content,
    )
}
