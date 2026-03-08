package com.thinkupllc.daystildisney.ui.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
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
import com.thinkupllc.daystildisney.core.util.daysUntil
import com.thinkupllc.daystildisney.ui.components.CelebrationOverlay
import com.thinkupllc.daystildisney.ui.components.CastleSilhouette
import com.thinkupllc.daystildisney.ui.components.GradientBackground
import com.thinkupllc.daystildisney.ui.home.components.CountdownHero
import com.thinkupllc.daystildisney.ui.home.components.DailyContentCard
import com.thinkupllc.daystildisney.ui.home.components.TripCard
import com.thinkupllc.daystildisney.ui.theme.LocalParkTheme
import java.time.LocalDateTime

@Composable
fun HomeScreen(
    onNavigateToTripDetail: (String) -> Unit,
    onNavigateToAddTrip: () -> Unit,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: HomeViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val eventState by viewModel.eventState.collectAsStateWithLifecycle()

    val parkTheme = (uiState as? HomeUiState.Success)?.primaryParkTheme

    CompositionLocalProvider(LocalParkTheme provides parkTheme) {
        Scaffold(
            containerColor = Color.Transparent,
            floatingActionButton = {
                FloatingActionButton(
                    onClick = onNavigateToAddTrip,
                    containerColor = parkTheme?.palette?.accent
                        ?: MaterialTheme.colorScheme.primary,
                ) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = stringResource(R.string.home_add_trip),
                        tint = Color.White,
                    )
                }
            },
        ) { innerPadding ->
            GradientBackground(parkTheme = parkTheme) {
                when (val state = uiState) {
                    is HomeUiState.Loading -> LoadingContent()

                    is HomeUiState.NoTrips -> EmptyContent(
                        onAddTrip = onNavigateToAddTrip,
                        onSettings = onNavigateToSettings,
                        modifier = Modifier.padding(innerPadding),
                    )

                    is HomeUiState.Success -> SuccessContent(
                        state = state,
                        onNavigateToTripDetail = onNavigateToTripDetail,
                        onSettings = onNavigateToSettings,
                        modifier = Modifier.padding(innerPadding),
                    )

                    is HomeUiState.Error -> ErrorContent(message = state.message)
                }
            }

            // Milestone celebration overlay — drawn above everything
            eventState.celebrationMilestone?.let { milestone ->
                CelebrationOverlay(
                    milestone = milestone,
                    visible = eventState.showMilestoneCelebration,
                    onDismiss = viewModel::onMilestoneCelebrationDismissed,
                )
            }
        }
    }
}

@Composable
private fun SuccessContent(
    state: HomeUiState.Success,
    onNavigateToTripDetail: (String) -> Unit,
    onSettings: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val countdown = buildCountdown(state)

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding(),
        contentPadding = PaddingValues(bottom = 88.dp), // FAB clearance
    ) {
        // Settings button in top-right
        item {
            Box(modifier = Modifier.fillMaxWidth()) {
                IconButton(
                    onClick = onSettings,
                    modifier = Modifier.align(Alignment.TopEnd).padding(8.dp),
                ) {
                    Icon(
                        imageVector = Icons.Default.Settings,
                        contentDescription = stringResource(R.string.settings_title),
                        tint = Color.White.copy(alpha = 0.8f),
                    )
                }
            }
        }

        // Castle silhouette
        item {
            CastleSilhouette(
                park = state.primaryTrip.primaryPark,
                modifier = Modifier.padding(top = 8.dp),
            )
        }

        // Countdown hero
        item {
            CountdownHero(
                countdown = countdown,
                tripName = state.primaryTrip.name,
                modifier = Modifier.padding(vertical = 24.dp),
            )
        }

        // Daily content card
        state.dailyContent?.let { content ->
            item {
                DailyContentCard(
                    content = content,
                    accentColor = state.primaryParkTheme.palette.accent,
                    modifier = Modifier.padding(horizontal = 16.dp),
                )
                Spacer(modifier = Modifier.height(16.dp))
            }
        }

        // Secondary trips section header
        if (state.allTrips.size > 1) {
            item {
                Text(
                    text = "Other Trips",
                    style = MaterialTheme.typography.titleSmall,
                    color = Color.White.copy(alpha = 0.7f),
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                )
            }

            items(
                items = state.allTrips.filter { it.id != state.primaryTrip.id },
                key = { it.id },
            ) { trip ->
                TripCard(
                    trip = trip,
                    onClick = { onNavigateToTripDetail(trip.id) },
                    modifier = Modifier
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 8.dp),
                )
            }
        }
    }
}

private fun buildCountdown(state: HomeUiState.Success): CountdownComponents {
    val trip = state.primaryTrip
    val startDateTime = trip.startDate.atStartOfDay()
    return startDateTime.countdownComponents()
}

// Use local extension here to avoid ambiguous imports
private fun java.time.LocalDateTime.countdownComponents(): CountdownComponents {
    val now = LocalDateTime.now()
    val totalMinutes = java.time.temporal.ChronoUnit.MINUTES.between(now, this).coerceAtLeast(0)
    val days = totalMinutes / (60 * 24)
    val hours = (totalMinutes % (60 * 24)) / 60
    val minutes = totalMinutes % 60
    return CountdownComponents(days = days, hours = hours, minutes = minutes)
}

@Composable
private fun EmptyContent(
    onAddTrip: () -> Unit,
    onSettings: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(modifier = modifier.fillMaxSize()) {
        IconButton(
            onClick = onSettings,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .statusBarsPadding()
                .padding(8.dp),
        ) {
            Icon(
                imageVector = Icons.Default.Settings,
                contentDescription = stringResource(R.string.settings_title),
                tint = Color.White.copy(alpha = 0.8f),
            )
        }

        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = "\uD83C\uDFF0",
                style = MaterialTheme.typography.displayMedium,
            )
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = stringResource(R.string.home_no_trips_title),
                style = MaterialTheme.typography.headlineSmall,
                color = Color.White,
                textAlign = TextAlign.Center,
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = stringResource(R.string.home_no_trips_subtitle),
                style = MaterialTheme.typography.bodyLarge,
                color = Color.White.copy(alpha = 0.7f),
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun LoadingContent() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(color = Color.White)
    }
}

@Composable
private fun ErrorContent(message: String) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(
            text = message,
            style = MaterialTheme.typography.bodyLarge,
            color = Color.White,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(24.dp),
        )
    }
}
