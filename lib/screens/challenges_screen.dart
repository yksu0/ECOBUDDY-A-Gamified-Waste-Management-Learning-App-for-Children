import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/challenge_service.dart';
import '../models/challenge.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text(
          'Daily Challenges',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Daily'),
            Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
            Tab(icon: Icon(Icons.star), text: 'Special'),
          ],
        ),
      ),
      body: Consumer<ChallengeService>(
        builder: (context, challengeService, child) {
          return Column(
            children: [
              // Header Stats
              _buildHeaderStats(challengeService),
              
              // Tabs Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChallengeList(challengeService.dailyChallenges, 'daily'),
                    _buildChallengeList(challengeService.weeklyChallenges, 'weekly'),
                    _buildChallengeList(challengeService.specialChallenges, 'special'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final challengeService = Provider.of<ChallengeService>(context, listen: false);
          await challengeService.refreshChallenges();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Challenges refreshed!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  Widget _buildHeaderStats(ChallengeService challengeService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events,
              value: '${challengeService.activeChallengeCount}',
              label: 'Active',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle,
              value: '${challengeService.completedTodayCount}',
              label: 'Completed Today',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              value: '${challengeService.dailyStreak}',
              label: 'Day Streak',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.monetization_on,
              value: '${challengeService.totalCoins}',
              label: 'Coins',
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(List<Challenge> challenges, String type) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'daily' ? Icons.today :
              type == 'weekly' ? Icons.calendar_view_week : Icons.star,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type} challenges available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'daily' ? 'Check back tomorrow for new challenges!' :
              type == 'weekly' ? 'New weekly challenges coming soon!' :
              'Special challenges appear randomly!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChallengeCard(challenge),
        );
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final progress = challenge.currentProgress / challenge.targetValue;
    final isCompleted = challenge.isCompleted;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted 
              ? LinearGradient(
                  colors: [Colors.green[100]!, Colors.green[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getChallengeColor(challenge).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getChallengeIcon(challenge),
                      color: _getChallengeColor(challenge),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getDifficultyText(challenge.difficulty),
                          style: TextStyle(
                            color: _getDifficultyColor(challenge.difficulty),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                challenge.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${challenge.currentProgress}/${challenge.targetValue}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : _getChallengeColor(challenge),
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Rewards
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.rewardPoints} points',
                    style: TextStyle(
                      color: Colors.amber[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.monetization_on, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.rewardCoins} coins',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (!challenge.isExpired)
                    Text(
                      _getTimeRemaining(challenge),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              
              // Hints (if available)
              if (challenge.hints.isNotEmpty && !isCompleted) ...[
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text(
                    'Hints',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  children: challenge.hints.map((hint) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hint,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getChallengeColor(Challenge challenge) {
    switch (challenge.type) {
      case ChallengeType.scanning:
        return Colors.blue;
      case ChallengeType.petCare:
        return Colors.pink;
      case ChallengeType.learning:
        return Colors.purple;
      case ChallengeType.environmental:
        return Colors.green;
      case ChallengeType.streak:
        return Colors.orange;
      case ChallengeType.special:
        return Colors.amber;
    }
  }

  IconData _getChallengeIcon(Challenge challenge) {
    switch (challenge.type) {
      case ChallengeType.scanning:
        return Icons.camera_alt;
      case ChallengeType.petCare:
        return Icons.pets;
      case ChallengeType.learning:
        return Icons.school;
      case ChallengeType.environmental:
        return Icons.eco;
      case ChallengeType.streak:
        return Icons.local_fire_department;
      case ChallengeType.special:
        return Icons.star;
    }
  }

  String _getDifficultyText(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'EASY';
      case ChallengeDifficulty.medium:
        return 'MEDIUM';
      case ChallengeDifficulty.hard:
        return 'HARD';
    }
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
    }
  }

  String _getTimeRemaining(Challenge challenge) {
    final now = DateTime.now();
    final timeLeft = challenge.endDate.difference(now);
    
    if (timeLeft.isNegative) return 'Expired';
    
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays}d left';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h left';
    } else {
      return '${timeLeft.inMinutes}m left';
    }
  }
}