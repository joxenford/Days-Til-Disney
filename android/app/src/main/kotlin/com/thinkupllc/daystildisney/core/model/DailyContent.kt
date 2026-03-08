package com.thinkupllc.daystildisney.core.model

/**
 * A single piece of daily content shown to the user during their countdown.
 * Content is drawn from the bundled JSON library and filtered by [ContentEngine].
 */
data class DailyContent(
    val id: String,
    val type: ContentType,
    val title: String,
    val body: String,
    /** If non-null, this content is only shown for trips that include this park. */
    val parkFilter: DisneyPark?,
    /** If non-null, this content is only shown for trips to this resort. */
    val resortFilter: DisneyResort?,
    /**
     * The days-out window during which this content is appropriate.
     * e.g., 30..89 = shown when 30–89 days remain until the trip.
     */
    val daysOutRange: IntRange,
    /** Optional attribution or source credit. */
    val source: String? = null,
)

enum class ContentType(val displayName: String) {
    FUN_FACT("Fun Fact"),
    PLANNING_TIP("Planning Tip"),
    TRIVIA("Trivia"),
    RIDE_SPOTLIGHT("Ride Spotlight"),
}
