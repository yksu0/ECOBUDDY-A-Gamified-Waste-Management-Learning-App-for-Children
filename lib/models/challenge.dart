import 'package:flutter/material.dart';

enum ChallengeType {
  scanning,
  petCare,
  learning,
  streak,
  environmental,
  special,
}

enum ChallengeDifficulty {
  easy,
  medium,
  hard,
}

enum ChallengeFrequency {
  daily,
  weekly,
  special,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final ChallengeFrequency frequency;
  final IconData icon;
  final Color color;
  final int targetValue;
  final int currentProgress;
  final int rewardPoints;
  final int rewardCoins;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> hints;
  final String progressDescription;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.frequency,
    required this.icon,
    required this.color,
    required this.targetValue,
    this.currentProgress = 0,
    required this.rewardPoints,
    required this.rewardCoins,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.completedAt,
    this.hints = const [],
    this.progressDescription = '',
  });

  Challenge copyWith({
    int? currentProgress,
    bool? isCompleted,
    DateTime? completedAt,
    String? progressDescription,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      frequency: frequency,
      icon: icon,
      color: color,
      targetValue: targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardPoints: rewardPoints,
      rewardCoins: rewardCoins,
      startDate: startDate,
      endDate: endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      hints: hints,
      progressDescription: progressDescription ?? this.progressDescription,
    );
  }

  double get progressPercentage {
    if (targetValue == 0) return 1.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  
  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return endDate.difference(DateTime.now());
  }

  String get difficultyText {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'progressDescription': progressDescription,
    };
  }

  static Challenge fromJsonWithTemplate(Map<String, dynamic> json, Challenge template) {
    return template.copyWith(
      currentProgress: json['currentProgress'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      progressDescription: json['progressDescription'] ?? '',
    );
  }
}

class ChallengeTemplate {
  static List<Challenge> getDailyChallenges(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    
    return [
      // Scanning Challenges
      Challenge(
        id: 'daily_scan_3_items_${date.day}',
        title: 'Eco Explorer',
        description: 'Scan and identify 3 different items today',
        type: ChallengeType.scanning,
        difficulty: ChallengeDifficulty.easy,
        frequency: ChallengeFrequency.daily,
        icon: Icons.search,
        color: Colors.blue,
        targetValue: 3,
        rewardPoints: 50,
        rewardCoins: 10,
        startDate: startOfDay,
        endDate: endOfDay,
        hints: [
          'Look around your house for recyclable items',
          'Check your kitchen for food packaging',
          'Don\'t forget about bathroom items!'
        ],
      ),
      
      Challenge(
        id: 'daily_accuracy_streak_${date.day}',
        title: 'Sharp Eye',
        description: 'Get 5 high-confidence scans (>85%) in a row',
        type: ChallengeType.scanning,
        difficulty: ChallengeDifficulty.medium,
        frequency: ChallengeFrequency.daily,
        icon: Icons.visibility,
        color: Colors.purple,
        targetValue: 5,
        rewardPoints: 75,
        rewardCoins: 15,
        startDate: startOfDay,
        endDate: endOfDay,
        hints: [
          'Make sure items are well-lit',
          'Hold the camera steady',
          'Try scanning familiar items first'
        ],
      ),

      // Pet Care Challenges
      Challenge(
        id: 'daily_pet_care_${date.day}',
        title: 'Pet Parent',
        description: 'Feed your EcoBuddy and keep happiness above 80%',
        type: ChallengeType.petCare,
        difficulty: ChallengeDifficulty.easy,
        frequency: ChallengeFrequency.daily,
        icon: Icons.pets,
        color: Colors.pink,
        targetValue: 1,
        rewardPoints: 30,
        rewardCoins: 8,
        startDate: startOfDay,
        endDate: endOfDay,
        hints: [
          'Feed your pet when the happiness drops',
          'Regular care keeps your pet happy',
          'Happy pets give better rewards!'
        ],
      ),

      // Learning Challenges
      Challenge(
        id: 'daily_learn_disposal_${date.day}',
        title: 'Knowledge Seeker',
        description: 'Read disposal methods for 5 different items',
        type: ChallengeType.learning,
        difficulty: ChallengeDifficulty.easy,
        frequency: ChallengeFrequency.daily,
        icon: Icons.school,
        color: Colors.orange,
        targetValue: 5,
        rewardPoints: 40,
        rewardCoins: 12,
        startDate: startOfDay,
        endDate: endOfDay,
        hints: [
          'Tap on scan results to learn more',
          'Each item has disposal instructions',
          'Learning helps the environment!'
        ],
      ),

      // Environmental Challenges
      Challenge(
        id: 'daily_recyclable_focus_${date.day}',
        title: 'Recycling Champion',
        description: 'Scan 3 recyclable items (plastic, glass, metal, paper)',
        type: ChallengeType.environmental,
        difficulty: ChallengeDifficulty.medium,
        frequency: ChallengeFrequency.daily,
        icon: Icons.recycling,
        color: Colors.green,
        targetValue: 3,
        rewardPoints: 60,
        rewardCoins: 18,
        startDate: startOfDay,
        endDate: endOfDay,
        hints: [
          'Look for bottles, cans, and paper',
          'Check recycling symbols on packaging',
          'Clean containers work best for scanning'
        ],
      ),
    ];
  }

  static List<Challenge> getWeeklyChallenges(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
    
    return [
      Challenge(
        id: 'weekly_consistency_${weekStart.day}',
        title: 'Weekly Warrior',
        description: 'Use the app every day this week',
        type: ChallengeType.streak,
        difficulty: ChallengeDifficulty.hard,
        frequency: ChallengeFrequency.weekly,
        icon: Icons.calendar_view_week,
        color: Colors.indigo,
        targetValue: 7,
        rewardPoints: 200,
        rewardCoins: 50,
        startDate: weekStart,
        endDate: weekEnd,
        hints: [
          'Just open the app once per day',
          'Scan at least one item daily',
          'Don\'t forget to feed your pet!'
        ],
      ),

      Challenge(
        id: 'weekly_diversity_${weekStart.day}',
        title: 'Category Master',
        description: 'Scan items from all 7 waste categories',
        type: ChallengeType.scanning,
        difficulty: ChallengeDifficulty.hard,
        frequency: ChallengeFrequency.weekly,
        icon: Icons.category,
        color: Colors.teal,
        targetValue: 7,
        rewardPoints: 150,
        rewardCoins: 40,
        startDate: weekStart,
        endDate: weekEnd,
        hints: [
          'Explore different rooms in your house',
          'Look for: plastic, glass, metal, paper, organic, electronic, textile',
          'Each category counts only once'
        ],
      ),

      Challenge(
        id: 'weekly_pet_master_${weekStart.day}',
        title: 'Pet Master',
        description: 'Keep your pet happy (>70%) for the entire week',
        type: ChallengeType.petCare,
        difficulty: ChallengeDifficulty.medium,
        frequency: ChallengeFrequency.weekly,
        icon: Icons.favorite,
        color: Colors.red,
        targetValue: 7,
        rewardPoints: 120,
        rewardCoins: 35,
        startDate: weekStart,
        endDate: weekEnd,
        hints: [
          'Feed your pet regularly',
          'Don\'t let happiness drop below 70%',
          'Consistent care is key!'
        ],
      ),
    ];
  }

  static List<Challenge> getSpecialChallenges() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return [
      Challenge(
        id: 'special_weekend_warrior',
        title: 'Weekend Eco Warrior',
        description: 'Complete 10 scans during the weekend',
        type: ChallengeType.special,
        difficulty: ChallengeDifficulty.medium,
        frequency: ChallengeFrequency.special,
        icon: Icons.weekend,
        color: Colors.amber,
        targetValue: 10,
        rewardPoints: 100,
        rewardCoins: 25,
        startDate: startOfWeek.add(const Duration(days: 5)), // Saturday
        endDate: endOfWeek,
        hints: [
          'Weekend is perfect for exploring',
          'Clean out old items from storage',
          'Involve family members!'
        ],
      ),

      Challenge(
        id: 'special_perfect_accuracy',
        title: 'Perfectionist',
        description: 'Get 10 scans with 95%+ accuracy',
        type: ChallengeType.special,
        difficulty: ChallengeDifficulty.hard,
        frequency: ChallengeFrequency.special,
        icon: Icons.star,
        color: Colors.amber[700]!,
        targetValue: 10,
        rewardPoints: 300,
        rewardCoins: 75,
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        hints: [
          'Use good lighting',
          'Keep camera steady',
          'Choose clear, recognizable items'
        ],
      ),
    ];
  }
}

class ChallengeReward {
  final int points;
  final int coins;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const ChallengeReward({
    required this.points,
    required this.coins,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  static ChallengeReward getCompletionReward(Challenge challenge) {
    return ChallengeReward(
      points: challenge.rewardPoints,
      coins: challenge.rewardCoins,
      title: 'Challenge Complete!',
      description: '${challenge.title} finished successfully',
      icon: Icons.emoji_events,
      color: challenge.color,
    );
  }
}