package com.oriontech.ecobuddy.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.oriontech.ecobuddy.ui.screens.*

@Composable
fun EcoBuddyNavigation(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = "home"
    ) {
        composable("home") {
            HomeScreen(navController = navController)
        }
        composable("scanner") {
            ScannerScreen(navController = navController)
        }
        composable("pet_care") {
            PetCareScreen(navController = navController)
        }
        composable("achievements") {
            AchievementsScreen(navController = navController)
        }
        composable("mini_games") {
            MiniGamesScreen(navController = navController)
        }
        composable("settings") {
            SettingsScreen(navController = navController)
        }
    }
}

sealed class Screen(val route: String) {
    object Home : Screen("home")
    object Scanner : Screen("scanner")
    object PetCare : Screen("pet_care")
    object Achievements : Screen("achievements")
    object MiniGames : Screen("mini_games")
    object Settings : Screen("settings")
}
