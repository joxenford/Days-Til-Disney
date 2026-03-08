package com.thinkupllc.daystildisney.engine.milestone

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import com.thinkupllc.daystildisney.core.model.Milestone
import com.thinkupllc.daystildisney.core.model.Trip
import com.thinkupllc.daystildisney.core.util.daysUntil
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import javax.inject.Inject
import javax.inject.Singleton

private val Context.milestoneStore: DataStore<Preferences> by preferencesDataStore(
    name = "milestone_manager"
)

/**
 * DataStore-backed implementation of [MilestoneManager].
 * Acknowledgement state is persisted per (tripId, daysOut) pair so celebrations
 * are shown exactly once and survive app restarts.
 */
@Singleton
class DefaultMilestoneManager @Inject constructor(
    @ApplicationContext private val context: Context,
) : MilestoneManager {

    override fun getCurrentMilestone(trip: Trip): Milestone? {
        val daysOut = trip.startDate.daysUntil().toInt()
        return Milestone.forDaysOut(daysOut)
    }

    override suspend fun isMilestoneAcknowledged(tripId: String, daysOut: Int): Boolean {
        val prefs = context.milestoneStore.data.first()
        return prefs[ackKey(tripId, daysOut)] ?: false
    }

    override suspend fun acknowledgeMilestone(tripId: String, daysOut: Int) {
        context.milestoneStore.edit { prefs ->
            prefs[ackKey(tripId, daysOut)] = true
        }
    }

    private fun ackKey(tripId: String, daysOut: Int): Preferences.Key<Boolean> =
        booleanPreferencesKey("ack_${tripId}_${daysOut}")
}
