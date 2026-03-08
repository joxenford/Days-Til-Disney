package com.thinkupllc.daystildisney.core.data.repository

import com.thinkupllc.daystildisney.core.data.local.db.TripDao
import com.thinkupllc.daystildisney.core.data.local.db.TripEntity
import com.thinkupllc.daystildisney.core.model.Trip
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

/**
 * Room-backed implementation of [TripRepository].
 * All operations are performed on the caller's coroutine context;
 * Room handles the IO dispatcher internally for suspend functions.
 */
class LocalTripRepository @Inject constructor(
    private val tripDao: TripDao,
) : TripRepository {

    override fun observeAllTrips(): Flow<List<Trip>> =
        tripDao.observeAllTrips().map { entities ->
            entities.map { it.toDomain() }
        }

    override fun observePrimaryTrip(): Flow<Trip?> =
        tripDao.observePrimaryTrip().map { it?.toDomain() }

    override fun observeTripById(id: String): Flow<Trip?> =
        tripDao.observeTripById(id).map { it?.toDomain() }

    override suspend fun getTripById(id: String): Trip? =
        tripDao.getTripById(id)?.toDomain()

    override suspend fun saveTrip(trip: Trip) {
        tripDao.upsertTrip(TripEntity.fromDomain(trip))
    }

    override suspend fun deleteTrip(id: String) {
        tripDao.deleteTripById(id)
    }

    override suspend fun setPrimaryTrip(tripId: String) {
        // Use the atomic SQL expression on TripDao to set primary in one query
        tripDao.setPrimaryTrip(tripId)
    }

    override suspend fun getTripCount(): Int = tripDao.getTripCount()
}
