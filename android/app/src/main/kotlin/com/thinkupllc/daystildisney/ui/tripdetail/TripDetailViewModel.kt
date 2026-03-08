package com.thinkupllc.daystildisney.ui.tripdetail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.thinkupllc.daystildisney.core.data.repository.TripRepository
import com.thinkupllc.daystildisney.core.model.DailyContent
import com.thinkupllc.daystildisney.core.model.Trip
import com.thinkupllc.daystildisney.core.util.daysUntil
import com.thinkupllc.daystildisney.engine.content.ContentEngine
import com.thinkupllc.daystildisney.engine.theme.ParkTheme
import com.thinkupllc.daystildisney.engine.theme.ParkThemeProvider
import com.thinkupllc.daystildisney.ui.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface TripDetailUiState {
    data object Loading : TripDetailUiState
    data class Success(
        val trip: Trip,
        val parkTheme: ParkTheme,
        val daysUntilTrip: Long,
        val dailyContent: DailyContent?,
    ) : TripDetailUiState
    data object TripDeleted : TripDetailUiState
    data class Error(val message: String) : TripDetailUiState
}

@HiltViewModel
class TripDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val tripRepository: TripRepository,
    private val contentEngine: ContentEngine,
    private val parkThemeProvider: ParkThemeProvider,
) : ViewModel() {

    private val tripId: String = checkNotNull(savedStateHandle[Screen.TripDetail.ARG_TRIP_ID])

    private val _deleteState = MutableStateFlow(false)
    val deleteState: StateFlow<Boolean> = _deleteState.asStateFlow()

    val uiState: StateFlow<TripDetailUiState> = tripRepository
        .observeTripById(tripId)
        .map { trip ->
            if (trip == null) {
                TripDetailUiState.TripDeleted
            } else {
                buildSuccessState(trip)
            }
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = TripDetailUiState.Loading,
        )

    private suspend fun buildSuccessState(trip: Trip): TripDetailUiState {
        val theme = parkThemeProvider.getTheme(trip.primaryPark)
        val daysOut = trip.startDate.daysUntil()
        val content = runCatching { contentEngine.getDailyContent(trip) }.getOrNull()
        return TripDetailUiState.Success(
            trip = trip,
            parkTheme = theme,
            daysUntilTrip = daysOut,
            dailyContent = content,
        )
    }

    fun onSetPrimary() {
        viewModelScope.launch {
            runCatching { tripRepository.setPrimaryTrip(tripId) }
        }
    }

    fun onDeleteTrip() {
        viewModelScope.launch {
            runCatching { tripRepository.deleteTrip(tripId) }
            _deleteState.value = true
        }
    }
}
