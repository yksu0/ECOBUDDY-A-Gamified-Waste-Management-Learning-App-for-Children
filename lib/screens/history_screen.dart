import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scan_history_service.dart';
import '../models/scan_history.dart';
import '../models/trash_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    // Initialize scan history service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scanHistoryService = ScanHistoryService();
      if (!scanHistoryService.isInitialized) {
        scanHistoryService.initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'Recent'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your scans...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: ChangeNotifierProvider.value(
              value: ScanHistoryService(),
              child: Consumer<ScanHistoryService>(
                builder: (context, scanHistoryService, child) {
                  if (!scanHistoryService.isInitialized) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHistoryTab(scanHistoryService),
                      _buildStatisticsTab(scanHistoryService),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ScanHistoryService scanHistoryService) {
    final scans = _searchQuery.isEmpty
        ? scanHistoryService.scanHistory
        : scanHistoryService.searchScans(_searchQuery);

    if (scans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.camera_alt : Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No Scans Yet' : 'No Results Found',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty 
                  ? 'Start scanning items to see your history!'
                  : 'Try a different search term',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        return _buildScanCard(scan);
      },
    );
  }

  Widget _buildScanCard(ScanHistoryItem scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: File(scan.imagePath).existsSync()
                    ? Image.file(
                        File(scan.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name and category
                  Text(
                    scan.identifiedTrash?.name ?? 'Unknown Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Category and confidence
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(scan.identifiedTrash?.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          scan.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${scan.confidencePercentage} confidence',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Date and feedback
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scan.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (scan.wasCorrect)
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        )
                      else
                        const Icon(
                          Icons.error,
                          size: 16,
                          color: Colors.orange,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(ScanHistoryService scanHistoryService) {
    final stats = scanHistoryService.getStatistics();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Scans',
                  stats.totalScans.toString(),
                  Icons.camera_alt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Success Rate',
                  stats.successRatePercentage,
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  stats.weekScans.toString(),
                  Icons.calendar_view_week,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${stats.streak} days',
                  Icons.local_fire_department,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Category breakdown
          const Text(
            'Categories Scanned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...TrashCategory.values.map((category) {
            final count = stats.categoryBreakdown[category] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_getCategoryName(category)),
                  ),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(TrashCategory? category) {
    if (category == null) return Colors.grey;
    switch (category) {
      case TrashCategory.plastic:
        return Colors.blue;
      case TrashCategory.glass:
        return Colors.cyan;
      case TrashCategory.metal:
        return Colors.grey;
      case TrashCategory.paper:
        return Colors.brown;
      case TrashCategory.organic:
        return Colors.green;
      case TrashCategory.electronic:
        return Colors.purple;
      case TrashCategory.hazardous:
        return Colors.red;
      case TrashCategory.textile:
        return Colors.pink;
      case TrashCategory.unknown:
        return Colors.grey;
    }
  }

  String _getCategoryName(TrashCategory category) {
    switch (category) {
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
}