import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import '../models/trash_item.dart';

class ChallengeService extends ChangeNotifier {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  final List<Challenge> _activeChallenges = [];
  final List<Challenge> _completedChallenges = [];
  int _totalCoins = 0;
  int _dailyStreak = 0;
  DateTime? _lastActiveDate;
  Map<String, int> _dailyStats = {};
  Map<String, int> _weeklyStats = {};
  List<String> _recentCompletions = [];

  // Getters
  List<Challenge> get activeChallenges => _activeChallenges;
  List<Challenge> get completedChallenges => _completedChallenges;
  List<Challenge> get dailyChallenges => _activeChallenges
      .where((c) => c.frequency == ChallengeFrequency.daily && c.isActive)
      .toList();
  List<Challenge> get weeklyChallenges => _activeChallenges
      .where((c) => c.frequency == ChallengeFrequency.weekly && c.isActive)
      .toList();
  List<Challenge> get specialChallenges => _activeChallenges
      .where((c) => c.frequency == ChallengeFrequency.special && c.isActive)
      .toList();
  
  int get totalCoins => _totalCoins;
  int get dailyStreak => _dailyStreak;
  List<String> get recentCompletions => _recentCompletions;
  
  int get activeChallengeCount => _activeChallenges
      .where((c) => c.isActive && !c.isCompleted)
      .length;
  
  int get completedTodayCount => _activeChallenges
      .where((c) => c.isCompleted && 
             c.completedAt != null && 
             _isToday(c.completedAt!))
      .length;

  Future<void> initialize() async {
    debugPrint('Initializing Challenge Service...');
    await _loadChallengeData();
    await _generateDailyChallenges();
    await _generateWeeklyChallenges();
    await _generateSpecialChallenges();
    await _updateDailyStreak();
    debugPrint('Challenge Service initialized with ${_activeChallenges.length} active challenges');
  }

  // Challenge generation
  Future<void> _generateDailyChallenges() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Check if we already have today's challenges
    final hasCurrentChallenges = _activeChallenges.any((c) => 
        c.frequency == ChallengeFrequency.daily && 
        c.startDate.day == today.day &&
        c.startDate.month == today.month &&
        c.startDate.year == today.year);
    
    if (!hasCurrentChallenges) {
      debugPrint('Generating new daily challenges for $todayKey');
      
      // Remove expired daily challenges
      _activeChallenges.removeWhere((c) => 
          c.frequency == ChallengeFrequency.daily && c.isExpired);
      
      // Generate new challenges
      final newDailyChallenges = ChallengeTemplate.getDailyChallenges(today);
      
      // Randomly select 2-3 challenges for variety
      final selectedChallenges = _selectRandomChallenges(newDailyChallenges, 3);
      _activeChallenges.addAll(selectedChallenges);
      
      await _saveChallengeData();
    }
  }

  Future<void> _generateWeeklyChallenges() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Check if we have current week's challenges
    final hasCurrentWeeklyChallenges = _activeChallenges.any((c) => 
        c.frequency == ChallengeFrequency.weekly && !c.isExpired);
    
    if (!hasCurrentWeeklyChallenges) {
      debugPrint('Generating new weekly challenges');
      
      // Remove expired weekly challenges
      _activeChallenges.removeWhere((c) => 
          c.frequency == ChallengeFrequency.weekly && c.isExpired);
      
      // Generate new weekly challenges
      final newWeeklyChallenges = ChallengeTemplate.getWeeklyChallenges(weekStart);
      
      // Select 1-2 weekly challenges
      final selectedChallenges = _selectRandomChallenges(newWeeklyChallenges, 2);
      _activeChallenges.addAll(selectedChallenges);
      
      await _saveChallengeData();
    }
  }

  Future<void> _generateSpecialChallenges() async {
    final hasActiveSpecial = _activeChallenges.any((c) => 
        c.frequency == ChallengeFrequency.special && c.isActive);
    
    if (!hasActiveSpecial && Random().nextDouble() < 0.3) { // 30% chance
      debugPrint('Generating special challenge');
      
      final specialChallenges = ChallengeTemplate.getSpecialChallenges();
      if (specialChallenges.isNotEmpty) {
        final selectedChallenge = specialChallenges[Random().nextInt(specialChallenges.length)];
        _activeChallenges.add(selectedChallenge);
        await _saveChallengeData();
      }
    }
  }

  List<Challenge> _selectRandomChallenges(List<Challenge> challenges, int maxCount) {
    if (challenges.length <= maxCount) return challenges;
    
    final shuffled = List<Challenge>.from(challenges)..shuffle();
    return shuffled.take(maxCount).toList();
  }

  // Progress tracking
  Future<void> recordScanProgress({
    required String itemName,
    required TrashCategory category,
    required double confidence,
    bool readDisposal = false,
  }) async {
    debugPrint('Recording scan progress: $itemName, confidence: ${confidence.toStringAsFixed(2)}');
    
    final today = _getTodayKey();
    _dailyStats[today] = (_dailyStats[today] ?? 0) + 1;
    
    for (final challenge in _activeChallenges.where((c) => !c.isCompleted && c.isActive)) {
      bool progressMade = false;
      
      switch (challenge.type) {
        case ChallengeType.scanning:
          if (challenge.id.contains('scan_3_items')) {
            progressMade = await _updateChallengeProgress(challenge, 1);
          } else if (challenge.id.contains('accuracy_streak') && confidence >= 0.85) {
            progressMade = await _updateChallengeProgress(challenge, 1);
          } else if (challenge.id.contains('diversity') && !challenge.progressDescription.contains(category.name)) {
            progressMade = await _updateChallengeProgress(challenge, 1, '${challenge.progressDescription},${category.name}');
          }
          break;
          
        case ChallengeType.environmental:
          if (challenge.id.contains('recyclable_focus') && _isRecyclable(category)) {
            progressMade = await _updateChallengeProgress(challenge, 1);
          }
          break;
          
        case ChallengeType.learning:
          if (challenge.id.contains('learn_disposal') && readDisposal) {
            progressMade = await _updateChallengeProgress(challenge, 1);
          }
          break;
          
        case ChallengeType.special:
          if (challenge.id.contains('weekend_warrior') && _isWeekend()) {
            progressMade = await _updateChallengeProgress(challenge, 1);
          } else if (challenge.id.contains('perfect_accuracy') && confidence >= 0.95) {
            progressMade = await _updateChallengeProgress(challenge, 1);
          }
          break;
          
        default:
          break;
      }
      
      if (progressMade) {
        debugPrint('Progress made on challenge: ${challenge.title}');
      }
    }
    
    await _saveChallengeData();
    notifyListeners();
  }

  Future<void> recordPetCareProgress() async {
    debugPrint('Recording pet care progress');
    
    for (final challenge in _activeChallenges.where((c) => 
        !c.isCompleted && c.isActive && c.type == ChallengeType.petCare)) {
      
      if (challenge.id.contains('daily_pet_care')) {
        await _updateChallengeProgress(challenge, 1);
      } else if (challenge.id.contains('weekly_pet_master')) {
        // This will be updated by a separate happiness check
      }
    }
    
    await _saveChallengeData();
    notifyListeners();
  }

  Future<void> recordDailyUsage() async {
    final today = DateTime.now();
    _lastActiveDate = today;
    
    // Update daily usage challenges
    for (final challenge in _activeChallenges.where((c) => 
        !c.isCompleted && c.isActive && c.type == ChallengeType.streak)) {
      
      if (challenge.id.contains('weekly_consistency')) {
        await _updateChallengeProgress(challenge, 1);
      }
    }
    
    await _updateDailyStreak();
    await _saveChallengeData();
    notifyListeners();
  }

  Future<bool> _updateChallengeProgress(Challenge challenge, int increment, [String? newDescription]) async {
    final newProgress = challenge.currentProgress + increment;
    final isNowCompleted = newProgress >= challenge.targetValue;
    
    final updatedChallenge = challenge.copyWith(
      currentProgress: newProgress,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
      progressDescription: newDescription ?? challenge.progressDescription,
    );
    
    // Replace in active challenges list
    final index = _activeChallenges.indexWhere((c) => c.id == challenge.id);
    if (index != -1) {
      _activeChallenges[index] = updatedChallenge;
    }
    
    if (isNowCompleted && !challenge.isCompleted) {
      await _completeChallenge(updatedChallenge);
      return true;
    }
    
    return newProgress > challenge.currentProgress;
  }

  Future<void> _completeChallenge(Challenge challenge) async {
    debugPrint('🎉 Challenge completed: ${challenge.title} (+${challenge.rewardPoints} points, +${challenge.rewardCoins} coins)');
    
    _completedChallenges.add(challenge);
    _totalCoins += challenge.rewardCoins;
    _recentCompletions.insert(0, challenge.title);
    
    // Keep only last 5 recent completions
    if (_recentCompletions.length > 5) {
      _recentCompletions.removeLast();
    }
    
    // TODO: Integrate with achievement service for bonus points
  }

  // Helper methods
  bool _isRecyclable(TrashCategory category) {
    return [
      TrashCategory.plastic,
      TrashCategory.glass,
      TrashCategory.metal,
      TrashCategory.paper,
    ].contains(category);
  }

  bool _isWeekend() {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _getTodayKey() {
    final today = DateTime.now();
    return '${today.year}-${today.month}-${today.day}';
  }

  Future<void> _updateDailyStreak() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (_lastActiveDate == null) {
      _dailyStreak = 1;
    } else if (_isToday(_lastActiveDate!)) {
      // Already counted today
      return;
    } else if (_lastActiveDate!.year == yesterday.year &&
               _lastActiveDate!.month == yesterday.month &&
               _lastActiveDate!.day == yesterday.day) {
      _dailyStreak++;
    } else {
      _dailyStreak = 1; // Reset streak
    }
    
    _lastActiveDate = now;
  }

  // Challenge management
  Future<void> refreshChallenges() async {
    await _generateDailyChallenges();
    await _generateWeeklyChallenges();
    await _generateSpecialChallenges();
    notifyListeners();
  }

  Challenge? getChallengeById(String id) {
    return _activeChallenges.firstWhere(
      (c) => c.id == id,
      orElse: () => _completedChallenges.firstWhere(
        (c) => c.id == id,
        orElse: () => throw StateError('Challenge not found: $id'),
      ),
    );
  }

  List<Challenge> getChallengesByType(ChallengeType type) {
    return _activeChallenges.where((c) => c.type == type && c.isActive).toList();
  }

  // Persistence
  Future<void> _saveChallengeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final data = {
        'activeChallenges': _activeChallenges.map((c) => {
          'template': {
            'id': c.id,
            'title': c.title,
            'description': c.description,
            'type': c.type.name,
            'difficulty': c.difficulty.name,
            'frequency': c.frequency.name,
            'targetValue': c.targetValue,
            'rewardPoints': c.rewardPoints,
            'rewardCoins': c.rewardCoins,
            'startDate': c.startDate.toIso8601String(),
            'endDate': c.endDate.toIso8601String(),
            'hints': c.hints,
          },
          'progress': c.toJson(),
        }).toList(),
        'completedChallenges': _completedChallenges.map((c) => c.toJson()).toList(),
        'totalCoins': _totalCoins,
        'dailyStreak': _dailyStreak,
        'lastActiveDate': _lastActiveDate?.toIso8601String(),
        'dailyStats': _dailyStats,
        'weeklyStats': _weeklyStats,
        'recentCompletions': _recentCompletions,
      };
      
      await prefs.setString('challenge_data', jsonEncode(data));
      debugPrint('Challenge data saved');
    } catch (e) {
      debugPrint('Error saving challenge data: $e');
    }
  }

  Future<void> _loadChallengeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('challenge_data');
      
      if (dataString == null) {
        debugPrint('No saved challenge data found');
        return;
      }
      
      final data = jsonDecode(dataString) as Map<String, dynamic>;
      
      // Load active challenges (simplified loading for now)
      _totalCoins = data['totalCoins'] ?? 0;
      _dailyStreak = data['dailyStreak'] ?? 0;
      _lastActiveDate = data['lastActiveDate'] != null 
          ? DateTime.parse(data['lastActiveDate'])
          : null;
      
      _dailyStats = Map<String, int>.from(data['dailyStats'] ?? {});
      _weeklyStats = Map<String, int>.from(data['weeklyStats'] ?? {});
      _recentCompletions = List<String>.from(data['recentCompletions'] ?? []);
      
      debugPrint('Challenge data loaded successfully');
    } catch (e) {
      debugPrint('Error loading challenge data: $e');
    }
  }

  // Reset for testing
  Future<void> resetChallenges() async {
    _activeChallenges.clear();
    _completedChallenges.clear();
    _totalCoins = 0;
    _dailyStreak = 0;
    _lastActiveDate = null;
    _dailyStats.clear();
    _weeklyStats.clear();
    _recentCompletions.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('challenge_data');
    
    await initialize();
    notifyListeners();
  }
}