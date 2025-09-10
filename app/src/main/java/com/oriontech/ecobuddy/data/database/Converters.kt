package com.oriontech.ecobuddy.data.database

import androidx.room.TypeConverter
import com.oriontech.ecobuddy.data.models.*

class Converters {
    @TypeConverter
    fun fromEvolutionStage(stage: EvolutionStage): String = stage.name
    
    @TypeConverter
    fun toEvolutionStage(stage: String): EvolutionStage = EvolutionStage.valueOf(stage)
    
    @TypeConverter
    fun fromTrashCategory(category: TrashCategory): String = category.name
    
    @TypeConverter
    fun toTrashCategory(category: String): TrashCategory = TrashCategory.valueOf(category)
    
    @TypeConverter
    fun fromAchievementCategory(category: AchievementCategory): String = category.name
    
    @TypeConverter
    fun toAchievementCategory(category: String): AchievementCategory = AchievementCategory.valueOf(category)
    
    @TypeConverter
    fun fromSubscriptionStatus(status: SubscriptionStatus): String = status.name
    
    @TypeConverter
    fun toSubscriptionStatus(status: String): SubscriptionStatus = SubscriptionStatus.valueOf(status)
}
