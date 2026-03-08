package com.thinkupllc.daystildisney.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.thinkupllc.daystildisney.ui.addedittrip.AddEditTripScreen
import com.thinkupllc.daystildisney.ui.home.HomeScreen
import com.thinkupllc.daystildisney.ui.settings.SettingsScreen
import com.thinkupllc.daystildisney.ui.splash.SplashScreen
import com.thinkupllc.daystildisney.ui.tripdetail.TripDetailScreen

/**
 * The root navigation host. Defines all navigable destinations and
 * their argument types.
 *
 * The start destination is [Screen.Splash], which immediately transitions
 * to [Screen.Home] once its animation completes.
 */
@Composable
fun AppNavHost(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController(),
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Splash.route,
        modifier = modifier,
    ) {
        composable(route = Screen.Splash.route) {
            SplashScreen(
                onSplashComplete = {
                    navController.navigate(Screen.Home.route) {
                        // Remove splash from back stack so Back doesn't return to it
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                }
            )
        }

        composable(route = Screen.Home.route) {
            HomeScreen(
                onNavigateToTripDetail = { tripId ->
                    navController.navigate(Screen.TripDetail().createRoute(tripId))
                },
                onNavigateToAddTrip = {
                    navController.navigate(Screen.AddEditTrip().createRoute())
                },
                onNavigateToSettings = {
                    navController.navigate(Screen.Settings.route)
                },
            )
        }

        composable(
            route = Screen.TripDetail.ROUTE,
            arguments = listOf(
                navArgument(Screen.TripDetail.ARG_TRIP_ID) { type = NavType.StringType }
            ),
        ) { backStackEntry ->
            val tripId = backStackEntry.arguments?.getString(Screen.TripDetail.ARG_TRIP_ID) ?: return@composable
            TripDetailScreen(
                tripId = tripId,
                onNavigateBack = { navController.popBackStack() },
                onNavigateToEdit = {
                    navController.navigate(Screen.AddEditTrip().createRoute(tripId))
                },
            )
        }

        composable(
            route = Screen.AddEditTrip.ROUTE,
            arguments = listOf(
                navArgument(Screen.AddEditTrip.ARG_TRIP_ID) {
                    type = NavType.StringType
                    nullable = true
                    defaultValue = null
                }
            ),
        ) { backStackEntry ->
            val tripId = backStackEntry.arguments?.getString(Screen.AddEditTrip.ARG_TRIP_ID)
            AddEditTripScreen(
                tripId = tripId,
                onNavigateBack = { navController.popBackStack() },
                onTripSaved = { navController.popBackStack() },
            )
        }

        composable(route = Screen.Settings.route) {
            SettingsScreen(
                onNavigateBack = { navController.popBackStack() },
            )
        }
    }
}
