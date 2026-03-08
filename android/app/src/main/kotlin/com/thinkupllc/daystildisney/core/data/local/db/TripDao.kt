package com.thinkupllc.daystildisney.core.data.local.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

/**
 * Room DAO for all trip persistence operations.
 * All list queries return [Flow] so the UI layer can observe live updates.
 */
@Dao
interface TripDao {

    /** Observe all trips, ordered by primary first, then creation date descending. */
    @Query("SELECT * FROM trips ORDER BY is_primary DESC, created_at DESC")
    fun observeAllTrips(): Flow<List<TripEntity>>

    /** Observe the single trip marked as primary, or null if none. */
    @Query("SELECT * FROM trips WHERE is_primary = 1 LIMIT 1")
    fun observePrimaryTrip(): Flow<TripEntity?>

    /** One-shot fetch of a trip by its ID. Returns null if not found. */
    @Query("SELECT * FROM trips WHERE id = :id")
    suspend fun getTripById(id: String): TripEntity?

    /** Observe a single trip by ID (live updates). */
    @Query("SELECT * FROM trips WHERE id = :id")
    fun observeTripById(id: String): Flow<TripEntity?>

    /** One-shot fetch of all trips (non-reactive, for use in non-UI coroutines). */
    @Query("SELECT * FROM trips ORDER BY is_primary DESC, created_at DESC")
    suspend fun getAllTrips(): List<TripEntity>

    /**
     * Insert or replace a trip. Using REPLACE strategy means updates are handled
     * via upsert semantics — callers don't need to distinguish insert vs. update.
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertTrip(trip: TripEntity)

    /** Insert multiple trips at once (used for initial data seeding). */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertTrips(trips: List<TripEntity>)

    @Update
    suspend fun updateTrip(trip: TripEntity)

    @Delete
    suspend fun deleteTrip(trip: TripEntity)

    @Query("DELETE FROM trips WHERE id = :id")
    suspend fun deleteTripById(id: String)

    /**
     * Clears the primary flag from ALL trips.
     * Call this before setting a new primary to ensure only one is ever primary.
     */
    @Query("UPDATE trips SET is_primary = 0")
    suspend fun clearAllPrimaryFlags()

    /** Sets the specified trip as primary and clears all others. */
    @Query("UPDATE trips SET is_primary = (id = :tripId)")
    suspend fun setPrimaryTrip(tripId: String)

    @Query("SELECT COUNT(*) FROM trips")
    suspend fun getTripCount(): Int
}
