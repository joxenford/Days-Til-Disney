package com.thinkupllc.daystildisney.ui.addedittrip

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.thinkupllc.daystildisney.core.data.repository.TripRepository
import com.thinkupllc.daystildisney.core.model.DisneyPark
import com.thinkupllc.daystildisney.core.model.DisneyResort
import com.thinkupllc.daystildisney.core.model.Trip
import com.thinkupllc.daystildisney.ui.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDate
import java.util.UUID
import javax.inject.Inject

// ---------------------------------------------------------------------------
// UI State
// ---------------------------------------------------------------------------

data class AddEditTripUiState(
    val isLoading: Boolean = true,
    val tripId: String? = null,         // null = new trip
    val name: String = "",
    val selectedResort: DisneyResort? = null,
    val selectedParks: List<DisneyPark> = emptyList(),
    val startDate: LocalDate? = null,
    val endDate: LocalDate? = null,
    val isPrimary: Boolean = false,
    val isSaving: Boolean = false,
    val isSaved: Boolean = false,
    val nameError: String? = null,
    val resortError: String? = null,
    val dateError: String? = null,
    val saveError: String? = null,
) {
    val isEditMode: Boolean get() = tripId != null
    val isFormValid: Boolean
        get() = name.isNotBlank() &&
                selectedResort != null &&
                selectedParks.isNotEmpty() &&
                startDate != null &&
                endDate != null &&
                !endDate.isBefore(startDate)
}

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

@HiltViewModel
class AddEditTripViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val tripRepository: TripRepository,
) : ViewModel() {

    private val existingTripId: String? = savedStateHandle[Screen.AddEditTrip.ARG_TRIP_ID]

    private val _uiState = MutableStateFlow(AddEditTripUiState())
    val uiState: StateFlow<AddEditTripUiState> = _uiState.asStateFlow()

    init {
        if (existingTripId != null) {
            loadExistingTrip(existingTripId)
        } else {
            _uiState.update { it.copy(isLoading = false) }
        }
    }

    private fun loadExistingTrip(id: String) {
        viewModelScope.launch {
            val trip = tripRepository.getTripById(id)
            if (trip != null) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        tripId = trip.id,
                        name = trip.name,
                        selectedResort = trip.resort,
                        selectedParks = trip.parks,
                        startDate = trip.startDate,
                        endDate = trip.endDate,
                        isPrimary = trip.isPrimary,
                    )
                }
            } else {
                _uiState.update { it.copy(isLoading = false, saveError = "Trip not found.") }
            }
        }
    }

    fun onNameChanged(name: String) {
        _uiState.update {
            it.copy(name = name, nameError = if (name.isBlank()) "Name is required" else null)
        }
    }

    fun onResortSelected(resort: DisneyResort) {
        _uiState.update {
            it.copy(
                selectedResort = resort,
                selectedParks = emptyList(), // Clear parks when resort changes
                resortError = null,
            )
        }
    }

    fun onParkToggled(park: DisneyPark) {
        _uiState.update { state ->
            val current = state.selectedParks.toMutableList()
            if (park in current) current.remove(park) else current.add(park)
            state.copy(selectedParks = current)
        }
    }

    fun onStartDateSelected(date: LocalDate) {
        _uiState.update { state ->
            val endDate = state.endDate
            state.copy(
                startDate = date,
                endDate = if (endDate != null && endDate.isBefore(date)) null else endDate,
                dateError = null,
            )
        }
    }

    fun onEndDateSelected(date: LocalDate) {
        _uiState.update { state ->
            val startDate = state.startDate
            state.copy(
                endDate = date,
                dateError = if (startDate != null && date.isBefore(startDate))
                    "End date must be on or after start date" else null,
            )
        }
    }

    fun onIsPrimaryChanged(isPrimary: Boolean) {
        _uiState.update { it.copy(isPrimary = isPrimary) }
    }

    fun onSave() {
        val state = _uiState.value
        if (!state.isFormValid) {
            _uiState.update {
                it.copy(
                    nameError = if (it.name.isBlank()) "Name is required" else null,
                    resortError = if (it.selectedResort == null) "Select a destination" else null,
                    dateError = if (it.startDate == null || it.endDate == null) "Select dates" else null,
                )
            }
            return
        }

        _uiState.update { it.copy(isSaving = true) }

        viewModelScope.launch {
            val now = Instant.now()
            val trip = Trip(
                id = state.tripId ?: UUID.randomUUID().toString(),
                name = state.name.trim(),
                resort = state.selectedResort!!,
                parks = state.selectedParks,
                startDate = state.startDate!!,
                endDate = state.endDate!!,
                isPrimary = state.isPrimary,
                createdAt = now,
                updatedAt = now,
            )

            runCatching {
                tripRepository.saveTrip(trip)
                if (trip.isPrimary) {
                    tripRepository.setPrimaryTrip(trip.id)
                }
            }.onSuccess {
                _uiState.update { it.copy(isSaving = false, isSaved = true) }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(isSaving = false, saveError = error.message ?: "Save failed")
                }
            }
        }
    }
}
