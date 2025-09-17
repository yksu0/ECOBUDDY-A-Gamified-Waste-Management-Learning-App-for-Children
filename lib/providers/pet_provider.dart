import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class PetProvider extends ChangeNotifier {
  Pet _pet = Pet.initial();
  bool _isLoading = false;

  Pet get pet => _pet;
  bool get isLoading => _isLoading;

  PetProvider() {
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved pet data or use defaults
      final name = prefs.getString('pet_name') ?? 'Bud';
      final happiness = prefs.getInt('pet_happiness') ?? 50;
      final xp = prefs.getInt('pet_xp') ?? 0;
      final level = prefs.getInt('pet_level') ?? 1;
      final evolutionStageIndex = prefs.getInt('pet_evolution_stage') ?? 0;
      final emotionalStateIndex = prefs.getInt('pet_emotional_state') ?? 5;
      
      final lastFedMs = prefs.getInt('pet_last_fed') ?? DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch;
      final lastPlayedMs = prefs.getInt('pet_last_played') ?? DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
      final lastCleanedMs = prefs.getInt('pet_last_cleaned') ?? DateTime.now().millisecondsSinceEpoch;

      _pet = Pet(
        name: name,
        happiness: happiness.clamp(0, 100),
        xp: xp,
        level: level,
        evolutionStage: PetEvolutionStage.values[evolutionStageIndex.clamp(0, PetEvolutionStage.values.length - 1)],
        emotionalState: PetEmotionalState.values[emotionalStateIndex.clamp(0, PetEmotionalState.values.length - 1)],
        lastFed: DateTime.fromMillisecondsSinceEpoch(lastFedMs),
        lastPlayed: DateTime.fromMillisecondsSinceEpoch(lastPlayedMs),
        lastCleaned: DateTime.fromMillisecondsSinceEpoch(lastCleanedMs),
      );

      // Update emotional state based on current conditions
      _updateEmotionalState();
    } catch (e) {
      debugPrint('Error loading pet data: $e');
      _pet = Pet.initial();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _savePetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('pet_name', _pet.name);
      await prefs.setInt('pet_happiness', _pet.happiness);
      await prefs.setInt('pet_xp', _pet.xp);
      await prefs.setInt('pet_level', _pet.level);
      await prefs.setInt('pet_evolution_stage', _pet.evolutionStage.index);
      await prefs.setInt('pet_emotional_state', _pet.emotionalState.index);
      await prefs.setInt('pet_last_fed', _pet.lastFed.millisecondsSinceEpoch);
      await prefs.setInt('pet_last_played', _pet.lastPlayed.millisecondsSinceEpoch);
      await prefs.setInt('pet_last_cleaned', _pet.lastCleaned.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving pet data: $e');
    }
  }

  void _updateEmotionalState() {
    final newEmotionalState = _pet.calculatedEmotionalState;
    final newEvolutionStage = _pet.calculatedEvolutionStage;
    
    _pet = _pet.copyWith(
      emotionalState: newEmotionalState,
      evolutionStage: newEvolutionStage,
    );
  }

  Future<void> feedPet() async {
    if (_pet.needsFeeding) {
      final happinessGain = 15;
      final xpGain = 10;
      
      _pet = _pet.copyWith(
        happiness: (_pet.happiness + happinessGain).clamp(0, 100),
        xp: _pet.xp + xpGain,
        level: _calculateNewLevel(_pet.xp + xpGain),
        lastFed: DateTime.now(),
      );
      
      _updateEmotionalState();
      notifyListeners();
      await _savePetData();
    }
  }

  Future<void> playWithPet() async {
    if (_pet.needsPlaying) {
      final happinessGain = 20;
      final xpGain = 15;
      
      _pet = _pet.copyWith(
        happiness: (_pet.happiness + happinessGain).clamp(0, 100),
        xp: _pet.xp + xpGain,
        level: _calculateNewLevel(_pet.xp + xpGain),
        lastPlayed: DateTime.now(),
      );
      
      _updateEmotionalState();
      notifyListeners();
      await _savePetData();
    }
  }

  Future<void> cleanPet() async {
    if (_pet.needsCleaning) {
      final happinessGain = 10;
      final xpGain = 5;
      
      _pet = _pet.copyWith(
        happiness: (_pet.happiness + happinessGain).clamp(0, 100),
        xp: _pet.xp + xpGain,
        level: _calculateNewLevel(_pet.xp + xpGain),
        lastCleaned: DateTime.now(),
      );
      
      _updateEmotionalState();
      notifyListeners();
      await _savePetData();
    }
  }

  Future<void> petThePet() async {
    // Always allows petting, gives small happiness boost
    final happinessGain = 5;
    final xpGain = 2;
    
    _pet = _pet.copyWith(
      happiness: (_pet.happiness + happinessGain).clamp(0, 100),
      xp: _pet.xp + xpGain,
      level: _calculateNewLevel(_pet.xp + xpGain),
    );
    
    _updateEmotionalState();
    notifyListeners();
    await _savePetData();
  }

  Future<void> scanTrash() async {
    // Called when user successfully scans trash
    final happinessGain = 25;
    final xpGain = 50;
    
    _pet = _pet.copyWith(
      happiness: (_pet.happiness + happinessGain).clamp(0, 100),
      xp: _pet.xp + xpGain,
      level: _calculateNewLevel(_pet.xp + xpGain),
    );
    
    _updateEmotionalState();
    notifyListeners();
    await _savePetData();
  }

  int _calculateNewLevel(int totalXp) {
    // Each level requires level * 100 XP
    int level = 1;
    int requiredXp = 0;
    
    while (totalXp >= requiredXp + (level * 100)) {
      requiredXp += level * 100;
      level++;
    }
    
    return level;
  }

  Future<void> updatePetName(String newName) async {
    _pet = _pet.copyWith(name: newName);
    notifyListeners();
    await _savePetData();
  }

  // Simulate passage of time (for testing or when app is reopened)
  Future<void> updatePetCondition() async {
    // Gradually decrease happiness over time if needs aren't met
    int happinessDecrease = 0;
    
    if (_pet.needsFeeding) happinessDecrease += 5;
    if (_pet.needsPlaying) happinessDecrease += 3;
    if (_pet.needsCleaning) happinessDecrease += 2;
    
    if (happinessDecrease > 0) {
      _pet = _pet.copyWith(
        happiness: (_pet.happiness - happinessDecrease).clamp(0, 100),
      );
      
      _updateEmotionalState();
      notifyListeners();
      await _savePetData();
    }
  }
}