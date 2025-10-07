import '../models/trash_item.dart';

class ScanHistoryItem {
  final String id;
  final String imagePath;
  final TrashItem? identifiedTrash;
  final double confidence;
  final DateTime scanDate;
  final List<String> labels;
  final String location; // Optional location where scan happened
  final bool wasCorrect; // Whether user confirmed the identification was correct
  final String? userFeedback; // Optional user feedback/correction

  const ScanHistoryItem({
    required this.id,
    required this.imagePath,
    this.identifiedTrash,
    required this.confidence,
    required this.scanDate,
    required this.labels,
    this.location = '',
    this.wasCorrect = true,
    this.userFeedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'identifiedTrash': identifiedTrash != null ? {
        'name': identifiedTrash!.name,
        'category': identifiedTrash!.category.index,
        'disposalMethod': identifiedTrash!.disposalMethod,
        'environmentalImpact': identifiedTrash!.environmentalImpact,
        'funFact': identifiedTrash!.funFact,
        'recyclingPoints': identifiedTrash!.recyclingPoints,
        'isRecyclable': identifiedTrash!.isRecyclable,
      } : null,
      'confidence': confidence,
      'scanDate': scanDate.toIso8601String(),
      'labels': labels,
      'location': location,
      'wasCorrect': wasCorrect,
      'userFeedback': userFeedback,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    TrashItem? identifiedTrash;
    if (json['identifiedTrash'] != null) {
      final trashData = json['identifiedTrash'] as Map<String, dynamic>;
      identifiedTrash = TrashItem(
        name: trashData['name'],
        category: TrashCategory.values[trashData['category']],
        disposalMethod: trashData['disposalMethod'],
        environmentalImpact: trashData['environmentalImpact'],
        funFact: trashData['funFact'],
        recyclingPoints: trashData['recyclingPoints'],
        isRecyclable: trashData['isRecyclable'],
      );
    }

    return ScanHistoryItem(
      id: json['id'],
      imagePath: json['imagePath'],
      identifiedTrash: identifiedTrash,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      scanDate: DateTime.parse(json['scanDate']),
      labels: List<String>.from(json['labels'] ?? []),
      location: json['location'] ?? '',
      wasCorrect: json['wasCorrect'] ?? true,
      userFeedback: json['userFeedback'],
    );
  }

  ScanHistoryItem copyWith({
    String? id,
    String? imagePath,
    TrashItem? identifiedTrash,
    double? confidence,
    DateTime? scanDate,
    List<String>? labels,
    String? location,
    bool? wasCorrect,
    String? userFeedback,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      identifiedTrash: identifiedTrash ?? this.identifiedTrash,
      confidence: confidence ?? this.confidence,
      scanDate: scanDate ?? this.scanDate,
      labels: labels ?? this.labels,
      location: location ?? this.location,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  String get categoryName {
    if (identifiedTrash == null) return 'Unknown';
    switch (identifiedTrash!.category) {
      case TrashCategory.plastic:
        return 'Plastic';
      case TrashCategory.glass:
        return 'Glass';
      case TrashCategory.metal:
        return 'Metal';
      case TrashCategory.paper:
        return 'Paper';
      case TrashCategory.organic:
        return 'Organic';
      case TrashCategory.electronic:
        return 'Electronic';
      case TrashCategory.hazardous:
        return 'Hazardous';
      case TrashCategory.textile:
        return 'Textile';
      case TrashCategory.unknown:
        return 'Unknown';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(scanDate);

    if (difference.inDays == 0) {
      // Today
      final hour = scanDate.hour.toString().padLeft(2, '0');
      final minute = scanDate.minute.toString().padLeft(2, '0');
      return 'Today at $hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final month = scanDate.month.toString().padLeft(2, '0');
      final day = scanDate.day.toString().padLeft(2, '0');
      return '$month/$day/${scanDate.year}';
    }
  }

  String get confidencePercentage => '${(confidence * 100).round()}%';
}

class ScanStatistics {
  final int totalScans;
  final int successfulScans;
  final int todayScans;
  final int weekScans;
  final int monthScans;
  final Map<TrashCategory, int> categoryBreakdown;
  final double averageConfidence;
  final int streak; // Days with at least one scan

  const ScanStatistics({
    required this.totalScans,
    required this.successfulScans,
    required this.todayScans,
    required this.weekScans,
    required this.monthScans,
    required this.categoryBreakdown,
    required this.averageConfidence,
    required this.streak,
  });

  double get successRate => totalScans > 0 ? successfulScans / totalScans : 0.0;
  String get successRatePercentage => '${(successRate * 100).round()}%';
}
