import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';
import '../models/trash_item.dart';

class ScanHistoryService extends ChangeNotifier {
  static final ScanHistoryService _instance = ScanHistoryService._internal();
  factory ScanHistoryService() => _instance;
  ScanHistoryService._internal();

  List<ScanHistoryItem> _scanHistory = [];
  bool _isInitialized = false;

  // Getters
  List<ScanHistoryItem> get scanHistory => List.unmodifiable(_scanHistory);
  bool get isInitialized => _isInitialized;
  
  // Get recent scans (last 20)
  List<ScanHistoryItem> get recentScans => _scanHistory.take(20).toList();
  
  // Get today's scans
  List<ScanHistoryItem> get todayScans {
    final today = DateTime.now();
    return _scanHistory.where((scan) {
      return scan.scanDate.year == today.year &&
             scan.scanDate.month == today.month &&
             scan.scanDate.day == today.day;
    }).toList();
  }

  // Get scans from this week
  List<ScanHistoryItem> get weekScans {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _scanHistory.where((scan) => scan.scanDate.isAfter(weekAgo)).toList();
  }

  // Get scans from this month
  List<ScanHistoryItem> get monthScans {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return _scanHistory.where((scan) => scan.scanDate.isAfter(monthAgo)).toList();
  }

  Future<void> initialize() async {
    debugPrint('Initializing Scan History Service...');
    await _loadHistory();
    _isInitialized = true;
    debugPrint('Scan History Service initialized with ${_scanHistory.length} scans');
    notifyListeners();
  }

  Future<void> addScanToHistory({
    required String imagePath,
    TrashItem? identifiedTrash,
    required double confidence,
    required List<String> labels,
    String location = '',
    bool wasCorrect = true,
    String? userFeedback,
  }) async {
    final scanId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final scanItem = ScanHistoryItem(
      id: scanId,
      imagePath: imagePath,
      identifiedTrash: identifiedTrash,
      confidence: confidence,
      scanDate: DateTime.now(),
      labels: labels,
      location: location,
      wasCorrect: wasCorrect,
      userFeedback: userFeedback,
    );

    // Add to beginning of list (most recent first)
    _scanHistory.insert(0, scanItem);
    
    // Keep only last 100 scans to prevent storage issues
    if (_scanHistory.length > 100) {
      final removedItems = _scanHistory.sublist(100);
      _scanHistory = _scanHistory.sublist(0, 100);
      
      // Clean up old image files
      for (final item in removedItems) {
        _cleanupImageFile(item.imagePath);
      }
    }

    await _saveHistory();
    notifyListeners();
    
    debugPrint('Added scan to history: ${identifiedTrash?.name ?? "Unknown item"}');
  }

  Future<void> updateScanFeedback(String scanId, bool wasCorrect, String? userFeedback) async {
    final index = _scanHistory.indexWhere((scan) => scan.id == scanId);
    if (index != -1) {
      _scanHistory[index] = _scanHistory[index].copyWith(
        wasCorrect: wasCorrect,
        userFeedback: userFeedback,
      );
      
      await _saveHistory();
      notifyListeners();
      
      debugPrint('Updated scan feedback for $scanId');
    }
  }

  Future<void> deleteScan(String scanId) async {
    final index = _scanHistory.indexWhere((scan) => scan.id == scanId);
    if (index != -1) {
      final removedScan = _scanHistory.removeAt(index);
      _cleanupImageFile(removedScan.imagePath);
      
      await _saveHistory();
      notifyListeners();
      
      debugPrint('Deleted scan: $scanId');
    }
  }

  Future<void> clearHistory() async {
    // Clean up all image files
    for (final scan in _scanHistory) {
      _cleanupImageFile(scan.imagePath);
    }
    
    _scanHistory.clear();
    await _saveHistory();
    notifyListeners();
    
    debugPrint('Cleared scan history');
  }

  ScanStatistics getStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final todayCount = _scanHistory.where((scan) {
      final scanDay = DateTime(scan.scanDate.year, scan.scanDate.month, scan.scanDate.day);
      return scanDay == today;
    }).length;

    final weekCount = _scanHistory.where((scan) => scan.scanDate.isAfter(weekAgo)).length;
    final monthCount = _scanHistory.where((scan) => scan.scanDate.isAfter(monthAgo)).length;

    final successfulScans = _scanHistory.where((scan) => scan.wasCorrect).length;

    // Category breakdown
    final categoryBreakdown = <TrashCategory, int>{};
    for (final category in TrashCategory.values) {
      categoryBreakdown[category] = _scanHistory
          .where((scan) => scan.identifiedTrash?.category == category)
          .length;
    }

    // Average confidence
    double averageConfidence = 0.0;
    if (_scanHistory.isNotEmpty) {
      final totalConfidence = _scanHistory.fold<double>(0.0, (sum, scan) => sum + scan.confidence);
      averageConfidence = totalConfidence / _scanHistory.length;
    }

    // Calculate streak
    int streak = _calculateStreak();

    return ScanStatistics(
      totalScans: _scanHistory.length,
      successfulScans: successfulScans,
      todayScans: todayCount,
      weekScans: weekCount,
      monthScans: monthCount,
      categoryBreakdown: categoryBreakdown,
      averageConfidence: averageConfidence,
      streak: streak,
    );
  }

  List<ScanHistoryItem> getScansForCategory(TrashCategory category) {
    return _scanHistory
        .where((scan) => scan.identifiedTrash?.category == category)
        .toList();
  }

  List<ScanHistoryItem> searchScans(String query) {
    final lowerQuery = query.toLowerCase();
    return _scanHistory.where((scan) {
      return scan.identifiedTrash?.name.toLowerCase().contains(lowerQuery) == true ||
             scan.labels.any((label) => label.toLowerCase().contains(lowerQuery)) ||
             scan.categoryName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  int _calculateStreak() {
    if (_scanHistory.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // Group scans by date
    final scansByDate = <DateTime, List<ScanHistoryItem>>{};
    for (final scan in _scanHistory) {
      final scanDate = DateTime(scan.scanDate.year, scan.scanDate.month, scan.scanDate.day);
      scansByDate[scanDate] = scansByDate[scanDate] ?? [];
      scansByDate[scanDate]!.add(scan);
    }

    // Check consecutive days
    DateTime checkDate = today;
    while (scansByDate.containsKey(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // If today has no scans but yesterday does, start from yesterday
    if (streak == 0 && scansByDate.containsKey(today.subtract(const Duration(days: 1)))) {
      checkDate = today.subtract(const Duration(days: 1));
      while (scansByDate.containsKey(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _scanHistory.map((scan) => scan.toJson()).toList();
      await prefs.setString('scan_history', jsonEncode(historyJson));
      debugPrint('Scan history saved');
    } catch (e) {
      debugPrint('Error saving scan history: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('scan_history');
      
      if (historyString != null) {
        final historyJson = jsonDecode(historyString) as List;
        _scanHistory = historyJson
            .map((json) => ScanHistoryItem.fromJson(json as Map<String, dynamic>))
            .toList();

        // Clean up invalid entries (missing image files)
        _scanHistory = _scanHistory.where((scan) {
          if (!File(scan.imagePath).existsSync()) {
            debugPrint('Removing scan with missing image: ${scan.imagePath}');
            return false;
          }
          return true;
        }).toList();
        
        debugPrint('Loaded ${_scanHistory.length} scans from history');
      }
    } catch (e) {
      debugPrint('Error loading scan history: $e');
      _scanHistory = [];
    }
  }

  void _cleanupImageFile(String imagePath) {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        file.deleteSync();
        debugPrint('Cleaned up image file: $imagePath');
      }
    } catch (e) {
      debugPrint('Error cleaning up image file $imagePath: $e');
    }
  }
}
