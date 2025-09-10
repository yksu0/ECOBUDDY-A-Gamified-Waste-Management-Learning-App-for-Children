package com.oriontech.ecobuddy.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "pets")
data class Pet(
    @PrimaryKey val id: String = "bud", // Single pet per user for now
    val name: String = "Bud",
    val level: Int = 1,
    val xp: Int = 0,
    val happiness: Int = 100,
    val evolutionStage: EvolutionStage = EvolutionStage.BABY,
    val lastInteraction: Long = System.currentTimeMillis(),
    val isNeglected: Boolean = false
)

enum class EvolutionStage {
    BABY, CHILD, ADULT
}

enum class PetEmotion {
    HAPPY, SAD, EXCITED, SLEEPY, NEUTRAL
}
