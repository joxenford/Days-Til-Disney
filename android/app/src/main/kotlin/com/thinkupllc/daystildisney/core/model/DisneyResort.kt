package com.thinkupllc.daystildisney.core.model

/**
 * All six Disney resort destinations worldwide.
 * Each resort holds the list of parks within it and display metadata.
 */
enum class DisneyResort(
    val displayName: String,
    val shortName: String,
    val location: String,
) {
    WALT_DISNEY_WORLD(
        displayName = "Walt Disney World",
        shortName = "WDW",
        location = "Orlando, Florida, USA",
    ),
    DISNEYLAND_RESORT(
        displayName = "Disneyland Resort",
        shortName = "DLR",
        location = "Anaheim, California, USA",
    ),
    TOKYO_DISNEY_RESORT(
        displayName = "Tokyo Disney Resort",
        shortName = "TDR",
        location = "Urayasu, Chiba, Japan",
    ),
    DISNEYLAND_PARIS(
        displayName = "Disneyland Paris",
        shortName = "DLP",
        location = "Marne-la-Vallée, France",
    ),
    HONG_KONG_DISNEYLAND(
        displayName = "Hong Kong Disneyland",
        shortName = "HKDL",
        location = "Lantau Island, Hong Kong",
    ),
    SHANGHAI_DISNEYLAND(
        displayName = "Shanghai Disneyland",
        shortName = "SHDL",
        location = "Pudong, Shanghai, China",
    );

    /** Returns all parks belonging to this resort. */
    val parks: List<DisneyPark>
        get() = DisneyPark.entries.filter { it.resort == this }
}
