package com.oriontech.ecobuddy.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_progress")
data class UserProgress(
    @PrimaryKey val id: String = "main_progress",
    val totalScans: Int = 0,
    val correctIdentifications: Int = 0,
    val streakDays: Int = 0,
    val lastScanDate: Long = 0,
    val totalXpEarned: Int = 0,
    val subscriptionStatus: SubscriptionStatus = SubscriptionStatus.FREE,
    val dailyScansUsed: Int = 0,
    val dailyScansLimit: Int = 5 // Free tier limit
)

enum class SubscriptionStatus {
    FREE, PREMIUM
}
