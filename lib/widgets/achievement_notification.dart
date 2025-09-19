import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementNotificationWidget extends StatefulWidget {
  const AchievementNotificationWidget({super.key});

  @override
  State<AchievementNotificationWidget> createState() => _AchievementNotificationWidgetState();
}

class _AchievementNotificationWidgetState extends State<AchievementNotificationWidget>
    with TickerProviderStateMixin {
  
  List<AnimationController> _controllers = [];
  List<Animation<double>> _slideAnimations = [];
  List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewAchievements();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkForNewAchievements() {
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final recentlyUnlocked = achievementService.recentlyUnlocked;
    
    if (recentlyUnlocked.isNotEmpty) {
      _showAchievementNotifications(recentlyUnlocked);
      // Clear notifications after showing
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          achievementService.clearRecentlyUnlocked();
        }
      });
    }
  }

  void _showAchievementNotifications(List<Achievement> achievements) {
    // Clear previous controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _slideAnimations.clear();
    _fadeAnimations.clear();

    // Create new controllers and animations
    for (int i = 0; i < achievements.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      
      final slideAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
      
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ));

      _controllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);

      // Start animation with delay for each achievement
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          controller.forward();
          
          // Auto-hide after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              controller.reverse();
            }
          });
        }
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        // Check for new achievements when the widget rebuilds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkForNewAchievements();
        });

        final recentlyUnlocked = achievementService.recentlyUnlocked;
        
        if (recentlyUnlocked.isEmpty || _controllers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Column(
            children: List.generate(
              recentlyUnlocked.length.clamp(0, _controllers.length),
              (index) => AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _slideAnimations[index].value * -100,
                    ),
                    child: Opacity(
                      opacity: _fadeAnimations[index].value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: _buildAchievementCard(recentlyUnlocked[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              achievement.color.withOpacity(0.8),
              achievement.color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: achievement.color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Achievement icon with glow effect
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Achievement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Achievement Unlocked!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      color: achievement.color,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+${achievement.rewardPoints}',
                      style: TextStyle(
                        color: achievement.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementProgressWidget extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final Color color;
  final IconData icon;

  const AchievementProgressWidget({
    super.key,
    required this.title,
    required this.current,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$current/$total',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}