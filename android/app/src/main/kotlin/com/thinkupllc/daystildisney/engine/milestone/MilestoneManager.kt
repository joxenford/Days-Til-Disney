package com.thinkupllc.daystildisney.engine.milestone

import com.thinkupllc.daystildisney.core.model.Milestone
import com.thinkupllc.daystildisney.core.model.Trip

/**
 * Observes a trip countdown and determines whether a milestone celebration
 * should be shown.
 */
interface MilestoneManager {
    /**
     * Returns the [Milestone] that should be celebrated for [trip] today,
     * or null if today is not a milestone day.
     */
    fun getCurrentMilestone(trip: Trip): Milestone?

    /**
     * Returns true if the milestone for [trip] at [daysOut] has already
     * been acknowledged by the user (so we don't re-show celebrations).
     */
    suspend fun isMilestoneAcknowledged(tripId: String, daysOut: Int): Boolean

    /** Records that the user has seen the milestone celebration. */
    suspend fun acknowledgeMilestone(tripId: String, daysOut: Int)
}
