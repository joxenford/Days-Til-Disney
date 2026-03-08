package com.thinkupllc.daystildisney.core.data.repository

import android.content.Context
import com.thinkupllc.daystildisney.core.model.ContentType
import com.thinkupllc.daystildisney.core.model.DailyContent
import com.thinkupllc.daystildisney.core.model.DisneyPark
import com.thinkupllc.daystildisney.core.model.DisneyResort
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Loads daily content from the bundled [assets/daily_content.json] file.
 * Content is parsed once and cached in memory for the app's lifetime.
 */
@Singleton
class LocalContentRepository @Inject constructor(
    @ApplicationContext private val context: Context,
) : ContentRepository {

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    // Lazy in-memory cache: loaded once on first access, held for the session.
    private var cachedContent: List<DailyContent>? = null

    override suspend fun getAllContent(): List<DailyContent> {
        return cachedContent ?: loadContentFromAssets().also { cachedContent = it }
    }

    override suspend fun getEligibleContent(
        daysUntilTrip: Int,
        park: DisneyPark,
        resort: DisneyResort,
    ): List<DailyContent> {
        return getAllContent().filter { content ->
            isEligible(content, daysUntilTrip, park, resort)
        }
    }

    override suspend fun getContentByType(
        type: ContentType,
        daysUntilTrip: Int,
        park: DisneyPark,
        resort: DisneyResort,
    ): List<DailyContent> {
        return getEligibleContent(daysUntilTrip, park, resort)
            .filter { it.type == type }
    }

    private fun isEligible(
        content: DailyContent,
        daysUntilTrip: Int,
        park: DisneyPark,
        resort: DisneyResort,
    ): Boolean {
        // Check days-out range
        if (daysUntilTrip !in content.daysOutRange) return false
        // Check park filter (null = applies to all parks)
        if (content.parkFilter != null && content.parkFilter != park) return false
        // Check resort filter (null = applies to all resorts)
        if (content.resortFilter != null && content.resortFilter != resort) return false
        return true
    }

    private suspend fun loadContentFromAssets(): List<DailyContent> =
        withContext(Dispatchers.IO) {
            try {
                val jsonString = context.assets
                    .open("daily_content.json")
                    .bufferedReader()
                    .use { it.readText() }
                val dtos = json.decodeFromString<List<DailyContentDto>>(jsonString)
                dtos.mapNotNull { it.toDomain() }
            } catch (e: Exception) {
                // Log in production, return empty list so app doesn't crash
                emptyList()
            }
        }
}

// ---------------------------------------------------------------------------
// Internal DTO — decouples JSON shape from the domain model
// ---------------------------------------------------------------------------

@Serializable
private data class DailyContentDto(
    val id: String,
    val type: String,
    val title: String,
    val body: String,
    val parkFilter: String? = null,
    val resortFilter: String? = null,
    val daysOutMin: Int,
    val daysOutMax: Int,
    val source: String? = null,
) {
    fun toDomain(): DailyContent? {
        val contentType = runCatching { ContentType.valueOf(type) }.getOrNull() ?: return null
        val park = parkFilter?.let { runCatching { DisneyPark.valueOf(it) }.getOrNull() }
        val resort = resortFilter?.let { runCatching { DisneyResort.valueOf(it) }.getOrNull() }
        return DailyContent(
            id = id,
            type = contentType,
            title = title,
            body = body,
            parkFilter = park,
            resortFilter = resort,
            daysOutRange = daysOutMin..daysOutMax,
            source = source,
        )
    }
}
