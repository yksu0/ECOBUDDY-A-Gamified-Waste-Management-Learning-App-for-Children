import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/trash_item.dart';

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final Map<AchievementType, Achievement> _achievements = {};
  final List<Achievement> _recentlyUnlocked = [];
  int _totalPoints = 0;
  int _currentStreak = 0;
  DateTime? _lastUsageDate;
  Map<String, int> _scanStatistics = {};
  Map<TrashCategory, int> _categoryScans = {};
  int _consecutiveHighAccuracy = 0;
  int _petCareStreak = 0;
  DateTime? _lastPetCareDate;
  int _totalRecyclingPoints = 0;
  Set<String> _readFunFacts = {};
  Set<String> _viewedDisposalInstructions = {};

  // Getters
  List<Achievement> get allAchievements => _achievements.values.toList();
  List<Achievement> get unlockedAchievements => 
      _achievements.values.where((a) => a.isUnlocked).toList();
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;
  int get totalPoints => _totalPoints;
  int get currentStreak => _currentStreak;
  Map<String, int> get scanStatistics => Map.unmodifiable(_scanStatistics);
  double get overallProgress {
    if (_achievements.isEmpty) return 0.0;
    return unlockedAchievements.length / _achievements.length;
  }

  Future<void> initialize() async {
    debugPrint('Initializing Achievement Service...');
    
    // Load template achievements
    for (final achievement in AchievementDatabase.getAllAchievements()) {
      _achievements[achievement.type] = achievement;
    }
    
    await _loadProgress();
    await _checkEarlyAdopterAchievement();
    
    debugPrint('Achievement Service initialized with ${_achievements.length} achievements');
    debugPrint('Total points: $_totalPoints, Unlocked: ${unlockedAchievements.length}');
  }

  // Track scanning activities
  Future<void> recordScan({
    required String itemName,
    required TrashCategory category,
    required double confidence,
    required int recyclingPoints,
    bool readFunFact = false,
    bool viewedDisposal = false,
  }) async {
    debugPrint('Recording scan: $itemName, category: ${category.name}, confidence: ${confidence.toStringAsFixed(2)}');
    
    // Update scan statistics
    _scanStatistics[itemName] = (_scanStatistics[itemName] ?? 0) + 1;
    _categoryScans[category] = (_categoryScans[category] ?? 0) + 1;
    _totalRecyclingPoints += recyclingPoints;
    
    if (readFunFact) _readFunFacts.add(itemName);
    if (viewedDisposal) _viewedDisposalInstructions.add(itemName);
    
    // Track accuracy streak
    if (confidence >= 0.9) {
      _consecutiveHighAccuracy++;
    } else {
      _consecutiveHighAccuracy = 0;
    }
    
    // Check scanning achievements
    await _checkScanningAchievements();
    await _checkEnvironmentalAchievements();
    await _checkLearningAchievements();
    
    await _saveProgress();
    notifyListeners();
  }

  // Track pet care activities
  Future<void> recordPetCare() async {
    debugPrint('Recording pet care activity');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCareDay = _lastPetCareDate != null 
        ? DateTime(_lastPetCareDate!.year, _lastPetCareDate!.month, _lastPetCareDate!.day)
        : null;
    
    if (lastCareDay == null || today.difference(lastCareDay).inDays == 1) {
      _petCareStreak++;
    } else if (today != lastCareDay) {
      _petCareStreak = 1;
    }
    
    _lastPetCareDate = now;
    
    await _checkPetCareAchievements();
    await _saveProgress();
    notifyListeners();
  }

  // Track daily usage
  Future<void> recordDailyUsage() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastUsageDay = _lastUsageDate != null 
        ? DateTime(_lastUsageDate!.year, _lastUsageDate!.month, _lastUsageDate!.day)
        : null;
    
    if (lastUsageDay == null || today.difference(lastUsageDay).inDays == 1) {
      _currentStreak++;
    } else if (today != lastUsageDay) {
      _currentStreak = 1;
    }
    
    _lastUsageDate = now;
    
    await _checkStreakAchievements();
    await _saveProgress();
    notifyListeners();
  }

  // Achievement checking methods
  Future<void> _checkScanningAchievements() async {
    final totalScans = _scanStatistics.values.fold(0, (sum, count) => sum + count);
    final uniqueItems = _scanStatistics.length;
    
    await _checkAndUnlock(AchievementType.firstScan, 1, totalScans);
    await _checkAndUnlock(AchievementType.scan10Items, 10, uniqueItems);
    await _checkAndUnlock(AchievementType.scan50Items, 50, uniqueItems);
    await _checkAndUnlock(AchievementType.scan100Items, 100, uniqueItems);
    await _checkAndUnlock(AchievementType.perfectAccuracy, 10, _consecutiveHighAccuracy);
    await _checkAndUnlock(AchievementType.diverseScanning, 7, _categoryScans.length);
  }

  Future<void> _checkPetCareAchievements() async {
    await _checkAndUnlock(AchievementType.firstFeed, 1, _petCareStreak > 0 ? 1 : 0);
    await _checkAndUnlock(AchievementType.petCare7Days, 7, _petCareStreak);
    await _checkAndUnlock(AchievementType.petCare30Days, 30, _petCareStreak);
  }

  Future<void> _checkEnvironmentalAchievements() async {
    final recyclableScans = _categoryScans.entries
        .where((entry) => [TrashCategory.plastic, TrashCategory.glass, 
                          TrashCategory.metal, TrashCategory.paper].contains(entry.key))
        .fold(0, (sum, entry) => sum + entry.value);
    
    await _checkAndUnlock(AchievementType.recyclingChampion, 25, recyclableScans);
    await _checkAndUnlock(AchievementType.ecoWarrior, 50, _scanStatistics.length);
    await _checkAndUnlock(AchievementType.planetProtector, 1000, _totalRecyclingPoints);
  }

  Future<void> _checkLearningAchievements() async {
    await _checkAndUnlock(AchievementType.funFactReader, 20, _readFunFacts.length);
    await _checkAndUnlock(AchievementType.knowledgeSeeker, 30, _viewedDisposalInstructions.length);
    
    // Eco expert requires knowledge about all categories plus general knowledge
    final knowledgePoints = _categoryScans.length + (_readFunFacts.length >= 10 ? 1 : 0);
    await _checkAndUnlock(AchievementType.ecoExpert, 8, knowledgePoints);
  }

  Future<void> _checkStreakAchievements() async {
    await _checkAndUnlock(AchievementType.dailyUser, 3, _currentStreak);
    await _checkAndUnlock(AchievementType.weeklyChampion, 7, _currentStreak);
    await _checkAndUnlock(AchievementType.monthlyHero, 30, _currentStreak);
  }

  Future<void> _checkEarlyAdopterAchievement() async {
    await _checkAndUnlock(AchievementType.earlyAdopter, 1, 1);
  }

  // Core unlock mechanism
  Future<void> _checkAndUnlock(AchievementType type, int required, int current) async {
    final achievement = _achievements[type];
    if (achievement == null || achievement.isUnlocked) return;
    
    final updatedAchievement = achievement.copyWith(
      currentProgress: current,
      progressDescription: '$current / $required',
    );
    _achievements[type] = updatedAchievement;
    
    if (current >= required) {
      await _unlockAchievement(type);
    }
  }

  Future<void> _unlockAchievement(AchievementType type) async {
    final achievement = _achievements[type];
    if (achievement == null || achievement.isUnlocked) return;
    
    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      currentProgress: achievement.pointsRequired,
      progressDescription: 'Completed!',
    );
    
    _achievements[type] = unlockedAchievement;
    _recentlyUnlocked.add(unlockedAchievement);
    _totalPoints += unlockedAchievement.rewardPoints;
    
    debugPrint('🏆 Achievement unlocked: ${unlockedAchievement.title} (+${unlockedAchievement.rewardPoints} points)');
    
    // Keep only last 5 recently unlocked for UI purposes
    if (_recentlyUnlocked.length > 5) {
      _recentlyUnlocked.removeAt(0);
    }
  }

  // Clear recent notifications (called by UI after showing)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  // Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.values
        .where((achievement) => achievement.category == category)
        .toList()
        ..sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
  }

  // Progress tracking
  double getCategoryProgress(AchievementCategory category) {
    final categoryAchievements = getAchievementsByCategory(category);
    if (categoryAchievements.isEmpty) return 0.0;
    
    final unlockedCount = categoryAchievements.where((a) => a.isUnlocked).length;
    return unlockedCount / categoryAchievements.length;
  }

  // Persistence
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final achievementData = <String, dynamic>{};
      for (final entry in _achievements.entries) {
        achievementData[entry.key.name] = entry.value.toJson();
      }
      
      final data = {
        'achievements': achievementData,
        'totalPoints': _totalPoints,
        'currentStreak': _currentStreak,
        'lastUsageDate': _lastUsageDate?.toIso8601String(),
        'scanStatistics': _scanStatistics,
        'categoryScans': _categoryScans.map((k, v) => MapEntry(k.name, v)),
        'consecutiveHighAccuracy': _consecutiveHighAccuracy,
        'petCareStreak': _petCareStreak,
        'lastPetCareDate': _lastPetCareDate?.toIso8601String(),
        'totalRecyclingPoints': _totalRecyclingPoints,
        'readFunFacts': _readFunFacts.toList(),
        'viewedDisposalInstructions': _viewedDisposalInstructions.toList(),
      };
      
      await prefs.setString('achievement_progress', jsonEncode(data));
      debugPrint('Achievement progress saved');
    } catch (e) {
      debugPrint('Error saving achievement progress: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('achievement_progress');
      
      if (dataString == null) {
        debugPrint('No saved achievement progress found');
        return;
      }
      
      final data = jsonDecode(dataString) as Map<String, dynamic>;
      
      // Load achievement progress
      final achievementData = data['achievements'] as Map<String, dynamic>? ?? {};
      for (final entry in achievementData.entries) {
        final type = AchievementType.values.firstWhere(
          (t) => t.name == entry.key,
          orElse: () => AchievementType.firstScan, // fallback
        );
        final template = _achievements[type];
        if (template != null) {
          _achievements[type] = Achievement.fromJson(entry.value, template);
        }
      }
      
      // Load other progress data
      _totalPoints = data['totalPoints'] ?? 0;
      _currentStreak = data['currentStreak'] ?? 0;
      _lastUsageDate = data['lastUsageDate'] != null 
          ? DateTime.parse(data['lastUsageDate'])
          : null;
      
      _scanStatistics = Map<String, int>.from(data['scanStatistics'] ?? {});
      
      final categoryScansData = data['categoryScans'] as Map<String, dynamic>? ?? {};
      _categoryScans = {};
      for (final entry in categoryScansData.entries) {
        final category = TrashCategory.values.firstWhere(
          (c) => c.name == entry.key,
          orElse: () => TrashCategory.unknown,
        );
        _categoryScans[category] = entry.value;
      }
      
      _consecutiveHighAccuracy = data['consecutiveHighAccuracy'] ?? 0;
      _petCareStreak = data['petCareStreak'] ?? 0;
      _lastPetCareDate = data['lastPetCareDate'] != null 
          ? DateTime.parse(data['lastPetCareDate'])
          : null;
      _totalRecyclingPoints = data['totalRecyclingPoints'] ?? 0;
      
      _readFunFacts = Set<String>.from(data['readFunFacts'] ?? []);
      _viewedDisposalInstructions = Set<String>.from(data['viewedDisposalInstructions'] ?? []);
      
      debugPrint('Achievement progress loaded successfully');
    } catch (e) {
      debugPrint('Error loading achievement progress: $e');
    }
  }

  // Reset for testing
  Future<void> resetProgress() async {
    _achievements.clear();
    _recentlyUnlocked.clear();
    _totalPoints = 0;
    _currentStreak = 0;
    _lastUsageDate = null;
    _scanStatistics.clear();
    _categoryScans.clear();
    _consecutiveHighAccuracy = 0;
    _petCareStreak = 0;
    _lastPetCareDate = null;
    _totalRecyclingPoints = 0;
    _readFunFacts.clear();
    _viewedDisposalInstructions.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('achievement_progress');
    
    await initialize();
    notifyListeners();
  }
}