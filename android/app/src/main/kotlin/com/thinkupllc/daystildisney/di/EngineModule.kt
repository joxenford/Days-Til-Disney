package com.thinkupllc.daystildisney.di

import com.thinkupllc.daystildisney.engine.content.ContentEngine
import com.thinkupllc.daystildisney.engine.content.LocalContentEngine
import com.thinkupllc.daystildisney.engine.milestone.DefaultMilestoneManager
import com.thinkupllc.daystildisney.engine.milestone.MilestoneManager
import com.thinkupllc.daystildisney.engine.theme.SystemTimeOfDayProvider
import com.thinkupllc.daystildisney.engine.theme.TimeOfDayProvider
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt module for engine/service layer interfaces.
 * Each engine interface is bound to its production implementation here.
 * Swap implementations for tests by providing a test module.
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class EngineModule {

    @Binds
    @Singleton
    abstract fun bindContentEngine(
        impl: LocalContentEngine,
    ): ContentEngine

    @Binds
    @Singleton
    abstract fun bindMilestoneManager(
        impl: DefaultMilestoneManager,
    ): MilestoneManager

    @Binds
    @Singleton
    abstract fun bindTimeOfDayProvider(
        impl: SystemTimeOfDayProvider,
    ): TimeOfDayProvider
}
