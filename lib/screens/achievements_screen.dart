import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<AchievementCategory> categories = [
    AchievementCategory.scanning,
    AchievementCategory.petCare,
    AchievementCategory.environmental,
    AchievementCategory.learning,
    AchievementCategory.streak,
    AchievementCategory.special,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: 'All', icon: Icon(Icons.emoji_events)),
            ...categories.map((category) => Tab(
              text: _getCategoryName(category),
              icon: Icon(_getCategoryIcon(category)),
            )),
          ],
        ),
      ),
      body: Consumer<AchievementService>(
        builder: (context, achievementService, child) {
          return Column(
            children: [
              _buildStatsHeader(achievementService),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllAchievements(achievementService),
                    ...categories.map((category) => 
                        _buildCategoryAchievements(achievementService, category)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(AchievementService service) {
    final unlockedCount = service.unlockedAchievements.length;
    final totalCount = service.allAchievements.length;
    final progressPercentage = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Points',
              service.totalPoints.toString(),
              Icons.stars,
              Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Unlocked',
              '$unlockedCount / $totalCount',
              Icons.lock_open,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Progress',
              '${(progressPercentage * 100).toInt()}%',
              Icons.trending_up,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAchievements(AchievementService service) {
    final achievements = service.allAchievements
        ..sort((a, b) {
          // Sort by unlocked status first, then by category and points
          if (a.isUnlocked != b.isUnlocked) {
            return a.isUnlocked ? -1 : 1;
          }
          final categoryCompare = a.category.name.compareTo(b.category.name);
          if (categoryCompare != 0) return categoryCompare;
          return a.pointsRequired.compareTo(b.pointsRequired);
        });

    return _buildAchievementList(achievements);
  }

  Widget _buildCategoryAchievements(AchievementService service, AchievementCategory category) {
    final achievements = service.getAchievementsByCategory(category);
    return _buildAchievementList(achievements);
  }

  Widget _buildAchievementList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text(
          'No achievements in this category yet!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progressPercentage = achievement.progressPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnlocked ? 6 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [achievement.color.withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isUnlocked
              ? Border.all(color: achievement.color.withOpacity(0.3), width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Achievement icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? achievement.color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isUnlocked ? achievement.color : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  achievement.icon,
                  color: isUnlocked ? achievement.color : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Achievement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                        if (isUnlocked) ...[
                          Icon(Icons.check_circle, color: achievement.color, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '+${achievement.rewardPoints}',
                            style: TextStyle(
                              color: achievement.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Colors.black54 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress bar
                    if (!isUnlocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            achievement.progressDescription.isNotEmpty
                                ? achievement.progressDescription
                                : '${achievement.currentProgress}/${achievement.pointsRequired}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.scanning:
        return 'Scanning';
      case AchievementCategory.petCare:
        return 'Pet Care';
      case AchievementCategory.environmental:
        return 'Environmental';
      case AchievementCategory.learning:
        return 'Learning';
      case AchievementCategory.streak:
        return 'Streaks';
      case AchievementCategory.special:
        return 'Special';
    }
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.scanning:
        return Icons.camera_alt;
      case AchievementCategory.petCare:
        return Icons.pets;
      case AchievementCategory.environmental:
        return Icons.eco;
      case AchievementCategory.learning:
        return Icons.school;
      case AchievementCategory.streak:
        return Icons.whatshot;
      case AchievementCategory.special:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}