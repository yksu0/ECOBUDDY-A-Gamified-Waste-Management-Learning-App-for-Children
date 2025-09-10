package com.oriontech.ecobuddy.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "trash_items")
data class TrashItem(
    @PrimaryKey val id: String,
    val name: String,
    val category: TrashCategory,
    val disposalMethod: String,
    val recyclingInfo: String,
    val environmentalImpact: String,
    val funFact: String? = null,
    val scanCount: Int = 0,
    val lastScanned: Long = 0
)

enum class TrashCategory {
    PLASTIC, GLASS, METAL, PAPER, ORGANIC, ELECTRONIC, HAZARDOUS, OTHER
}
