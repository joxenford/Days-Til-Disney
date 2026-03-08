package com.thinkupllc.daystildisney.ui.splash

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.thinkupllc.daystildisney.R
import com.thinkupllc.daystildisney.ui.components.GradientBackground
import kotlinx.coroutines.delay

/**
 * Animated launch screen.
 *
 * The system splash screen (from [Theme.DaysTilDisney.Splash]) handles the
 * very first frame while Compose initializes. This Composable takes over
 * immediately after, running a short castle + title fade-in before calling
 * [onSplashComplete] to navigate to [HomeScreen].
 */
@Composable
fun SplashScreen(
    onSplashComplete: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val castleAlpha = remember { Animatable(0f) }
    val castleScale = remember { Animatable(0.7f) }
    val titleAlpha = remember { Animatable(0f) }

    LaunchedEffect(Unit) {
        // Castle scales up and fades in
        castleAlpha.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = 700, easing = EaseOutCubic),
        )
        castleScale.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = 700, easing = EaseOutCubic),
        )
        // Title fades in shortly after the castle
        delay(200)
        titleAlpha.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = 500),
        )
        // Hold for a beat, then hand off to Home
        delay(800)
        onSplashComplete()
    }

    GradientBackground(modifier = modifier) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center,
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                // Castle silhouette placeholder
                Text(
                    text = "\uD83C\uDFF0",   // Castle emoji — replace with SVG asset
                    style = MaterialTheme.typography.displayLarge,
                    modifier = Modifier
                        .alpha(castleAlpha.value)
                        .scale(castleScale.value),
                )

                Spacer(modifier = Modifier.height(24.dp))

                Text(
                    text = stringResource(R.string.app_name),
                    style = MaterialTheme.typography.headlineLarge,
                    color = Color.White,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.alpha(titleAlpha.value),
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "The magic starts here",
                    style = MaterialTheme.typography.bodyLarge,
                    color = Color.White.copy(alpha = 0.7f),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.alpha(titleAlpha.value),
                )
            }
        }
    }
}
