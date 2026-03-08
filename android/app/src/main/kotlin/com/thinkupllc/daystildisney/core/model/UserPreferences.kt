package com.thinkupllc.daystildisney.core.model

/**
 * User-configurable preferences stored in DataStore.
 * Intentionally kept minimal for MVP — notification preferences are v1.1.
 */
data class UserPreferences(
    val themeMode: ThemeMode = ThemeMode.AUTO,
    val hasCompletedOnboarding: Boolean = false,
    /** UUID string of the primary trip, or null if none has been explicitly set. */
    val primaryTripId: String? = null,
)

enum class ThemeMode {
    /** Follows the system's light/dark setting. */
    AUTO,
    LIGHT,
    DARK,
}
