enum PetEmotionalState {
  happy,
  sad,
  excited,
  sleepy,
  angry,
  neutral,
}

enum PetEvolutionStage {
  baby,
  child,
  adult,
}

class Pet {
  final String name;
  final int happiness;
  final int xp;
  final int level;
  final PetEvolutionStage evolutionStage;
  final PetEmotionalState emotionalState;
  final DateTime lastFed;
  final DateTime lastPlayed;
  final DateTime lastCleaned;

  const Pet({
    required this.name,
    required this.happiness,
    required this.xp,
    required this.level,
    required this.evolutionStage,
    required this.emotionalState,
    required this.lastFed,
    required this.lastPlayed,
    required this.lastCleaned,
  });

  factory Pet.initial() {
    return Pet(
      name: 'Bud',
      happiness: 50,
      xp: 0,
      level: 1,
      evolutionStage: PetEvolutionStage.baby,
      emotionalState: PetEmotionalState.neutral,
      lastFed: DateTime.now().subtract(const Duration(hours: 2)),
      lastPlayed: DateTime.now().subtract(const Duration(hours: 1)),
      lastCleaned: DateTime.now(),
    );
  }

  Pet copyWith({
    String? name,
    int? happiness,
    int? xp,
    int? level,
    PetEvolutionStage? evolutionStage,
    PetEmotionalState? emotionalState,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastCleaned,
  }) {
    return Pet(
      name: name ?? this.name,
      happiness: happiness ?? this.happiness,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      emotionalState: emotionalState ?? this.emotionalState,
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastCleaned: lastCleaned ?? this.lastCleaned,
    );
  }

  // Calculate if pet needs attention (shortened for testing)
  bool get needsFeeding => DateTime.now().difference(lastFed).inMinutes > 30; // 30 minutes
  bool get needsPlaying => DateTime.now().difference(lastPlayed).inMinutes > 45; // 45 minutes  
  bool get needsCleaning => DateTime.now().difference(lastCleaned).inMinutes > 60; // 1 hour

  // Calculate overall health
  double get healthPercentage => happiness / 100.0;

  // XP needed for next level
  int get xpForNextLevel => (level * 100);
  double get levelProgress => (xp % xpForNextLevel) / xpForNextLevel;

  // Evolution stage requirements
  PetEvolutionStage get calculatedEvolutionStage {
    if (level >= 20) return PetEvolutionStage.adult;
    if (level >= 10) return PetEvolutionStage.child;
    return PetEvolutionStage.baby;
  }

  // Auto-calculate emotional state based on needs
  PetEmotionalState get calculatedEmotionalState {
    if (happiness >= 80) return PetEmotionalState.happy;
    if (happiness <= 20) return PetEmotionalState.sad;
    if (needsFeeding && needsPlaying) return PetEmotionalState.angry;
    if (needsFeeding) return PetEmotionalState.sad;
    if (happiness >= 60) return PetEmotionalState.excited;
    return PetEmotionalState.neutral;
  }
}