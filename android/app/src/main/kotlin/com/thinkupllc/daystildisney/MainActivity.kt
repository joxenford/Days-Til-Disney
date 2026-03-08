package com.thinkupllc.daystildisney

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.thinkupllc.daystildisney.core.data.local.datastore.PreferencesDataStore
import com.thinkupllc.daystildisney.core.model.ThemeMode
import com.thinkupllc.daystildisney.core.model.UserPreferences
import com.thinkupllc.daystildisney.ui.navigation.AppNavHost
import com.thinkupllc.daystildisney.ui.theme.DisneyTheme
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

/**
 * The single Activity for the entire app.
 * Sets up the splash screen, edge-to-edge display, and the Compose content tree.
 * All navigation is handled within [AppNavHost].
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var preferencesDataStore: PreferencesDataStore

    override fun onCreate(savedInstanceState: Bundle?) {
        // Install the splash screen before super.onCreate so it shows immediately
        installSplashScreen()

        super.onCreate(savedInstanceState)

        // Render content edge-to-edge (system bars are transparent, we draw behind them)
        enableEdgeToEdge()

        setContent {
            val prefs by preferencesDataStore.userPreferences.collectAsState(
                initial = UserPreferences()
            )

            val darkTheme = when (prefs.themeMode) {
                ThemeMode.LIGHT -> false
                ThemeMode.DARK -> true
                ThemeMode.AUTO -> isSystemInDarkTheme()
            }

            DisneyTheme(darkTheme = darkTheme) {
                AppNavHost()
            }
        }
    }
}
