package com.thinkupllc.daystildisney.engine.content

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.thinkupllc.daystildisney.core.data.repository.ContentRepository
import com.thinkupllc.daystildisney.core.model.DailyContent
import com.thinkupllc.daystildisney.core.model.Trip
import com.thinkupllc.daystildisney.core.util.daysUntil
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import javax.inject.Inject
import javax.inject.Singleton

private val Context.contentEngineStore: DataStore<Preferences> by preferencesDataStore(
    name = "content_engine"
)

/**
 * Selects daily content from the local [ContentRepository], using DataStore
 * to track which content has already been shown per trip so nothing repeats.
 *
 * Selection algorithm:
 * 1. Filter all content by days-out range, park, and resort.
 * 2. Remove IDs that have already been shown for this trip.
 * 3. Prefer content matching the exact park; fall back to resort-only; fall back to universal.
 * 4. If all content in a category has been exhausted, reset the shown set for that trip
 *    and start the cycle over (better than no content).
 */
@Singleton
class LocalContentEngine @Inject constructor(
    @ApplicationContext private val context: Context,
    private val contentRepository: ContentRepository,
) : ContentEngine {

    override suspend fun getDailyContent(trip: Trip): DailyContent? {
        val daysOut = trip.startDate.daysUntil().toInt().coerceAtLeast(0)
        val eligible = contentRepository.getEligibleContent(
            daysUntilTrip = daysOut,
            park = trip.primaryPark,
            resort = trip.resort,
        )

        if (eligible.isEmpty()) return null

        val shownIds = getShownContentIds(trip.id)
        val unseen = eligible.filter { it.id !in shownIds }

        // If everything eligible has been seen, reset and start over for this trip
        val candidates = unseen.ifEmpty {
            resetShownContent(trip.id)
            eligible
        }

        // Preference order: exact park match > resort match > universal
        val selected = candidates.firstOrNull { it.parkFilter == trip.primaryPark }
            ?: candidates.firstOrNull { it.resortFilter == trip.resort && it.parkFilter == null }
            ?: candidates.firstOrNull { it.parkFilter == null && it.resortFilter == null }
            ?: candidates.first()

        markContentAsShown(trip.id, selected.id)
        return selected
    }

    private suspend fun getShownContentIds(tripId: String): Set<String> {
        val prefs = context.contentEngineStore.data.first()
        val key = shownKey(tripId)
        val raw = prefs[key] ?: return emptySet()
        return raw.split(",").filter { it.isNotBlank() }.toSet()
    }

    private suspend fun markContentAsShown(tripId: String, contentId: String) {
        context.contentEngineStore.edit { prefs ->
            val key = shownKey(tripId)
            val existing = prefs[key] ?: ""
            val updated = if (existing.isBlank()) contentId else "$existing,$contentId"
            prefs[key] = updated
        }
    }

    private suspend fun resetShownContent(tripId: String) {
        context.contentEngineStore.edit { prefs ->
            prefs.remove(shownKey(tripId))
        }
    }

    private fun shownKey(tripId: String): Preferences.Key<String> =
        stringPreferencesKey("shown_$tripId")
}
