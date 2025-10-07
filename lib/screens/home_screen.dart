import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../services/achievement_service.dart';
import '../services/challenge_service.dart';
import '../services/almanac_service.dart';
import '../widgets/simple_pet_widget.dart';
import '../widgets/achievement_notification.dart';
import '../models/pet.dart';
import 'achievements_screen.dart';
import 'challenges_screen.dart';
import 'almanac_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Update pet condition when app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().updatePetCondition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          'EcoBuddy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Consumer<AlmanacService>(
          builder: (context, almanacService, child) {
            final stats = almanacService.getLearningStats();
            
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_book, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AlmanacScreen(),
                      ),
                    );
                  },
                  tooltip: 'Waste Almanac (${stats['viewedItems']}/${stats['totalItems']} learned)',
                ),
                // Badge showing learning progress
                if (stats['viewedItems'] > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${stats['viewedItems']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          // Challenges button
          Consumer<ChallengeService>(
            builder: (context, challengeService, child) {
              final activeChallenges = challengeService.activeChallengeCount;
              final completedToday = challengeService.completedTodayCount;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.assignment, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChallengesScreen(),
                        ),
                      );
                    },
                    tooltip: 'Challenges ($completedToday completed today)',
                  ),
                  // Badge showing active challenges
                  if (activeChallenges > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: completedToday > 0 ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$activeChallenges',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Achievements button
          Consumer<AchievementService>(
            builder: (context, achievementService, child) {
              final unlockedCount = achievementService.unlockedAchievements.length;
              final totalCount = achievementService.allAchievements.length;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_events, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    tooltip: 'Achievements ($unlockedCount/$totalCount)',
                  ),
                  // Badge showing unlocked count
                  if (unlockedCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$unlockedCount',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final pet = petProvider.pet;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Pet Stats Card
                _buildStatsCard(pet),
                const SizedBox(height: 20),
                
                // Pet Display Area
                _buildPetArea(pet, petProvider),
                const SizedBox(height: 20),
                
                // Action Buttons
                _buildActionButtons(pet, petProvider),
                const SizedBox(height: 20),
                
                // Needs Indicators
                _buildNeedsIndicators(pet),
                const SizedBox(height: 20),
                
                // Achievement Progress Section
                _buildAchievementProgress(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(Pet pet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Level', pet.level.toString(), Icons.star),
                _buildStatItem('XP', pet.xp.toString(), Icons.trending_up),
                _buildStatItem('Happiness', '${pet.happiness}%', Icons.favorite),
              ],
            ),
            const SizedBox(height: 12),
            // XP Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress to Level ${pet.level + 1}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: pet.levelProgress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPetArea(Pet pet, PetProvider petProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade100,
            Colors.green.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Evolution Stage Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getEvolutionColor(pet.evolutionStage).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getEvolutionColor(pet.evolutionStage),
                width: 2,
              ),
            ),
            child: Text(
              _getEvolutionText(pet.evolutionStage),
              style: TextStyle(
                color: _getEvolutionColor(pet.evolutionStage),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Pet Widget
          SimplePetWidget(
            pet: pet,
            size: 250,
            onTap: () => petProvider.petThePet(),
          ),
          
          // Emotional State Indicator
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getEmotionColor(pet.emotionalState).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEmotionIcon(pet.emotionalState),
                  color: _getEmotionColor(pet.emotionalState),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _getEmotionText(pet.emotionalState),
                  style: TextStyle(
                    color: _getEmotionColor(pet.emotionalState),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Pet pet, PetProvider petProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.restaurant,
          label: 'Feed',
          color: Colors.orange,
          enabled: pet.needsFeeding,
          onPressed: () => petProvider.feedPet(),
        ),
        _buildActionButton(
          icon: Icons.sports_esports,
          label: 'Play',
          color: Colors.blue,
          enabled: pet.needsPlaying,
          onPressed: () => petProvider.playWithPet(),
        ),
        _buildActionButton(
          icon: Icons.cleaning_services,
          label: 'Clean',
          color: Colors.purple,
          enabled: pet.needsCleaning,
          onPressed: () => petProvider.cleanPet(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? color : Colors.grey.shade300,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: enabled ? 4 : 1,
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: enabled ? color : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNeedsIndicators(Pet pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pet Needs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildNeedIndicator(
              'Hunger',
              _getTimeSinceLastFed(pet),
              pet.needsFeeding,
              Icons.restaurant,
              Colors.orange,
            ),
            _buildNeedIndicator(
              'Energy',
              _getTimeSinceLastPlayed(pet),
              pet.needsPlaying,
              Icons.sports_esports,
              Colors.blue,
            ),
            _buildNeedIndicator(
              'Cleanliness',
              _getTimeSinceLastCleaned(pet),
              pet.needsCleaning,
              Icons.cleaning_services,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedIndicator(
    String label,
    String timeText,
    bool needsAttention,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: needsAttention ? color : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: needsAttention ? color : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (needsAttention)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Needed',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for UI
  Color _getEvolutionColor(PetEvolutionStage stage) {
    switch (stage) {
      case PetEvolutionStage.baby:
        return Colors.green.shade300;
      case PetEvolutionStage.child:
        return Colors.green.shade500;
      case PetEvolutionStage.adult:
        return Colors.green.shade700;
    }
  }

  String _getEvolutionText(PetEvolutionStage stage) {
    switch (stage) {
      case PetEvolutionStage.baby:
        return 'Baby Eco-Spirit';
      case PetEvolutionStage.child:
        return 'Young Guardian';
      case PetEvolutionStage.adult:
        return 'Eco Champion';
    }
  }

  Color _getEmotionColor(PetEmotionalState state) {
    switch (state) {
      case PetEmotionalState.happy:
      case PetEmotionalState.excited:
        return Colors.green;
      case PetEmotionalState.sad:
        return Colors.blue;
      case PetEmotionalState.angry:
        return Colors.red;
      case PetEmotionalState.sleepy:
        return Colors.purple;
      case PetEmotionalState.neutral:
        return Colors.grey;
    }
  }

  IconData _getEmotionIcon(PetEmotionalState state) {
    switch (state) {
      case PetEmotionalState.happy:
        return Icons.sentiment_very_satisfied;
      case PetEmotionalState.excited:
        return Icons.celebration;
      case PetEmotionalState.sad:
        return Icons.sentiment_very_dissatisfied;
      case PetEmotionalState.angry:
        return Icons.sentiment_dissatisfied;
      case PetEmotionalState.sleepy:
        return Icons.bedtime;
      case PetEmotionalState.neutral:
        return Icons.sentiment_neutral;
    }
  }

  String _getEmotionText(PetEmotionalState state) {
    switch (state) {
      case PetEmotionalState.happy:
        return 'Happy';
      case PetEmotionalState.excited:
        return 'Excited';
      case PetEmotionalState.sad:
        return 'Sad';
      case PetEmotionalState.angry:
        return 'Upset';
      case PetEmotionalState.sleepy:
        return 'Sleepy';
      case PetEmotionalState.neutral:
        return 'Content';
    }
  }

  String _getTimeSinceLastFed(Pet pet) {
    final duration = DateTime.now().difference(pet.lastFed);
    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inMinutes} minutes ago';
    }
  }

  String _getTimeSinceLastPlayed(Pet pet) {
    final duration = DateTime.now().difference(pet.lastPlayed);
    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inMinutes} minutes ago';
    }
  }

  String _getTimeSinceLastCleaned(Pet pet) {
    final duration = DateTime.now().difference(pet.lastCleaned);
    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inMinutes} minutes ago';
    }
  }

  Widget _buildAchievementProgress() {
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        final totalScans = achievementService.scanStatistics.values.fold(0, (sum, count) => sum + count);
        final unlockedCount = achievementService.unlockedAchievements.length;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Achievement Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AchievementsScreen(),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Total points and unlocked achievements
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressStat(
                        'Total Points',
                        achievementService.totalPoints.toString(),
                        Icons.stars,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressStat(
                        'Achievements',
                        '$unlockedCount / ${achievementService.allAchievements.length}',
                        Icons.lock_open,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress indicators
                if (totalScans < 10) ...[
                  AchievementProgressWidget(
                    title: 'Explorer Progress',
                    current: totalScans,
                    total: 10,
                    color: Colors.blue,
                    icon: Icons.search,
                  ),
                ] else if (achievementService.currentStreak < 7) ...[
                  AchievementProgressWidget(
                    title: 'Weekly Champion',
                    current: achievementService.currentStreak,
                    total: 7,
                    color: Colors.orange,
                    icon: Icons.whatshot,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}