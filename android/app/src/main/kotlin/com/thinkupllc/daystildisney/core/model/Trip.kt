package com.thinkupllc.daystildisney.core.model

import java.time.Instant
import java.time.LocalDate

/**
 * Domain model for a Disney trip. This is the object ViewModels and the UI
 * layer work with directly. It is intentionally separate from [TripEntity],
 * the Room persistence model, so the database schema can evolve independently.
 */
data class Trip(
    val id: String,
    val name: String,
    val resort: DisneyResort,
    /** One or more parks within the resort selected for this trip. */
    val parks: List<DisneyPark>,
    val startDate: LocalDate,
    val endDate: LocalDate,
    /** The primary trip is shown as the hero countdown on the Home screen. */
    val isPrimary: Boolean,
    val createdAt: Instant,
    val updatedAt: Instant,
) {
    /**
     * The lead park drives all theming. When the user selects multiple parks,
     * the first selected park is used as the visual theme source.
     */
    val primaryPark: DisneyPark
        get() = parks.firstOrNull() ?: resort.parks.firstOrNull() ?: DisneyPark.MAGIC_KINGDOM

    /** True if today is before [startDate]. */
    val isFuture: Boolean
        get() = LocalDate.now().isBefore(startDate)

    /** True if today falls within [startDate]..[endDate] (inclusive). */
    val isActive: Boolean
        get() {
            val today = LocalDate.now()
            return !today.isBefore(startDate) && !today.isAfter(endDate)
        }

    /** True if the trip has ended. */
    val isPast: Boolean
        get() = LocalDate.now().isAfter(endDate)
}
