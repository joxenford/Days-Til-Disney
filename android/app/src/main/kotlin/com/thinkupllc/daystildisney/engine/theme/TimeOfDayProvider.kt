package com.thinkupllc.daystildisney.engine.theme

import java.time.LocalTime
import javax.inject.Inject

/**
 * Classifies the current time of day into a [TimeOfDay] segment.
 * Injected as an interface so the real clock can be swapped for a
 * deterministic test clock without changing any other code.
 */
interface TimeOfDayProvider {
    fun getCurrentTimeOfDay(): TimeOfDay
}

/**
 * Production implementation that reads the system clock.
 */
class SystemTimeOfDayProvider @Inject constructor() : TimeOfDayProvider {
    override fun getCurrentTimeOfDay(): TimeOfDay {
        return TimeOfDay.forLocalTime(LocalTime.now())
    }
}

/**
 * The four time-of-day segments used to drive the ambient gradient theming.
 * Boundaries are inclusive on the start, exclusive on the end.
 *
 * Dawn  05:00 – 08:00
 * Day   08:00 – 17:00
 * Dusk  17:00 – 20:00
 * Night 20:00 – 05:00 (wraps around midnight)
 */
enum class TimeOfDay {
    DAWN,
    DAY,
    DUSK,
    NIGHT;

    companion object {
        fun forLocalTime(time: LocalTime): TimeOfDay {
            val hour = time.hour
            return when {
                hour in 5..7   -> DAWN
                hour in 8..16  -> DAY
                hour in 17..19 -> DUSK
                else           -> NIGHT
            }
        }
    }
}
