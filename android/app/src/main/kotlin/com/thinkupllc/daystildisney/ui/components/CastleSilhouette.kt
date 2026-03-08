package com.thinkupllc.daystildisney.ui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.thinkupllc.daystildisney.core.model.DisneyPark
import com.thinkupllc.daystildisney.ui.theme.LocalParkTheme

/**
 * Displays a castle/icon silhouette for the given [park].
 *
 * In the MVP, the silhouette is rendered using a park-specific Unicode or
 * emoji character as a placeholder. The real implementation replaces this
 * with an SVG/VectorDrawable loaded from assets once the art assets are
 * delivered. The composable API stays identical.
 *
 * @param park The park whose icon to display.
 * @param height The height of the silhouette container.
 * @param alpha Opacity of the silhouette (0.0 = transparent, 1.0 = opaque).
 */
@Composable
fun CastleSilhouette(
    park: DisneyPark,
    modifier: Modifier = Modifier,
    height: Dp = 160.dp,
    alpha: Float = 0.85f,
    tintColor: Color = LocalParkTheme.current?.palette?.silhouetteColor ?: Color.White,
) {
    // Placeholder: park emoji character until SVG assets arrive.
    // TODO: Replace with Image(painter = painterResource(id = park.drawableResId))
    val placeholderEmoji = parkPlaceholderEmoji(park)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .alpha(alpha),
        contentAlignment = Alignment.BottomCenter,
    ) {
        Text(
            text = placeholderEmoji,
            fontSize = 80.sp,
            fontWeight = FontWeight.Normal,
            textAlign = TextAlign.Center,
            color = tintColor,
        )
    }
}

private fun parkPlaceholderEmoji(park: DisneyPark): String = when (park) {
    DisneyPark.MAGIC_KINGDOM -> "\uD83C\uDFF0"            // Castle
    DisneyPark.EPCOT -> "\uD83C\uDF0D"                    // Globe
    DisneyPark.HOLLYWOOD_STUDIOS -> "\uD83C\uDFAC"        // Clapper board
    DisneyPark.ANIMAL_KINGDOM -> "\uD83C\uDF33"           // Tree
    DisneyPark.DISNEYLAND -> "\uD83C\uDFF0"               // Castle
    DisneyPark.CALIFORNIA_ADVENTURE -> "\uD83C\uDF0A"     // Wave
    DisneyPark.TOKYO_DISNEYLAND -> "\uD83C\uDF38"         // Cherry blossom
    DisneyPark.TOKYO_DISNEYSEA -> "\uD83D\uDEA2"          // Ship
    DisneyPark.DISNEYLAND_PARK_PARIS -> "\uD83C\uDFF0"    // Castle
    DisneyPark.WALT_DISNEY_STUDIOS_PARK -> "\uD83C\uDFAC" // Clapper board
    DisneyPark.HONG_KONG_DISNEYLAND_PARK -> "\uD83C\uDFF0" // Castle
    DisneyPark.SHANGHAI_DISNEYLAND_PARK -> "\uD83C\uDFF0"  // Castle
}
