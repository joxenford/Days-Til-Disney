package com.thinkupllc.daystildisney.engine.content

import com.thinkupllc.daystildisney.core.model.DailyContent
import com.thinkupllc.daystildisney.core.model.Trip

/**
 * Selects the daily content item to display for a given trip.
 *
 * The engine is responsible for:
 * - Filtering content by park, resort, and days-out range
 * - Avoiding repetition (same content shown twice for the same trip)
 * - Graceful fallback when no ideal content is available
 */
interface ContentEngine {
    /**
     * Returns today's content for [trip].
     * Returns null only if the content library is completely empty or unreachable.
     */
    suspend fun getDailyContent(trip: Trip): DailyContent?
}
