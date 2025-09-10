package com.oriontech.ecobuddy.data.database

import android.content.Context
import androidx.room.*
import com.oriontech.ecobuddy.data.models.*

@Database(
    entities = [Pet::class, TrashItem::class, Achievement::class, UserProgress::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class EcoBuddyDatabase : RoomDatabase() {
    abstract fun petDao(): PetDao
    abstract fun trashDao(): TrashDao
    abstract fun achievementDao(): AchievementDao
    abstract fun userProgressDao(): UserProgressDao
    
    companion object {
        @Volatile
        private var INSTANCE: EcoBuddyDatabase? = null
        
        fun getDatabase(context: Context): EcoBuddyDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    EcoBuddyDatabase::class.java,
                    "ecobuddy_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
