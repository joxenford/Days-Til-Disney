package com.thinkupllc.daystildisney

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/**
 * Application class — required for Hilt's dependency injection.
 * Hilt generates a Hilt component hierarchy rooted here at app startup.
 */
@HiltAndroidApp
class DaysTilDisneyApp : Application()
