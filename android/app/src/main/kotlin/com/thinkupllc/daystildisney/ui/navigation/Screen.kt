package com.thinkupllc.daystildisney.ui.navigation

/**
 * Sealed class representing all navigable screens/routes in the app.
 * Each object/class holds its route string and any typed argument accessors.
 *
 * Using a sealed class (rather than raw strings) gives compile-time safety
 * and a single source of truth for all route definitions.
 */
sealed class Screen(val route: String) {

    /** Animated splash / launch screen. */
    data object Splash : Screen("splash")

    /** Home screen — primary countdown hero + trip list + daily content. */
    data object Home : Screen("home")

    /**
     * Trip detail screen — full themed countdown + trip info.
     * @param tripId The UUID string of the trip to display.
     */
    data class TripDetail(val tripId: String = "{tripId}") :
        Screen("trip_detail/{tripId}") {
        fun createRoute(tripId: String) = "trip_detail/$tripId"

        companion object {
            const val ROUTE = "trip_detail/{tripId}"
            const val ARG_TRIP_ID = "tripId"
        }
    }

    /**
     * Add or edit a trip.
     * When [tripId] is null, the screen creates a new trip.
     * When [tripId] is provided, the screen edits the existing trip.
     */
    data class AddEditTrip(val tripId: String? = null) :
        Screen("add_edit_trip?tripId={tripId}") {
        fun createRoute(tripId: String? = null): String =
            if (tripId != null) "add_edit_trip?tripId=$tripId"
            else "add_edit_trip"

        companion object {
            const val ROUTE = "add_edit_trip?tripId={tripId}"
            const val ARG_TRIP_ID = "tripId"
        }
    }

    /** Settings screen. */
    data object Settings : Screen("settings")
}
