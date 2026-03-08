package com.thinkupllc.daystildisney.core.data.local.db

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.thinkupllc.daystildisney.core.model.DisneyPark
import com.thinkupllc.daystildisney.core.model.DisneyResort
import com.thinkupllc.daystildisney.core.model.Trip
import java.time.Instant
import java.time.LocalDate

/**
 * Room entity for persisting a [Trip].
 * Kept intentionally separate from the domain [Trip] model so the database
 * schema can evolve independently of the UI layer.
 *
 * Parks are stored as a comma-separated string of enum names via [Converters].
 */
@Entity(tableName = "trips")
data class TripEntity(
    @PrimaryKey
    @ColumnInfo(name = "id")
    val id: String,

    @ColumnInfo(name = "name")
    val name: String,

    @ColumnInfo(name = "resort")
    val resort: String,           // DisneyResort.name()

    @ColumnInfo(name = "parks")
    val parks: String,            // Comma-separated DisneyPark.name() values

    @ColumnInfo(name = "start_date")
    val startDate: String,        // ISO-8601 LocalDate (yyyy-MM-dd)

    @ColumnInfo(name = "end_date")
    val endDate: String,          // ISO-8601 LocalDate (yyyy-MM-dd)

    @ColumnInfo(name = "is_primary")
    val isPrimary: Boolean,

    @ColumnInfo(name = "created_at")
    val createdAt: Long,          // Epoch millis

    @ColumnInfo(name = "updated_at")
    val updatedAt: Long,          // Epoch millis
) {
    /** Maps this persistence entity to the domain [Trip] model. */
    fun toDomain(): Trip = Trip(
        id = id,
        name = name,
        resort = DisneyResort.valueOf(resort),
        parks = parks.split(",")
            .filter { it.isNotBlank() }
            .map { DisneyPark.valueOf(it) },
        startDate = LocalDate.parse(startDate),
        endDate = LocalDate.parse(endDate),
        isPrimary = isPrimary,
        createdAt = Instant.ofEpochMilli(createdAt),
        updatedAt = Instant.ofEpochMilli(updatedAt),
    )

    companion object {
        /** Creates a [TripEntity] from a domain [Trip]. */
        fun fromDomain(trip: Trip): TripEntity = TripEntity(
            id = trip.id,
            name = trip.name,
            resort = trip.resort.name,
            parks = trip.parks.joinToString(",") { it.name },
            startDate = trip.startDate.toString(),
            endDate = trip.endDate.toString(),
            isPrimary = trip.isPrimary,
            createdAt = trip.createdAt.toEpochMilli(),
            updatedAt = trip.updatedAt.toEpochMilli(),
        )
    }
}
