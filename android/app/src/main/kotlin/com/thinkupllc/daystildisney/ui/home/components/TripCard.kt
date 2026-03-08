package com.thinkupllc.daystildisney.ui.home.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.thinkupllc.daystildisney.core.model.Trip
import com.thinkupllc.daystildisney.core.util.daysUntil
import com.thinkupllc.daystildisney.core.util.formatDateRange

/**
 * A compact card representing a single trip in the trip list on the Home screen.
 * Shows the park theme color strip, trip name, dates, and days-out count.
 *
 * @param trip The trip to display.
 * @param onClick Called when the user taps the card to open Trip Detail.
 */
@Composable
fun TripCard(
    trip: Trip,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val palette = trip.primaryPark.colorPalette
    val daysOut = trip.startDate.daysUntil()

    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Color strip on the left indicating the park theme
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .height(56.dp)
                    .clip(MaterialTheme.shapes.small)
                    .background(
                        Brush.verticalGradient(
                            listOf(palette.primary, palette.secondary)
                        )
                    )
            )

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = trip.name,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = trip.resort.displayName,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(
                    text = formatDateRange(trip.startDate, trip.endDate),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Days-out badge
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center,
            ) {
                when {
                    daysOut < 0 -> {
                        Text(
                            text = "Past",
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                    daysOut == 0L -> {
                        Text(
                            text = "TODAY",
                            style = MaterialTheme.typography.labelLarge,
                            color = palette.primary,
                        )
                    }
                    else -> {
                        Text(
                            text = daysOut.toString(),
                            style = MaterialTheme.typography.titleLarge,
                            color = palette.primary,
                        )
                        Text(
                            text = "days",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }
}
