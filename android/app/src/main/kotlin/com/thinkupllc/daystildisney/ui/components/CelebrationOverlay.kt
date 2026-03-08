package com.thinkupllc.daystildisney.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.thinkupllc.daystildisney.core.model.CelebrationType
import com.thinkupllc.daystildisney.core.model.Milestone

/**
 * Full-screen overlay shown when the countdown hits a [Milestone].
 * Displays the milestone message with a pulsing celebration animation.
 *
 * The animation layer is kept as a simple alpha pulse for MVP.
 * A proper particle system (confetti, fireworks) should be implemented
 * in v1.1 using a Canvas-based emitter or Lottie animation.
 *
 * @param milestone The milestone to celebrate.
 * @param visible Whether the overlay is currently shown.
 * @param onDismiss Called when the user taps anywhere to dismiss.
 */
@Composable
fun CelebrationOverlay(
    milestone: Milestone,
    visible: Boolean,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    AnimatedVisibility(
        visible = visible,
        enter = fadeIn(tween(600)),
        exit = fadeOut(tween(400)),
        modifier = modifier,
    ) {
        val dismissSource = remember { MutableInteractionSource() }

        Box(
            modifier = Modifier
                .fillMaxSize()
                .clickable(
                    interactionSource = dismissSource,
                    indication = null,
                    onClick = onDismiss,
                ),
            contentAlignment = Alignment.Center,
        ) {
            // Semi-transparent scrim
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .alpha(0.7f)
            )

            // Pulsing particle layer (MVP placeholder)
            PulsingParticleLayer(celebrationType = milestone.celebrationType)

            // Milestone message card
            Card(
                modifier = Modifier
                    .fillMaxWidth(0.85f)
                    .padding(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.White.copy(alpha = 0.95f),
                ),
                shape = MaterialTheme.shapes.extraLarge,
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Text(
                        text = celebrationEmoji(milestone.celebrationType),
                        style = MaterialTheme.typography.displaySmall,
                        textAlign = TextAlign.Center,
                    )
                    Spacer(modifier = Modifier.padding(8.dp))
                    Text(
                        text = milestone.title,
                        style = MaterialTheme.typography.headlineMedium,
                        textAlign = TextAlign.Center,
                        color = Color(0xFF1A3A6B),
                    )
                    Spacer(modifier = Modifier.padding(4.dp))
                    Text(
                        text = milestone.subtitle,
                        style = MaterialTheme.typography.bodyLarge,
                        textAlign = TextAlign.Center,
                        color = Color(0xFF555555),
                    )
                    Spacer(modifier = Modifier.padding(12.dp))
                    Text(
                        text = "Tap anywhere to continue",
                        style = MaterialTheme.typography.labelMedium,
                        color = Color(0xFF888888),
                    )
                }
            }
        }
    }
}

@Composable
private fun PulsingParticleLayer(celebrationType: CelebrationType) {
    val alpha = remember { Animatable(0.4f) }
    LaunchedEffect(Unit) {
        alpha.animateTo(
            targetValue = 0.9f,
            animationSpec = infiniteRepeatable(
                animation = tween(800, easing = LinearEasing),
                repeatMode = RepeatMode.Reverse,
            )
        )
    }
    // TODO: Replace with a real canvas particle system in v1.1
    Box(
        modifier = Modifier
            .fillMaxSize()
            .alpha(alpha.value),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = celebrationEmoji(celebrationType).repeat(3),
            style = MaterialTheme.typography.displayLarge,
            textAlign = TextAlign.Center,
        )
    }
}

private fun celebrationEmoji(type: CelebrationType): String = when (type) {
    CelebrationType.CONFETTI -> "\uD83C\uDF89"   // Party popper
    CelebrationType.FIREWORKS -> "\uD83C\uDF86"  // Fireworks
    CelebrationType.SPARKLE -> "\u2728"           // Sparkles
}
