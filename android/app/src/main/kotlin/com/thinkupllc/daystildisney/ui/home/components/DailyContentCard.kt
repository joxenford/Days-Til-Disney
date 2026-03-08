package com.thinkupllc.daystildisney.ui.home.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SuggestionChip
import androidx.compose.material3.SuggestionChipDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.thinkupllc.daystildisney.R
import com.thinkupllc.daystildisney.core.model.ContentType
import com.thinkupllc.daystildisney.core.model.DailyContent

/**
 * Displays today's daily Disney content as a card on the Home screen.
 * Shows the content type chip, title, and body text.
 *
 * @param content The [DailyContent] item to display.
 */
@Composable
fun DailyContentCard(
    content: DailyContent,
    modifier: Modifier = Modifier,
    accentColor: Color = MaterialTheme.colorScheme.primary,
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
        ) {
            // Header row: section label + content type chip
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = stringResource(R.string.home_daily_content_title),
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.weight(1f),
                )
                Spacer(modifier = Modifier.width(8.dp))
                SuggestionChip(
                    onClick = { /* no-op: informational only */ },
                    label = {
                        Text(
                            text = contentTypeLabel(content.type),
                            style = MaterialTheme.typography.labelSmall,
                        )
                    },
                    colors = SuggestionChipDefaults.suggestionChipColors(
                        containerColor = accentColor.copy(alpha = 0.15f),
                        labelColor = accentColor,
                    ),
                    border = null,
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = content.title,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurface,
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = content.body,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            content.source?.let { source ->
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "— $source",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
                )
            }
        }
    }
}

@Composable
private fun contentTypeLabel(type: ContentType): String = when (type) {
    ContentType.FUN_FACT -> stringResource(R.string.content_type_fun_fact)
    ContentType.PLANNING_TIP -> stringResource(R.string.content_type_planning_tip)
    ContentType.TRIVIA -> stringResource(R.string.content_type_trivia)
    ContentType.RIDE_SPOTLIGHT -> stringResource(R.string.content_type_ride_spotlight)
}
