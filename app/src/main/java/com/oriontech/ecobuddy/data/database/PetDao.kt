package com.oriontech.ecobuddy.data.database

import androidx.room.*
import com.oriontech.ecobuddy.data.models.Pet
import kotlinx.coroutines.flow.Flow

@Dao
interface PetDao {
    @Query("SELECT * FROM pets WHERE id = 'bud'")
    fun getPet(): Flow<Pet?>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdatePet(pet: Pet)
    
    @Query("UPDATE pets SET happiness = :happiness WHERE id = 'bud'")
    suspend fun updateHappiness(happiness: Int)
    
    @Query("UPDATE pets SET xp = :xp, level = :level WHERE id = 'bud'")
    suspend fun updateXpAndLevel(xp: Int, level: Int)
    
    @Query("UPDATE pets SET evolutionStage = :stage WHERE id = 'bud'")
    suspend fun updateEvolutionStage(stage: com.oriontech.ecobuddy.data.models.EvolutionStage)
    
    @Query("UPDATE pets SET lastInteraction = :timestamp WHERE id = 'bud'")
    suspend fun updateLastInteraction(timestamp: Long)
    
    @Query("UPDATE pets SET isNeglected = :neglected WHERE id = 'bud'")
    suspend fun updateNeglectStatus(neglected: Boolean)
}
