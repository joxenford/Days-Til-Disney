package com.thinkupllc.daystildisney.di

import android.content.Context
import androidx.room.Room
import com.thinkupllc.daystildisney.core.data.local.db.AppDatabase
import com.thinkupllc.daystildisney.core.data.local.db.TripDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt module for infrastructure-level dependencies:
 * the Room database, its DAOs, and the DataStore.
 *
 * DataStore instances are provided directly in [PreferencesDataStore]
 * via @Inject so no explicit @Provides is needed here for DataStore.
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideAppDatabase(
        @ApplicationContext context: Context,
    ): AppDatabase = Room.databaseBuilder(
        context,
        AppDatabase::class.java,
        AppDatabase.DATABASE_NAME,
    )
        .fallbackToDestructiveMigration()  // Replace with Migrations before production release
        .build()

    @Provides
    @Singleton
    fun provideTripDao(database: AppDatabase): TripDao = database.tripDao()
}
