package com.thinkupllc.daystildisney.core.data.repository

import com.thinkupllc.daystildisney.core.model.ContentType
import com.thinkupllc.daystildisney.core.model.DailyContent
import com.thinkupllc.daystildisney.core.model.DisneyPark
import com.thinkupllc.daystildisney.core.model.DisneyResort

/**
 * Defines the contract for accessing the daily content library.
 * In MVP, the implementation loads from a bundled JSON asset.
 * Post-MVP, a remote implementation could fetch from a content CMS.
 */
interface ContentRepository {

    /** Returns all content items in the library. */
    suspend fun getAllContent(): List<DailyContent>

    /**
     * Returns content eligible for a given trip context.
     *
     * @param daysUntilTrip Days remaining until the trip start date.
     * @param park The primary park for the trip (used for park-specific content).
     * @param resort The resort for the trip (used for resort-specific content).
     */
    suspend fun getEligibleContent(
        daysUntilTrip: Int,
        park: DisneyPark,
        resort: DisneyResort,
    ): List<DailyContent>

    /**
     * Returns content filtered by type and trip context.
     */
    suspend fun getContentByType(
        type: ContentType,
        daysUntilTrip: Int,
        park: DisneyPark,
        resort: DisneyResort,
    ): List<DailyContent>
}
