import 'package:flutter/material.dart';
import 'trash_item.dart';

class AlmanacItem {
  final String id;
  final String name;
  final String description;
  final TrashCategory category;
  final List<String> aliases; // Alternative names users might know it by
  final String disposalMethod;
  final String recyclingInfo;
  final List<String> tips;
  final String funFact;
  final String imageAsset;
  final int difficultyLevel; // 1-5, how hard it is to identify
  final bool isCommon; // Is this a commonly found item?
  final List<String> whereToFind; // Where users typically encounter this
  final String environmentalImpact;
  final int decompositionTime; // In years, 0 = doesn't decompose naturally
  final bool isHazardous;
  final List<String> relatedItems;

  const AlmanacItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.aliases,
    required this.disposalMethod,
    required this.recyclingInfo,
    required this.tips,
    required this.funFact,
    required this.imageAsset,
    required this.difficultyLevel,
    required this.isCommon,
    required this.whereToFind,
    required this.environmentalImpact,
    required this.decompositionTime,
    required this.isHazardous,
    required this.relatedItems,
  });

  String get difficultyText {
    switch (difficultyLevel) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return 'Medium';
    }
  }

  Color get difficultyColor {
    switch (difficultyLevel) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get decompositionText {
    if (decompositionTime == 0) {
      return 'Does not decompose naturally';
    } else if (decompositionTime < 1) {
      return 'Less than 1 year';
    } else if (decompositionTime == 1) {
      return '1 year';
    } else if (decompositionTime < 100) {
      return '$decompositionTime years';
    } else if (decompositionTime < 1000) {
      return '$decompositionTime+ years';
    } else {
      return '1000+ years';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TrashCategory.plastic:
        return Icons.local_drink;
      case TrashCategory.paper:
        return Icons.description;
      case TrashCategory.glass:
        return Icons.wine_bar;
      case TrashCategory.metal:
        return Icons.build;
      case TrashCategory.organic:
        return Icons.eco;
      case TrashCategory.electronic:
        return Icons.computer;
      case TrashCategory.textile:
        return Icons.checkroom;
      case TrashCategory.hazardous:
        return Icons.warning;
      case TrashCategory.unknown:
        return Icons.help_outline;
    }
  }

  // Convert to TrashItem for compatibility with existing systems
  TrashItem toTrashItem() {
    return TrashItem(
      name: name,
      category: category,
      disposalMethod: disposalMethod,
      environmentalImpact: environmentalImpact,
      funFact: funFact,
      recyclingPoints: _calculateRecyclingPoints(),
      isRecyclable: recyclingInfo.isNotEmpty && !isHazardous,
    );
  }

  int _calculateRecyclingPoints() {
    int basePoints = 10;
    
    // More points for harder to identify items
    basePoints += (difficultyLevel - 1) * 5;
    
    // More points for less common items
    if (!isCommon) basePoints += 10;
    
    // More points for highly recyclable categories
    switch (category) {
      case TrashCategory.plastic:
      case TrashCategory.glass:
      case TrashCategory.metal:
      case TrashCategory.paper:
        basePoints += 15;
        break;
      case TrashCategory.electronic:
        basePoints += 25;
        break;
      case TrashCategory.hazardous:
        basePoints += 30;
        break;
      default:
        basePoints += 5;
    }
    
    return basePoints;
  }

  // Search functionality
  bool matchesSearch(String query) {
    final searchLower = query.toLowerCase();
    return name.toLowerCase().contains(searchLower) ||
           description.toLowerCase().contains(searchLower) ||
           aliases.any((alias) => alias.toLowerCase().contains(searchLower)) ||
           category.name.toLowerCase().contains(searchLower) ||
           whereToFind.any((place) => place.toLowerCase().contains(searchLower));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'aliases': aliases,
      'disposalMethod': disposalMethod,
      'recyclingInfo': recyclingInfo,
      'tips': tips,
      'funFact': funFact,
      'imageAsset': imageAsset,
      'difficultyLevel': difficultyLevel,
      'isCommon': isCommon,
      'whereToFind': whereToFind,
      'environmentalImpact': environmentalImpact,
      'decompositionTime': decompositionTime,
      'isHazardous': isHazardous,
      'relatedItems': relatedItems,
    };
  }

  factory AlmanacItem.fromJson(Map<String, dynamic> json) {
    return AlmanacItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: TrashCategory.values.firstWhere((e) => e.name == json['category']),
      aliases: List<String>.from(json['aliases']),
      disposalMethod: json['disposalMethod'],
      recyclingInfo: json['recyclingInfo'],
      tips: List<String>.from(json['tips']),
      funFact: json['funFact'],
      imageAsset: json['imageAsset'],
      difficultyLevel: json['difficultyLevel'],
      isCommon: json['isCommon'],
      whereToFind: List<String>.from(json['whereToFind']),
      environmentalImpact: json['environmentalImpact'],
      decompositionTime: json['decompositionTime'],
      isHazardous: json['isHazardous'],
      relatedItems: List<String>.from(json['relatedItems']),
    );
  }
}

class AlmanacCategory {
  final TrashCategory category;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final List<AlmanacItem> items;
  final List<String> generalTips;
  final String recyclingOverview;

  const AlmanacCategory({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
    required this.generalTips,
    required this.recyclingOverview,
  });

  int get itemCount => items.length;
  int get commonItemsCount => items.where((item) => item.isCommon).length;
  int get rareItemsCount => items.where((item) => !item.isCommon).length;
  
  List<AlmanacItem> get sortedItems => List<AlmanacItem>.from(items)
    ..sort((a, b) {
      // Sort by: common items first, then by difficulty, then alphabetically
      if (a.isCommon != b.isCommon) {
        return a.isCommon ? -1 : 1;
      }
      if (a.difficultyLevel != b.difficultyLevel) {
        return a.difficultyLevel.compareTo(b.difficultyLevel);
      }
      return a.name.compareTo(b.name);
    });
}

// Learning progress tracking
class AlmanacProgress {
  final Map<String, bool> viewedItems; // item ID -> viewed
  final Map<String, bool> scannedItems; // item ID -> successfully scanned
  final Map<TrashCategory, int> categoryProgress; // category -> items learned
  final DateTime lastUpdated;

  const AlmanacProgress({
    required this.viewedItems,
    required this.scannedItems,
    required this.categoryProgress,
    required this.lastUpdated,
  });

  int get totalViewed => viewedItems.values.where((viewed) => viewed).length;
  int get totalScanned => scannedItems.values.where((scanned) => scanned).length;
  
  double getProgressForCategory(TrashCategory category, List<AlmanacItem> categoryItems) {
    final viewedInCategory = categoryItems.where((item) => viewedItems[item.id] == true).length;
    return categoryItems.isEmpty ? 0.0 : viewedInCategory / categoryItems.length;
  }

  bool hasViewedItem(String itemId) => viewedItems[itemId] == true;
  bool hasScannedItem(String itemId) => scannedItems[itemId] == true;

  AlmanacProgress copyWith({
    Map<String, bool>? viewedItems,
    Map<String, bool>? scannedItems,
    Map<TrashCategory, int>? categoryProgress,
    DateTime? lastUpdated,
  }) {
    return AlmanacProgress(
      viewedItems: viewedItems ?? this.viewedItems,
      scannedItems: scannedItems ?? this.scannedItems,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewedItems': viewedItems,
      'scannedItems': scannedItems,
      'categoryProgress': categoryProgress.map((key, value) => MapEntry(key.name, value)),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AlmanacProgress.fromJson(Map<String, dynamic> json) {
    return AlmanacProgress(
      viewedItems: Map<String, bool>.from(json['viewedItems'] ?? {}),
      scannedItems: Map<String, bool>.from(json['scannedItems'] ?? {}),
      categoryProgress: (json['categoryProgress'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(
                TrashCategory.values.firstWhere((e) => e.name == key),
                value as int,
              )) ?? {},
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  static AlmanacProgress initial() {
    return AlmanacProgress(
      viewedItems: {},
      scannedItems: {},
      categoryProgress: {},
      lastUpdated: DateTime.now(),
    );
  }
}