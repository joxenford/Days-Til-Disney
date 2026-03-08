package com.thinkupllc.daystildisney.core.data.repository

import com.thinkupllc.daystildisney.core.model.Trip
import kotlinx.coroutines.flow.Flow

/**
 * Defines the contract for all trip persistence operations.
 * The ViewModel layer depends only on this interface, enabling
 * easy substitution of the local Room implementation with a
 * remote/cloud implementation in post-MVP versions.
 */
interface TripRepository {

    /** Live stream of all trips, re-emitting whenever any trip changes. */
    fun observeAllTrips(): Flow<List<Trip>>

    /** Live stream of the current primary trip, or null if none is set. */
    fun observePrimaryTrip(): Flow<Trip?>

    /** Live stream of a single trip by [id]. */
    fun observeTripById(id: String): Flow<Trip?>

    /** One-shot fetch of a trip by [id]. */
    suspend fun getTripById(id: String): Trip?

    /** Creates a new trip or updates an existing one (upsert by ID). */
    suspend fun saveTrip(trip: Trip)

    /** Deletes the trip with [id]. No-op if the trip does not exist. */
    suspend fun deleteTrip(id: String)

    /**
     * Sets the trip with [tripId] as the primary countdown.
     * Ensures all other trips have isPrimary = false.
     */
    suspend fun setPrimaryTrip(tripId: String)

    /** Returns the total number of stored trips. */
    suspend fun getTripCount(): Int
}
