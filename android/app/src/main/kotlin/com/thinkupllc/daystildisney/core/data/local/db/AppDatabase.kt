package com.thinkupllc.daystildisney.core.data.local.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

/**
 * The single Room database for the app.
 *
 * Version history:
 *   1 — Initial schema (MVP)
 *
 * Increment [version] and add a [Migration] whenever the schema changes.
 * Schema JSON files are exported to app/schemas/ for migration validation.
 */
@Database(
    entities = [TripEntity::class],
    version = 1,
    exportSchema = true,
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {

    abstract fun tripDao(): TripDao

    companion object {
        const val DATABASE_NAME = "daystildisney.db"
    }
}
