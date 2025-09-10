package com.oriontech.ecobuddy.data.database

import androidx.room.*
import com.oriontech.ecobuddy.data.models.UserProgress
import kotlinx.coroutines.flow.Flow

@Dao
interface UserProgressDao {
    @Query("SELECT * FROM user_progress WHERE id = 'main_progress'")
    fun getUserProgress(): Flow<UserProgress?>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdateProgress(progress: UserProgress)
    
    @Query("UPDATE user_progress SET totalScans = totalScans + 1 WHERE id = 'main_progress'")
    suspend fun incrementTotalScans()
    
    @Query("UPDATE user_progress SET correctIdentifications = correctIdentifications + 1 WHERE id = 'main_progress'")
    suspend fun incrementCorrectIdentifications()
    
    @Query("UPDATE user_progress SET dailyScansUsed = dailyScansUsed + 1 WHERE id = 'main_progress'")
    suspend fun incrementDailyScansUsed()
    
    @Query("UPDATE user_progress SET dailyScansUsed = 0 WHERE id = 'main_progress'")
    suspend fun resetDailyScans()
    
    @Query("UPDATE user_progress SET streakDays = :days WHERE id = 'main_progress'")
    suspend fun updateStreak(days: Int)
    
    @Query("UPDATE user_progress SET lastScanDate = :date WHERE id = 'main_progress'")
    suspend fun updateLastScanDate(date: Long)
    
    @Query("UPDATE user_progress SET subscriptionStatus = :status WHERE id = 'main_progress'")
    suspend fun updateSubscriptionStatus(status: com.oriontech.ecobuddy.data.models.SubscriptionStatus)
}
