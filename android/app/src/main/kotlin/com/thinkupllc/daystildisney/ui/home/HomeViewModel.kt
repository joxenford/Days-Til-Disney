package com.thinkupllc.daystildisney.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.thinkupllc.daystildisney.core.data.repository.TripRepository
import com.thinkupllc.daystildisney.core.model.DailyContent
import com.thinkupllc.daystildisney.core.model.Milestone
import com.thinkupllc.daystildisney.core.model.Trip
import com.thinkupllc.daystildisney.core.util.daysUntil
import com.thinkupllc.daystildisney.engine.content.ContentEngine
import com.thinkupllc.daystildisney.engine.milestone.MilestoneManager
import com.thinkupllc.daystildisney.engine.theme.ParkTheme
import com.thinkupllc.daystildisney.engine.theme.ParkThemeProvider
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

// ---------------------------------------------------------------------------
// UI State
// ---------------------------------------------------------------------------

sealed interface HomeUiState {
    data object Loading : HomeUiState
    data object NoTrips : HomeUiState
    data class Success(
        val primaryTrip: Trip,
        val primaryParkTheme: ParkTheme,
        val daysUntilTrip: Long,
        val dailyContent: DailyContent?,
        val activeMilestone: Milestone?,
        val allTrips: List<Trip>,
    ) : HomeUiState
    data class Error(val message: String) : HomeUiState
}

data class HomeEventState(
    val showMilestoneCelebration: Boolean = false,
    val celebrationMilestone: Milestone? = null,
)

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val tripRepository: TripRepository,
    private val contentEngine: ContentEngine,
    private val milestoneManager: MilestoneManager,
    private val parkThemeProvider: ParkThemeProvider,
) : ViewModel() {

    private val _eventState = MutableStateFlow(HomeEventState())
    val eventState: StateFlow<HomeEventState> = _eventState.asStateFlow()

    val uiState: StateFlow<HomeUiState> = combine(
        tripRepository.observeAllTrips(),
        tripRepository.observePrimaryTrip(),
    ) { allTrips, primaryTrip ->
        buildUiState(allTrips, primaryTrip)
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = HomeUiState.Loading,
    )

    private suspend fun buildUiState(
        allTrips: List<Trip>,
        primaryTrip: Trip?,
    ): HomeUiState {
        if (allTrips.isEmpty()) return HomeUiState.NoTrips

        val trip = primaryTrip ?: allTrips.first()
        val daysOut = trip.startDate.daysUntil()
        val theme = parkThemeProvider.getTheme(trip.primaryPark)

        val content = runCatching { contentEngine.getDailyContent(trip) }.getOrNull()
        val milestone = milestoneManager.getCurrentMilestone(trip)

        // Check if milestone should trigger a celebration
        if (milestone != null) {
            val alreadyAcknowledged = milestoneManager.isMilestoneAcknowledged(
                tripId = trip.id,
                daysOut = milestone.daysOut,
            )
            if (!alreadyAcknowledged) {
                _eventState.update {
                    it.copy(
                        showMilestoneCelebration = true,
                        celebrationMilestone = milestone,
                    )
                }
            }
        }

        return HomeUiState.Success(
            primaryTrip = trip,
            primaryParkTheme = theme,
            daysUntilTrip = daysOut,
            dailyContent = content,
            activeMilestone = milestone,
            allTrips = allTrips,
        )
    }

    fun onMilestoneCelebrationDismissed() {
        val milestone = _eventState.value.celebrationMilestone ?: return
        val tripId = (uiState.value as? HomeUiState.Success)?.primaryTrip?.id ?: return

        viewModelScope.launch {
            milestoneManager.acknowledgeMilestone(tripId, milestone.daysOut)
            _eventState.update {
                it.copy(
                    showMilestoneCelebration = false,
                    celebrationMilestone = null,
                )
            }
        }
    }

    fun onSetPrimaryTrip(tripId: String) {
        viewModelScope.launch {
            runCatching { tripRepository.setPrimaryTrip(tripId) }
        }
    }
}
