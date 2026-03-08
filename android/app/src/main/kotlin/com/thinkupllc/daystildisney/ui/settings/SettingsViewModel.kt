package com.thinkupllc.daystildisney.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.thinkupllc.daystildisney.core.data.local.datastore.PreferencesDataStore
import com.thinkupllc.daystildisney.core.model.ThemeMode
import com.thinkupllc.daystildisney.core.model.UserPreferences
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SettingsUiState(
    val preferences: UserPreferences = UserPreferences(),
    val appVersion: String = "",
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val preferencesDataStore: PreferencesDataStore,
) : ViewModel() {

    val uiState: StateFlow<SettingsUiState> = preferencesDataStore.userPreferences
        .map { prefs ->
            SettingsUiState(
                preferences = prefs,
                appVersion = getAppVersion(),
            )
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = SettingsUiState(),
        )

    fun onThemeModeSelected(mode: ThemeMode) {
        viewModelScope.launch {
            preferencesDataStore.setThemeMode(mode)
        }
    }

    private fun getAppVersion(): String {
        // In production, read from BuildConfig.VERSION_NAME
        return "1.0.0"
    }
}
