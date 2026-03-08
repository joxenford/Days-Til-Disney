package com.thinkupllc.daystildisney.core.data.local.db

import androidx.room.TypeConverter
import java.time.Instant
import java.time.LocalDate

/**
 * Room type converters for types that Room cannot persist natively.
 * Registered via @TypeConverters on [AppDatabase].
 *
 * Design note: We store dates as their ISO-8601 string representation
 * (rather than epoch millis) so they are human-readable in db inspection
 * tools and survive timezone changes without silent bugs.
 */
class Converters {

    @TypeConverter
    fun localDateToString(date: LocalDate?): String? = date?.toString()

    @TypeConverter
    fun stringToLocalDate(value: String?): LocalDate? =
        value?.let { LocalDate.parse(it) }

    @TypeConverter
    fun instantToLong(instant: Instant?): Long? = instant?.toEpochMilli()

    @TypeConverter
    fun longToInstant(value: Long?): Instant? =
        value?.let { Instant.ofEpochMilli(it) }
}
