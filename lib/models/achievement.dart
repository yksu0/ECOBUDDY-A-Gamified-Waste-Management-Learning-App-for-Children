import 'package:flutter/material.dart';

enum AchievementCategory {
  scanning,
  petCare,
  environmental,
  learning,
  streak,
  special,
}

enum AchievementType {
  // Scanning achievements
  firstScan,
  scan10Items,
  scan50Items,
  scan100Items,
  scan500Items,
  perfectAccuracy,
  diverseScanning,
  
  // Pet care achievements
  firstFeed,
  petCare7Days,
  petCare30Days,
  happyPet,
  petLover,
  
  // Environmental achievements
  recyclingChampion,
  wasteReducer,
  ecoWarrior,
  planetProtector,
  greenLiving,
  
  // Learning achievements
  funFactReader,
  knowledgeSeeker,
  ecoExpert,
  teachersPet,
  
  // Streak achievements
  dailyUser,
  weeklyChampion,
  monthlyHero,
  
  // Special achievements
  earlyAdopter,
  bugReporter,
  socialSharer,
  perfectWeek,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int pointsRequired;
  final int rewardPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  final String progressDescription;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.pointsRequired,
    required this.rewardPoints,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
    this.progressDescription = '',
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
    String? progressDescription,
  }) {
    return Achievement(
      type: type,
      title: title,
      description: description,
      icon: icon,
      color: color,
      category: category,
      pointsRequired: pointsRequired,
      rewardPoints: rewardPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      progressDescription: progressDescription ?? this.progressDescription,
    );
  }

  double get progressPercentage {
    if (pointsRequired == 0) return 1.0;
    return (currentProgress / pointsRequired).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentProgress >= pointsRequired;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
      'progressDescription': progressDescription,
    };
  }

  static Achievement fromJson(Map<String, dynamic> json, Achievement template) {
    return template.copyWith(
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      currentProgress: json['currentProgress'] ?? 0,
      progressDescription: json['progressDescription'] ?? '',
    );
  }
}

class AchievementDatabase {
  static const Map<AchievementType, Achievement> _achievements = {
    // Scanning achievements
    AchievementType.firstScan: Achievement(
      type: AchievementType.firstScan,
      title: 'First Discovery',
      description: 'Take your first photo and identify an item!',
      icon: Icons.camera_alt,
      color: Colors.green,
      category: AchievementCategory.scanning,
      pointsRequired: 1,
      rewardPoints: 50,
    ),
    
    AchievementType.scan10Items: Achievement(
      type: AchievementType.scan10Items,
      title: 'Explorer',
      description: 'Successfully identify 10 different items',
      icon: Icons.search,
      color: Colors.blue,
      category: AchievementCategory.scanning,
      pointsRequired: 10,
      rewardPoints: 100,
    ),
    
    AchievementType.scan50Items: Achievement(
      type: AchievementType.scan50Items,
      title: 'Investigator',
      description: 'Scan and identify 50 items - you\'re getting good at this!',
      icon: Icons.visibility,
      color: Colors.purple,
      category: AchievementCategory.scanning,
      pointsRequired: 50,
      rewardPoints: 250,
    ),
    
    AchievementType.scan100Items: Achievement(
      type: AchievementType.scan100Items,
      title: 'Recognition Expert',
      description: 'Wow! You\'ve identified 100 items. You\'re an expert!',
      icon: Icons.star,
      color: Colors.orange,
      category: AchievementCategory.scanning,
      pointsRequired: 100,
      rewardPoints: 500,
    ),
    
    AchievementType.perfectAccuracy: Achievement(
      type: AchievementType.perfectAccuracy,
      title: 'Sharp Eye',
      description: 'Get 10 high-confidence scans in a row (>90% accuracy)',
      icon: Icons.precision_manufacturing,
      color: Colors.red,
      category: AchievementCategory.scanning,
      pointsRequired: 10,
      rewardPoints: 200,
    ),
    
    AchievementType.diverseScanning: Achievement(
      type: AchievementType.diverseScanning,
      title: 'Variety Hunter',
      description: 'Scan items from all 7 waste categories',
      icon: Icons.category,
      color: Colors.teal,
      category: AchievementCategory.scanning,
      pointsRequired: 7,
      rewardPoints: 300,
    ),

    // Pet care achievements
    AchievementType.firstFeed: Achievement(
      type: AchievementType.firstFeed,
      title: 'Pet Parent',
      description: 'Feed your EcoBuddy for the first time!',
      icon: Icons.pets,
      color: Colors.pink,
      category: AchievementCategory.petCare,
      pointsRequired: 1,
      rewardPoints: 25,
    ),
    
    AchievementType.petCare7Days: Achievement(
      type: AchievementType.petCare7Days,
      title: 'Caring Friend',
      description: 'Take care of your pet for 7 consecutive days',
      icon: Icons.favorite,
      color: Colors.red,
      category: AchievementCategory.petCare,
      pointsRequired: 7,
      rewardPoints: 150,
    ),
    
    AchievementType.petCare30Days: Achievement(
      type: AchievementType.petCare30Days,
      title: 'Devoted Guardian',
      description: 'Care for your EcoBuddy for 30 days straight!',
      icon: Icons.stars,
      color: Colors.amber,
      category: AchievementCategory.petCare,
      pointsRequired: 30,
      rewardPoints: 750,
    ),
    
    AchievementType.happyPet: Achievement(
      type: AchievementType.happyPet,
      title: 'Happiness Maker',
      description: 'Keep your pet at maximum happiness for 24 hours',
      icon: Icons.sentiment_very_satisfied,
      color: Colors.yellow,
      category: AchievementCategory.petCare,
      pointsRequired: 24,
      rewardPoints: 200,
    ),

    // Environmental achievements
    AchievementType.recyclingChampion: Achievement(
      type: AchievementType.recyclingChampion,
      title: 'Recycling Champion',
      description: 'Identify 25 recyclable items correctly',
      icon: Icons.recycling,
      color: Colors.green,
      category: AchievementCategory.environmental,
      pointsRequired: 25,
      rewardPoints: 300,
    ),
    
    AchievementType.ecoWarrior: Achievement(
      type: AchievementType.ecoWarrior,
      title: 'Eco Warrior',
      description: 'Learn about environmental impact of 50 different items',
      icon: Icons.eco,
      color: Colors.lightGreen,
      category: AchievementCategory.environmental,
      pointsRequired: 50,
      rewardPoints: 400,
    ),
    
    AchievementType.planetProtector: Achievement(
      type: AchievementType.planetProtector,
      title: 'Planet Protector',
      description: 'Accumulate 1000 total recycling points',
      icon: Icons.public,
      color: Colors.blue,
      category: AchievementCategory.environmental,
      pointsRequired: 1000,
      rewardPoints: 1000,
    ),

    // Learning achievements
    AchievementType.funFactReader: Achievement(
      type: AchievementType.funFactReader,
      title: 'Curious Mind',
      description: 'Read fun facts about 20 different items',
      icon: Icons.lightbulb,
      color: Colors.orange,
      category: AchievementCategory.learning,
      pointsRequired: 20,
      rewardPoints: 150,
    ),
    
    AchievementType.knowledgeSeeker: Achievement(
      type: AchievementType.knowledgeSeeker,
      title: 'Knowledge Seeker',
      description: 'View disposal instructions for 30 items',
      icon: Icons.school,
      color: Colors.indigo,
      category: AchievementCategory.learning,
      pointsRequired: 30,
      rewardPoints: 200,
    ),
    
    AchievementType.ecoExpert: Achievement(
      type: AchievementType.ecoExpert,
      title: 'Eco Expert',
      description: 'Master knowledge about all waste categories',
      icon: Icons.psychology,
      color: Colors.deepPurple,
      category: AchievementCategory.learning,
      pointsRequired: 8, // All categories + general knowledge
      rewardPoints: 500,
    ),

    // Streak achievements
    AchievementType.dailyUser: Achievement(
      type: AchievementType.dailyUser,
      title: 'Daily Explorer',
      description: 'Use the app 3 days in a row',
      icon: Icons.calendar_today,
      color: Colors.cyan,
      category: AchievementCategory.streak,
      pointsRequired: 3,
      rewardPoints: 100,
    ),
    
    AchievementType.weeklyChampion: Achievement(
      type: AchievementType.weeklyChampion,
      title: 'Weekly Champion',
      description: 'Use the app every day for a week',
      icon: Icons.date_range,
      color: Colors.teal,
      category: AchievementCategory.streak,
      pointsRequired: 7,
      rewardPoints: 300,
    ),
    
    AchievementType.monthlyHero: Achievement(
      type: AchievementType.monthlyHero,
      title: 'Monthly Hero',
      description: 'Keep your streak going for 30 days!',
      icon: Icons.emoji_events,
      color: Colors.amber,
      category: AchievementCategory.streak,
      pointsRequired: 30,
      rewardPoints: 1000,
    ),

    // Special achievements
    AchievementType.earlyAdopter: Achievement(
      type: AchievementType.earlyAdopter,
      title: 'Early Adopter',
      description: 'Welcome to EcoBuddy! Thanks for trying our app!',
      icon: Icons.rocket_launch,
      color: Colors.purple,
      category: AchievementCategory.special,
      pointsRequired: 1,
      rewardPoints: 100,
    ),
    
    AchievementType.perfectWeek: Achievement(
      type: AchievementType.perfectWeek,
      title: 'Perfect Week',
      description: 'Complete all daily activities for a full week',
      icon: Icons.workspace_premium,
      color: Colors.amber,
      category: AchievementCategory.special,
      pointsRequired: 7,
      rewardPoints: 500,
    ),
  };

  static Achievement? getAchievement(AchievementType type) {
    return _achievements[type];
  }

  static List<Achievement> getAllAchievements() {
    return _achievements.values.toList();
  }

  static List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.values
        .where((achievement) => achievement.category == category)
        .toList();
  }
}