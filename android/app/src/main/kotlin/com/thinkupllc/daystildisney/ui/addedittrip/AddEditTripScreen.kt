package com.thinkupllc.daystildisney.ui.addedittrip

import android.app.DatePickerDialog
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.thinkupllc.daystildisney.R
import com.thinkupllc.daystildisney.core.model.DisneyResort
import com.thinkupllc.daystildisney.ui.addedittrip.components.ParkSelectorSheet
import com.thinkupllc.daystildisney.core.util.formatDateRange
import java.time.LocalDate
import java.util.Calendar

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun AddEditTripScreen(
    tripId: String?,
    onNavigateBack: () -> Unit,
    onTripSaved: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AddEditTripViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showParkSelector by remember { mutableStateOf(false) }

    // Navigate on successful save
    LaunchedEffect(uiState.isSaved) {
        if (uiState.isSaved) onTripSaved()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = if (uiState.isEditMode)
                            stringResource(R.string.edit_trip_title)
                        else
                            stringResource(R.string.add_trip_title)
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                ),
            )
        },
        modifier = modifier,
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 16.dp)
                .verticalScroll(rememberScrollState())
                .imePadding(),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Spacer(modifier = Modifier.height(8.dp))

            // ---- Trip name ----
            OutlinedTextField(
                value = uiState.name,
                onValueChange = viewModel::onNameChanged,
                label = { Text(stringResource(R.string.add_trip_name_label)) },
                placeholder = { Text(stringResource(R.string.add_trip_name_placeholder)) },
                isError = uiState.nameError != null,
                supportingText = uiState.nameError?.let { { Text(it) } },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )

            // ---- Resort selector ----
            ResortDropdown(
                selectedResort = uiState.selectedResort,
                onResortSelected = viewModel::onResortSelected,
                isError = uiState.resortError != null,
                errorText = uiState.resortError,
            )

            // ---- Parks selector ----
            if (uiState.selectedResort != null) {
                Column {
                    Text(
                        text = stringResource(R.string.add_trip_parks_label),
                        style = MaterialTheme.typography.labelLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        uiState.selectedResort!!.parks.forEach { park ->
                            val isSelected = park in uiState.selectedParks
                            FilterChip(
                                selected = isSelected,
                                onClick = { viewModel.onParkToggled(park) },
                                label = { Text(park.displayName) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = park.colorPalette.primary.copy(alpha = 0.15f),
                                    selectedLabelColor = park.colorPalette.primary,
                                ),
                            )
                        }
                    }
                }
            }

            // ---- Dates ----
            DatePickerRow(
                startDate = uiState.startDate,
                endDate = uiState.endDate,
                onStartDateSelected = viewModel::onStartDateSelected,
                onEndDateSelected = viewModel::onEndDateSelected,
                errorText = uiState.dateError,
            )

            // ---- Set as primary toggle ----
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = stringResource(R.string.add_trip_primary_label),
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.weight(1f).padding(end = 16.dp),
                )
                Switch(
                    checked = uiState.isPrimary,
                    onCheckedChange = viewModel::onIsPrimaryChanged,
                )
            }

            // ---- Save error ----
            uiState.saveError?.let { error ->
                Text(
                    text = error,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodySmall,
                )
            }

            // ---- Save button ----
            Button(
                onClick = viewModel::onSave,
                modifier = Modifier.fillMaxWidth(),
                enabled = !uiState.isSaving,
            ) {
                if (uiState.isSaving) {
                    CircularProgressIndicator(
                        color = Color.White,
                        strokeWidth = 2.dp,
                        modifier = Modifier.height(20.dp),
                    )
                } else {
                    Text(stringResource(R.string.add_trip_save))
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ResortDropdown(
    selectedResort: DisneyResort?,
    onResortSelected: (DisneyResort) -> Unit,
    isError: Boolean,
    errorText: String?,
) {
    var expanded by remember { mutableStateOf(false) }

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it },
    ) {
        OutlinedTextField(
            value = selectedResort?.displayName ?: "",
            onValueChange = {},
            readOnly = true,
            label = { Text(stringResource(R.string.add_trip_resort_label)) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            isError = isError,
            supportingText = errorText?.let { { Text(it) } },
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(),
        )
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
        ) {
            DisneyResort.entries.forEach { resort ->
                DropdownMenuItem(
                    text = {
                        Column {
                            Text(resort.displayName, style = MaterialTheme.typography.bodyLarge)
                            Text(resort.location, style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    },
                    onClick = {
                        onResortSelected(resort)
                        expanded = false
                    },
                )
            }
        }
    }
}

@Composable
private fun DatePickerRow(
    startDate: LocalDate?,
    endDate: LocalDate?,
    onStartDateSelected: (LocalDate) -> Unit,
    onEndDateSelected: (LocalDate) -> Unit,
    errorText: String?,
) {
    val context = LocalContext.current

    fun showDatePicker(initial: LocalDate?, onSelected: (LocalDate) -> Unit) {
        val cal = Calendar.getInstance()
        initial?.let {
            cal.set(it.year, it.monthValue - 1, it.dayOfMonth)
        }
        DatePickerDialog(
            context,
            { _, year, month, day ->
                onSelected(LocalDate.of(year, month + 1, day))
            },
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH),
            cal.get(Calendar.DAY_OF_MONTH),
        ).apply {
            datePicker.minDate = System.currentTimeMillis() - 1000
        }.show()
    }

    Column {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            OutlinedTextField(
                value = startDate?.toString() ?: "",
                onValueChange = {},
                readOnly = true,
                label = { Text(stringResource(R.string.add_trip_start_date_label)) },
                trailingIcon = {
                    IconButton(onClick = { showDatePicker(startDate, onStartDateSelected) }) {
                        Icon(Icons.Default.CalendarToday, contentDescription = null)
                    }
                },
                modifier = Modifier
                    .weight(1f),
            )
            OutlinedTextField(
                value = endDate?.toString() ?: "",
                onValueChange = {},
                readOnly = true,
                label = { Text(stringResource(R.string.add_trip_end_date_label)) },
                trailingIcon = {
                    IconButton(onClick = { showDatePicker(endDate, onEndDateSelected) }) {
                        Icon(Icons.Default.CalendarToday, contentDescription = null)
                    }
                },
                modifier = Modifier.weight(1f),
            )
        }
        errorText?.let {
            Text(
                text = it,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(start = 16.dp, top = 4.dp),
            )
        }
    }
}
