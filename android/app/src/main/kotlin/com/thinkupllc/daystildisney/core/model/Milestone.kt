package com.thinkupllc.daystildisney.core.model

/**
 * Represents a milestone moment in the countdown.
 * When the countdown hits one of these thresholds, the app triggers
 * a celebration animation and shows a special milestone card.
 */
enum class Milestone(
    val daysOut: Int,
    val title: String,
    val subtitle: String,
    val celebrationType: CelebrationType,
) {
    DAYS_100(
        daysOut = 100,
        title = "100 Days of Magic!",
        subtitle = "Your Disney adventure begins in 100 days. Time to start dreaming!",
        celebrationType = CelebrationType.CONFETTI,
    ),
    DAYS_50(
        daysOut = 50,
        title = "50 Days to Go!",
        subtitle = "Halfway to the magic! Now's the time to make dining reservations.",
        celebrationType = CelebrationType.SPARKLE,
    ),
    DAYS_30(
        daysOut = 30,
        title = "One Month Until Disney!",
        subtitle = "Just one month away! Check your packing list and finalize plans.",
        celebrationType = CelebrationType.CONFETTI,
    ),
    DAYS_14(
        daysOut = 14,
        title = "Two Weeks Away!",
        subtitle = "Two more weeks! Confirm reservations and start packing.",
        celebrationType = CelebrationType.SPARKLE,
    ),
    DAYS_7(
        daysOut = 7,
        title = "One Week to Go!",
        subtitle = "One week! Check the weather forecast and charge your cameras.",
        celebrationType = CelebrationType.FIREWORKS,
    ),
    DAYS_3(
        daysOut = 3,
        title = "Three Days!",
        subtitle = "Only three days! Finish packing and get some rest — big magic ahead.",
        celebrationType = CelebrationType.SPARKLE,
    ),
    DAYS_1(
        daysOut = 1,
        title = "Tomorrow's the Day!",
        subtitle = "One sleep left! The magic is almost here.",
        celebrationType = CelebrationType.FIREWORKS,
    ),
    DAYS_0(
        daysOut = 0,
        title = "TODAY IS THE DAY!",
        subtitle = "Welcome to Disney! Make every moment magical!",
        celebrationType = CelebrationType.FIREWORKS,
    );

    companion object {
        /** Returns the [Milestone] matching [daysOut], or null if no milestone matches. */
        fun forDaysOut(daysOut: Int): Milestone? = entries.find { it.daysOut == daysOut }

        /** Returns true if [daysOut] corresponds to any milestone. */
        fun isMilestone(daysOut: Int): Boolean = forDaysOut(daysOut) != null
    }
}

enum class CelebrationType {
    CONFETTI,
    FIREWORKS,
    SPARKLE,
}
