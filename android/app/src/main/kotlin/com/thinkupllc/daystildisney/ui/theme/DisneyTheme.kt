package com.thinkupllc.daystildisney.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import com.thinkupllc.daystildisney.engine.theme.ParkTheme

// ---------------------------------------------------------------------------
// Base Material 3 color schemes (used before a park theme is loaded)
// ---------------------------------------------------------------------------

private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF1A3A6B),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFD0E4FF),
    onPrimaryContainer = Color(0xFF001C3D),
    secondary = Color(0xFFB8962E),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFFFE099),
    onSecondaryContainer = Color(0xFF261900),
    tertiary = Color(0xFF8E44AD),
    onTertiary = Color.White,
    background = Color(0xFFF8F9FF),
    onBackground = Color(0xFF1A1B20),
    surface = Color(0xFFFCFCFF),
    onSurface = Color(0xFF1A1B20),
    surfaceVariant = Color(0xFFDFE2EB),
    onSurfaceVariant = Color(0xFF43474E),
    outline = Color(0xFF73777F),
    error = Color(0xFFBA1A1A),
    onError = Color.White,
)

private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFF9ECAFF),
    onPrimary = Color(0xFF003063),
    primaryContainer = Color(0xFF00468B),
    onPrimaryContainer = Color(0xFFD0E4FF),
    secondary = Color(0xFFE8C547),
    onSecondary = Color(0xFF3B2E00),
    secondaryContainer = Color(0xFF564400),
    onSecondaryContainer = Color(0xFFFFE099),
    tertiary = Color(0xFFDDB0F5),
    onTertiary = Color(0xFF4D0072),
    background = Color(0xFF0A0A1A),
    onBackground = Color(0xFFE3E2E9),
    surface = Color(0xFF121221),
    onSurface = Color(0xFFE3E2E9),
    surfaceVariant = Color(0xFF43474E),
    onSurfaceVariant = Color(0xFFC3C7CF),
    outline = Color(0xFF8D9199),
    error = Color(0xFFFFB4AB),
    onError = Color(0xFF690005),
)

// ---------------------------------------------------------------------------
// Composition local for the active park theme
// ---------------------------------------------------------------------------

/**
 * Provides the currently active [ParkTheme] to any composable in the tree.
 * ViewModels that know the active trip inject their theme into this local.
 * Defaults to null — screens handle the null case with a fallback color.
 */
val LocalParkTheme = staticCompositionLocalOf<ParkTheme?> { null }

// ---------------------------------------------------------------------------
// Theme composable
// ---------------------------------------------------------------------------

/**
 * Root theme wrapper for the entire app.
 *
 * [darkTheme] is driven by [UserPreferences.themeMode] in [MainActivity].
 * [parkTheme] can be provided by screens that know the active park, causing
 * park-specific gradient backgrounds and accent colors to be available via
 * [LocalParkTheme].
 */
@Composable
fun DisneyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    parkTheme: ParkTheme? = null,
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    CompositionLocalProvider(LocalParkTheme provides parkTheme) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = DisneyTypography,
            shapes = DisneyShapes,
            content = content,
        )
    }
}
