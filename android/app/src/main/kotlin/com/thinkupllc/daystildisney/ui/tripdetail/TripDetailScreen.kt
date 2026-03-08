package com.thinkupllc.daystildisney.ui.tripdetail

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarOutline
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.thinkupllc.daystildisney.R
import com.thinkupllc.daystildisney.core.util.CountdownComponents
import com.thinkupllc.daystildisney.core.util.formatDateRange
import com.thinkupllc.daystildisney.ui.components.CastleSilhouette
import com.thinkupllc.daystildisney.ui.components.GradientBackground
import com.thinkupllc.daystildisney.ui.home.components.CountdownHero
import com.thinkupllc.daystildisney.ui.home.components.DailyContentCard
import com.thinkupllc.daystildisney.ui.theme.LocalParkTheme
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

@Composable
fun TripDetailScreen(
    tripId: String,
    onNavigateBack: () -> Unit,
    onNavigateToEdit: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: TripDetailViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val deleteState by viewModel.deleteState.collectAsStateWithLifecycle()
    var showDeleteDialog by remember { mutableStateOf(false) }

    // Navigate back when trip is deleted
    LaunchedEffect(deleteState) {
        if (deleteState) onNavigateBack()
    }

    val parkTheme = (uiState as? TripDetailUiState.Success)?.parkTheme

    CompositionLocalProvider(LocalParkTheme provides parkTheme) {
        GradientBackground(parkTheme = parkTheme, modifier = modifier) {
            when (val state = uiState) {
                is TripDetailUiState.Loading -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = Color.White)
                    }
                }
                is TripDetailUiState.Success -> SuccessContent(
                    state = state,
                    onBack = onNavigateBack,
                    onEdit = onNavigateToEdit,
                    onSetPrimary = viewModel::onSetPrimary,
                    onDeleteRequest = { showDeleteDialog = true },
                )
                is TripDetailUiState.TripDeleted -> { /* LaunchedEffect handles navigation */ }
                is TripDetailUiState.Error -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text(state.message, color = Color.White)
                    }
                }
            }
        }

        if (showDeleteDialog) {
            val tripName = (uiState as? TripDetailUiState.Success)?.trip?.name ?: ""
            DeleteConfirmationDialog(
                tripName = tripName,
                onConfirm = {
                    showDeleteDialog = false
                    viewModel.onDeleteTrip()
                },
                onDismiss = { showDeleteDialog = false },
            )
        }
    }
}

@Composable
private fun SuccessContent(
    state: TripDetailUiState.Success,
    onBack: () -> Unit,
    onEdit: () -> Unit,
    onSetPrimary: () -> Unit,
    onDeleteRequest: () -> Unit,
) {
    val trip = state.trip
    val countdown = buildCountdown(state)

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding(),
        contentPadding = PaddingValues(bottom = 32.dp),
    ) {
        // Top action bar
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(onClick = onBack) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = Color.White,
                    )
                }
                Row {
                    // Star / set primary
                    IconButton(onClick = onSetPrimary) {
                        Icon(
                            imageVector = if (trip.isPrimary) Icons.Default.Star else Icons.Default.StarOutline,
                            contentDescription = stringResource(R.string.trip_detail_set_primary),
                            tint = if (trip.isPrimary) state.parkTheme.palette.accent else Color.White,
                        )
                    }
                    // Edit
                    IconButton(onClick = onEdit) {
                        Icon(
                            imageVector = Icons.Default.Edit,
                            contentDescription = stringResource(R.string.trip_detail_edit),
                            tint = Color.White,
                        )
                    }
                }
            }
        }

        // Castle
        item {
            CastleSilhouette(park = trip.primaryPark)
        }

        // Countdown hero
        item {
            CountdownHero(
                countdown = countdown,
                tripName = trip.name,
                modifier = Modifier.padding(vertical = 24.dp),
            )
        }

        // Trip info section
        item {
            TripInfoSection(
                state = state,
                onDeleteRequest = onDeleteRequest,
                modifier = Modifier.padding(horizontal = 16.dp),
            )
        }

        // Daily content
        state.dailyContent?.let { content ->
            item {
                Spacer(modifier = Modifier.height(16.dp))
                DailyContentCard(
                    content = content,
                    accentColor = state.parkTheme.palette.accent,
                    modifier = Modifier.padding(horizontal = 16.dp),
                )
            }
        }
    }
}

@Composable
private fun TripInfoSection(
    state: TripDetailUiState.Success,
    onDeleteRequest: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val trip = state.trip

    androidx.compose.material3.Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = androidx.compose.material3.CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.12f),
        ),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
        ) {
            InfoRow(label = stringResource(R.string.trip_detail_resort), value = trip.resort.displayName)
            Divider(color = Color.White.copy(alpha = 0.2f), modifier = Modifier.padding(vertical = 8.dp))
            InfoRow(
                label = stringResource(R.string.trip_detail_parks),
                value = trip.parks.joinToString(", ") { it.displayName },
            )
            Divider(color = Color.White.copy(alpha = 0.2f), modifier = Modifier.padding(vertical = 8.dp))
            InfoRow(
                label = stringResource(R.string.trip_detail_dates),
                value = formatDateRange(trip.startDate, trip.endDate),
            )
            Spacer(modifier = Modifier.height(16.dp))
            TextButton(
                onClick = onDeleteRequest,
                modifier = Modifier.align(Alignment.End),
            ) {
                Text(
                    text = stringResource(R.string.trip_detail_delete),
                    color = MaterialTheme.colorScheme.error,
                )
            }
        }
    }
}

@Composable
private fun InfoRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelLarge,
            color = Color.White.copy(alpha = 0.7f),
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = Color.White,
            textAlign = TextAlign.End,
            modifier = Modifier.weight(1f, fill = false).padding(start = 16.dp),
        )
    }
}

@Composable
private fun DeleteConfirmationDialog(
    tripName: String,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(stringResource(R.string.trip_detail_delete_confirm_title)) },
        text = { Text(stringResource(R.string.trip_detail_delete_confirm_body, tripName)) },
        confirmButton = {
            TextButton(onClick = onConfirm) {
                Text(
                    text = stringResource(R.string.trip_detail_delete_confirm),
                    color = MaterialTheme.colorScheme.error,
                )
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(R.string.add_trip_cancel))
            }
        },
    )
}

private fun buildCountdown(state: TripDetailUiState.Success): CountdownComponents {
    val startDateTime = state.trip.startDate.atStartOfDay()
    val now = LocalDateTime.now()
    val totalMinutes = ChronoUnit.MINUTES.between(now, startDateTime).coerceAtLeast(0)
    val days = totalMinutes / (60 * 24)
    val hours = (totalMinutes % (60 * 24)) / 60
    val minutes = totalMinutes % 60
    return CountdownComponents(days = days, hours = hours, minutes = minutes)
}
