package com.thinkupllc.daystildisney.core.util

import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

/**
 * Number of full days remaining from today until [this] date.
 * Returns 0 if [this] is today, negative if [this] is in the past.
 */
fun LocalDate.daysUntil(): Long = ChronoUnit.DAYS.between(LocalDate.now(), this)

/**
 * Number of full days remaining from [from] until [this] date.
 */
fun LocalDate.daysUntilFrom(from: LocalDate): Long = ChronoUnit.DAYS.between(from, this)

/**
 * Number of full hours remaining from now until [this] date-time.
 */
fun LocalDateTime.hoursUntil(): Long = ChronoUnit.HOURS.between(LocalDateTime.now(), this)

/**
 * Decomposes the time remaining until [this] date-time into human-readable components.
 * Used for the "final day" countdown that shows hours and minutes instead of days.
 *
 * @return [CountdownComponents] with days, hours, and minutes until [this].
 */
fun LocalDateTime.countdownComponents(): CountdownComponents {
    val now = LocalDateTime.now()
    val totalMinutes = ChronoUnit.MINUTES.between(now, this).coerceAtLeast(0)
    val days = totalMinutes / (60 * 24)
    val hours = (totalMinutes % (60 * 24)) / 60
    val minutes = totalMinutes % 60
    return CountdownComponents(days = days, hours = hours, minutes = minutes)
}

/**
 * Human-readable breakdown of a time duration.
 */
data class CountdownComponents(
    val days: Long,
    val hours: Long,
    val minutes: Long,
) {
    val isToday: Boolean get() = days == 0L && hours == 0L && minutes == 0L
    val isFinalDay: Boolean get() = days == 0L
}

/**
 * Formats a [LocalDate] range as a display string.
 * e.g., "Jun 15 – Jun 22, 2026"
 */
fun formatDateRange(start: LocalDate, end: LocalDate): String {
    val startFormatted = "${start.month.name.lowercase().replaceFirstChar { it.uppercase() }.take(3)} ${start.dayOfMonth}"
    val endFormatted = "${end.month.name.lowercase().replaceFirstChar { it.uppercase() }.take(3)} ${end.dayOfMonth}, ${end.year}"
    return "$startFormatted – $endFormatted"
}
