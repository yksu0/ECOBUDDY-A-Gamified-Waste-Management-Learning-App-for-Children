package com.oriontech.ecobuddy.data.database

import androidx.room.*
import com.oriontech.ecobuddy.data.models.TrashItem
import com.oriontech.ecobuddy.data.models.TrashCategory
import kotlinx.coroutines.flow.Flow

@Dao
interface TrashDao {
    @Query("SELECT * FROM trash_items ORDER BY scanCount DESC")
    fun getAllTrashItems(): Flow<List<TrashItem>>
    
    @Query("SELECT * FROM trash_items WHERE category = :category ORDER BY name ASC")
    fun getTrashByCategory(category: TrashCategory): Flow<List<TrashItem>>
    
    @Query("SELECT * FROM trash_items WHERE id = :id")
    suspend fun getTrashItemById(id: String): TrashItem?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTrashItem(trashItem: TrashItem)
    
    @Query("UPDATE trash_items SET scanCount = scanCount + 1, lastScanned = :timestamp WHERE id = :id")
    suspend fun incrementScanCount(id: String, timestamp: Long)
    
    @Query("SELECT COUNT(*) FROM trash_items")
    suspend fun getTotalTrashCount(): Int
    
    @Query("SELECT SUM(scanCount) FROM trash_items")
    suspend fun getTotalScans(): Int
}
