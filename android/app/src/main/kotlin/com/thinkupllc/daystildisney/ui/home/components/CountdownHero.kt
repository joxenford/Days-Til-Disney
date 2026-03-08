package com.thinkupllc.daystildisney.ui.home.components

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.thinkupllc.daystildisney.R
import com.thinkupllc.daystildisney.core.util.CountdownComponents

/**
 * The large countdown number display — the hero of the Home screen.
 *
 * Shows "N days" for countdowns > 1 day.
 * Shows hours and minutes when the trip is today (< 1 day remaining).
 * Shows "TODAY!" when countdown is zero.
 *
 * The number animates with a vertical slide when it changes (e.g., at midnight).
 */
@Composable
fun CountdownHero(
    countdown: CountdownComponents,
    tripName: String,
    modifier: Modifier = Modifier,
    textColor: Color = Color.White,
) {
    val accessibilityDescription = when {
        countdown.isToday -> stringResource(R.string.countdown_accessibility_today)
        else -> stringResource(R.string.countdown_accessibility_days, countdown.days)
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp)
            .semantics { contentDescription = accessibilityDescription },
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // Trip name label above the number
        Text(
            text = tripName,
            style = MaterialTheme.typography.titleMedium,
            color = textColor.copy(alpha = 0.8f),
            textAlign = TextAlign.Center,
            maxLines = 2,
        )

        Spacer(modifier = Modifier.height(8.dp))

        when {
            countdown.isToday -> {
                Text(
                    text = stringResource(R.string.countdown_today),
                    style = MaterialTheme.typography.displayMedium,
                    color = textColor,
                    textAlign = TextAlign.Center,
                )
            }

            countdown.isFinalDay -> {
                // Final day: show hours and minutes
                FinalDayCountdown(
                    hours = countdown.hours,
                    minutes = countdown.minutes,
                    textColor = textColor,
                )
            }

            else -> {
                // Normal countdown: animate the day number
                AnimatedContent(
                    targetState = countdown.days,
                    transitionSpec = {
                        slideInVertically { it } togetherWith slideOutVertically { -it }
                    },
                    label = "countdown_days_animation",
                ) { days ->
                    Text(
                        text = days.toString(),
                        style = MaterialTheme.typography.displayLarge,
                        color = textColor,
                        textAlign = TextAlign.Center,
                    )
                }

                Text(
                    text = stringResource(R.string.countdown_days),
                    style = MaterialTheme.typography.titleLarge,
                    color = textColor.copy(alpha = 0.85f),
                    textAlign = TextAlign.Center,
                )

                Text(
                    text = stringResource(R.string.home_days_until),
                    style = MaterialTheme.typography.bodyLarge,
                    color = textColor.copy(alpha = 0.7f),
                    textAlign = TextAlign.Center,
                )
            }
        }
    }
}

@Composable
private fun FinalDayCountdown(
    hours: Long,
    minutes: Long,
    textColor: Color,
) {
    Row(
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.Bottom,
    ) {
        CountdownUnit(value = hours, label = stringResource(R.string.countdown_hours), textColor = textColor)
        Text(
            text = "  :  ",
            style = MaterialTheme.typography.displayMedium,
            color = textColor,
        )
        CountdownUnit(value = minutes, label = stringResource(R.string.countdown_minutes), textColor = textColor)
    }
}

@Composable
private fun CountdownUnit(
    value: Long,
    label: String,
    textColor: Color,
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value.toString().padStart(2, '0'),
            style = MaterialTheme.typography.displayMedium,
            color = textColor,
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = textColor.copy(alpha = 0.7f),
        )
    }
}
