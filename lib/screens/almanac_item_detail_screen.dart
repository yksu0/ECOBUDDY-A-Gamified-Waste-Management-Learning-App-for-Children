import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/almanac_item.dart';
import '../services/almanac_service.dart';

class AlmanacItemDetailScreen extends StatelessWidget {
  final AlmanacItem item;

  const AlmanacItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: _getCategoryColor(item.category.name),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getCategoryColor(item.category.name).withOpacity(0.8),
                      _getCategoryColor(item.category.name),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        item.categoryIcon,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Difficulty Row
                  Row(
                    children: [
                      Consumer<AlmanacService>(
                        builder: (context, almanacService, child) {
                          final isViewed = almanacService.progress.hasViewedItem(item.id);
                          final isScanned = almanacService.progress.hasScannedItem(item.id);
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isScanned 
                                  ? Colors.green.withOpacity(0.1)
                                  : isViewed 
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isScanned 
                                      ? Icons.camera_alt
                                      : isViewed 
                                          ? Icons.visibility
                                          : Icons.help_outline,
                                  size: 16,
                                  color: isScanned 
                                      ? Colors.green
                                      : isViewed 
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isScanned 
                                      ? 'Scanned'
                                      : isViewed 
                                          ? 'Viewed'
                                          : 'New',
                                  style: TextStyle(
                                    color: isScanned 
                                        ? Colors.green
                                        : isViewed 
                                            ? Colors.blue
                                            : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.difficultyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: item.difficultyColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.difficultyText,
                              style: TextStyle(
                                color: item.difficultyColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      if (item.isCommon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Common',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      
                      if (item.isHazardous) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Text(
                                'Hazardous',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  _buildSection(
                    title: 'Description',
                    content: item.description,
                    icon: Icons.info_outline,
                    color: Colors.blue,
                  ),
                  
                  // Disposal Method
                  _buildSection(
                    title: 'How to Dispose',
                    content: item.disposalMethod,
                    icon: Icons.delete_outline,
                    color: Colors.orange,
                  ),
                  
                  // Recycling Info
                  _buildSection(
                    title: 'Recycling Information',
                    content: item.recyclingInfo,
                    icon: Icons.recycling,
                    color: Colors.green,
                  ),
                  
                  // Environmental Impact
                  _buildSection(
                    title: 'Environmental Impact',
                    content: item.environmentalImpact,
                    icon: Icons.eco,
                    color: Colors.green[700]!,
                  ),
                  
                  // Fun Fact
                  _buildSection(
                    title: 'Fun Fact',
                    content: item.funFact,
                    icon: Icons.lightbulb_outline,
                    color: Colors.amber[700]!,
                  ),
                  
                  // Tips
                  if (item.tips.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildTipsSection(item.tips),
                  ],
                  
                  // Where to Find
                  if (item.whereToFind.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildWhereToFindSection(item.whereToFind),
                  ],
                  
                  // Aliases
                  if (item.aliases.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildAliasesSection(item.aliases),
                  ],
                  
                  // Decomposition Time
                  const SizedBox(height: 24),
                  _buildDecompositionSection(item),
                  
                  // Related Items
                  if (item.relatedItems.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRelatedItemsSection(item.relatedItems),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTipsSection(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tips_and_updates, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(
              'Helpful Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildWhereToFindSection(List<String> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Where You\'ll Find This',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: locations.map((location) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Text(
              location,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAliasesSection(List<String> aliases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.label, color: Colors.indigo, size: 20),
            SizedBox(width: 8),
            Text(
              'Also Known As',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: aliases.map((alias) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.withOpacity(0.2)),
            ),
            child: Text(
              alias,
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDecompositionSection(AlmanacItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.decompositionTime > 100 
            ? Colors.red.withOpacity(0.1)
            : item.decompositionTime > 10 
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.decompositionTime > 100 
              ? Colors.red.withOpacity(0.2)
              : item.decompositionTime > 10 
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: item.decompositionTime > 100 
                ? Colors.red
                : item.decompositionTime > 10 
                    ? Colors.orange
                    : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decomposition Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.decompositionTime > 100 
                        ? Colors.red
                        : item.decompositionTime > 10 
                            ? Colors.orange
                            : Colors.green,
                    fontSize: 14,
                  ),
                ),
                Text(
                  item.decompositionText,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedItemsSection(List<String> relatedItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.link, color: Colors.teal, size: 20),
            SizedBox(width: 8),
            Text(
              'Related Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: relatedItems.map((relatedItem) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withOpacity(0.2)),
            ),
            child: Text(
              relatedItem,
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'plastic':
        return Colors.blue;
      case 'paper':
        return Colors.brown;
      case 'glass':
        return Colors.green;
      case 'metal':
        return Colors.grey;
      case 'organic':
        return Colors.green[700]!;
      case 'electronic':
        return Colors.purple;
      case 'textile':
        return Colors.pink;
      case 'hazardous':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}