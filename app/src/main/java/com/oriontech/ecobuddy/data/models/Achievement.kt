package com.oriontech.ecobuddy.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "achievements")
data class Achievement(
    @PrimaryKey val id: String,
    val title: String,
    val description: String,
    val isUnlocked: Boolean = false,
    val unlockedDate: Long? = null,
    val category: AchievementCategory,
    val requiredValue: Int,
    val currentValue: Int = 0
)

enum class AchievementCategory {
    SCANNING, PET_CARE, STREAKS, LEARNING, SPECIAL
}
