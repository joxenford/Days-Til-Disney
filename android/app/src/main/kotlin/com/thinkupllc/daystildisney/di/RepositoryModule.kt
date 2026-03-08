package com.thinkupllc.daystildisney.di

import com.thinkupllc.daystildisney.core.data.repository.ContentRepository
import com.thinkupllc.daystildisney.core.data.repository.LocalContentRepository
import com.thinkupllc.daystildisney.core.data.repository.LocalTripRepository
import com.thinkupllc.daystildisney.core.data.repository.TripRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt module that binds repository interfaces to their local implementations.
 * Using @Binds (rather than @Provides) avoids unnecessary object creation.
 *
 * To swap in a remote/cloud implementation post-MVP, change the binding here
 * without touching any ViewModel or UI code.
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindTripRepository(
        impl: LocalTripRepository,
    ): TripRepository

    @Binds
    @Singleton
    abstract fun bindContentRepository(
        impl: LocalContentRepository,
    ): ContentRepository
}
