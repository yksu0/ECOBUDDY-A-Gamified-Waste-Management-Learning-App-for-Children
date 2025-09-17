enum TrashCategory {
  plastic,
  glass,
  metal,
  paper,
  organic,
  electronic,
  hazardous,
  textile,
  unknown,
}

class TrashItem {
  final String name;
  final TrashCategory category;
  final String disposalMethod;
  final String environmentalImpact;
  final String funFact;
  final int recyclingPoints;
  final bool isRecyclable;

  const TrashItem({
    required this.name,
    required this.category,
    required this.disposalMethod,
    required this.environmentalImpact,
    required this.funFact,
    required this.recyclingPoints,
    required this.isRecyclable,
  });
}

class VisionApiResponse {
  final List<String> labels;
  final double confidence;
  final TrashItem? identifiedTrash;
  final String rawResponse;

  const VisionApiResponse({
    required this.labels,
    required this.confidence,
    this.identifiedTrash,
    required this.rawResponse,
  });
}

class TrashDatabase {
  static const Map<String, TrashItem> _trashItems = {
    // Plastic items
    'bottle': TrashItem(
      name: 'Plastic Bottle',
      category: TrashCategory.plastic,
      disposalMethod: 'Clean and place in recycling bin. Remove cap if different plastic type.',
      environmentalImpact: 'Takes 450+ years to decompose. Can be recycled into new bottles, clothing, or carpets.',
      funFact: 'One recycled plastic bottle saves enough energy to power a lightbulb for 3 hours!',
      recyclingPoints: 25,
      isRecyclable: true,
    ),
    'plastic bag': TrashItem(
      name: 'Plastic Bag',
      category: TrashCategory.plastic,
      disposalMethod: 'Take to grocery store plastic bag recycling bins. Do not put in regular recycling.',
      environmentalImpact: 'Can take 10-20 years to decompose and harms marine life.',
      funFact: 'Plastic bags can be recycled into new bags, outdoor furniture, and playground equipment!',
      recyclingPoints: 15,
      isRecyclable: true,
    ),
    'plastic container': TrashItem(
      name: 'Plastic Container',
      category: TrashCategory.plastic,
      disposalMethod: 'Clean thoroughly and check recycling number. Most containers 1-5 are recyclable.',
      environmentalImpact: 'Can take hundreds of years to break down naturally.',
      funFact: 'Recycled plastic containers can become new food containers or even playground equipment!',
      recyclingPoints: 20,
      isRecyclable: true,
    ),

    // Glass items
    'glass': TrashItem(
      name: 'Glass Container',
      category: TrashCategory.glass,
      disposalMethod: 'Remove lids and rinse. Place in glass recycling bin.',
      environmentalImpact: 'Glass is 100% recyclable and can be recycled infinitely without losing quality.',
      funFact: 'Recycling one glass bottle saves enough energy to power a computer for 25 minutes!',
      recyclingPoints: 30,
      isRecyclable: true,
    ),
    'jar': TrashItem(
      name: 'Glass Jar',
      category: TrashCategory.glass,
      disposalMethod: 'Remove metal lid, clean jar, and place in glass recycling.',
      environmentalImpact: 'Glass recycling reduces raw material mining and saves 40% of energy.',
      funFact: 'A glass jar can be recycled into a new jar in just 30 days!',
      recyclingPoints: 25,
      isRecyclable: true,
    ),

    // Metal items
    'can': TrashItem(
      name: 'Aluminum Can',
      category: TrashCategory.metal,
      disposalMethod: 'Rinse and place in recycling bin. No need to remove labels.',
      environmentalImpact: 'Aluminum cans are infinitely recyclable and save 95% energy when recycled.',
      funFact: 'A recycled aluminum can is back on the shelf as a new can in just 60 days!',
      recyclingPoints: 35,
      isRecyclable: true,
    ),
    'tin': TrashItem(
      name: 'Tin Can',
      category: TrashCategory.metal,
      disposalMethod: 'Remove label, rinse clean, and place in metal recycling.',
      environmentalImpact: 'Steel cans are highly recyclable and reduce need for mining.',
      funFact: 'Steel is the most recycled material in the world!',
      recyclingPoints: 30,
      isRecyclable: true,
    ),

    // Paper items
    'paper': TrashItem(
      name: 'Paper',
      category: TrashCategory.paper,
      disposalMethod: 'Keep dry and clean. Place in paper recycling bin.',
      environmentalImpact: 'Recycling paper saves trees, water, and reduces landfill waste.',
      funFact: 'Recycling one ton of paper saves 17 trees and 7,000 gallons of water!',
      recyclingPoints: 20,
      isRecyclable: true,
    ),
    'cardboard': TrashItem(
      name: 'Cardboard',
      category: TrashCategory.paper,
      disposalMethod: 'Flatten boxes, remove tape/staples, keep dry for recycling.',
      environmentalImpact: 'Cardboard recycling reduces methane emissions from landfills.',
      funFact: 'Cardboard can be recycled 5-7 times before the fibers become too short!',
      recyclingPoints: 25,
      isRecyclable: true,
    ),
    'newspaper': TrashItem(
      name: 'Newspaper',
      category: TrashCategory.paper,
      disposalMethod: 'Keep dry and place in paper recycling bin.',
      environmentalImpact: 'Newspaper recycling helps reduce deforestation.',
      funFact: 'Recycled newspapers can become new newsprint, tissues, or egg cartons!',
      recyclingPoints: 15,
      isRecyclable: true,
    ),

    // Organic items
    'food': TrashItem(
      name: 'Food Waste',
      category: TrashCategory.organic,
      disposalMethod: 'Compost at home or use municipal compost bins if available.',
      environmentalImpact: 'Food waste in landfills produces methane, a potent greenhouse gas.',
      funFact: 'Composted food waste becomes nutrient-rich soil that helps plants grow!',
      recyclingPoints: 15,
      isRecyclable: true,
    ),
    'fruit': TrashItem(
      name: 'Fruit Waste',
      category: TrashCategory.organic,
      disposalMethod: 'Perfect for home composting! Creates excellent fertilizer.',
      environmentalImpact: 'Composting reduces methane emissions and creates valuable soil.',
      funFact: 'Fruit peels contain lots of nutrients that make plants super happy!',
      recyclingPoints: 20,
      isRecyclable: true,
    ),

    // Electronic items
    'battery': TrashItem(
      name: 'Battery',
      category: TrashCategory.electronic,
      disposalMethod: 'Take to electronics store or hazardous waste collection center.',
      environmentalImpact: 'Batteries contain toxic materials that can harm soil and water.',
      funFact: 'One car battery can contaminate 167,000 liters of water if not disposed properly!',
      recyclingPoints: 50,
      isRecyclable: true,
    ),
    'phone': TrashItem(
      name: 'Mobile Phone',
      category: TrashCategory.electronic,
      disposalMethod: 'Take to electronics recycling center or manufacturer take-back program.',
      environmentalImpact: 'Contains valuable metals that can be recovered and reused.',
      funFact: 'One million recycled phones can recover 35,000 pounds of copper!',
      recyclingPoints: 100,
      isRecyclable: true,
    ),
  };

  static TrashItem? findTrashItem(List<String> labels) {
    // Convert labels to lowercase for matching
    final lowerLabels = labels.map((label) => label.toLowerCase()).toList();
    
    // Try to find exact matches first
    for (final label in lowerLabels) {
      if (_trashItems.containsKey(label)) {
        return _trashItems[label];
      }
    }
    
    // Try partial matches
    for (final label in lowerLabels) {
      for (final entry in _trashItems.entries) {
        if (label.contains(entry.key) || entry.key.contains(label)) {
          return entry.value;
        }
      }
    }
    
    // Fallback based on common keywords
    return _categorizeByKeywords(lowerLabels);
  }

  static TrashItem? _categorizeByKeywords(List<String> labels) {
    final labelText = labels.join(' ').toLowerCase();
    
    // Plastic keywords
    if (labelText.contains('plastic') || 
        labelText.contains('bottle') || 
        labelText.contains('container') ||
        labelText.contains('bag') ||
        labelText.contains('packaging')) {
      return const TrashItem(
        name: 'Plastic Item',
        category: TrashCategory.plastic,
        disposalMethod: 'Check recycling number and clean before recycling.',
        environmentalImpact: 'Plastic takes hundreds of years to decompose.',
        funFact: 'Most plastics can be recycled multiple times!',
        recyclingPoints: 20,
        isRecyclable: true,
      );
    }
    
    // Glass keywords
    if (labelText.contains('glass') || 
        labelText.contains('jar') || 
        labelText.contains('bottle glass')) {
      return const TrashItem(
        name: 'Glass Item',
        category: TrashCategory.glass,
        disposalMethod: 'Clean and place in glass recycling bin.',
        environmentalImpact: 'Glass is 100% recyclable without quality loss.',
        funFact: 'Glass can be recycled forever!',
        recyclingPoints: 30,
        isRecyclable: true,
      );
    }
    
    // Metal keywords
    if (labelText.contains('metal') || 
        labelText.contains('aluminum') || 
        labelText.contains('can') ||
        labelText.contains('tin') ||
        labelText.contains('steel')) {
      return const TrashItem(
        name: 'Metal Item',
        category: TrashCategory.metal,
        disposalMethod: 'Clean and place in metal recycling bin.',
        environmentalImpact: 'Metal recycling saves significant energy.',
        funFact: 'Recycling aluminum saves 95% of the energy needed to make new aluminum!',
        recyclingPoints: 35,
        isRecyclable: true,
      );
    }
    
    // Paper keywords
    if (labelText.contains('paper') || 
        labelText.contains('cardboard') || 
        labelText.contains('newspaper') ||
        labelText.contains('magazine') ||
        labelText.contains('book')) {
      return const TrashItem(
        name: 'Paper Item',
        category: TrashCategory.paper,
        disposalMethod: 'Keep dry and place in paper recycling.',
        environmentalImpact: 'Paper recycling saves trees and water.',
        funFact: 'Recycling paper helps save our forests!',
        recyclingPoints: 20,
        isRecyclable: true,
      );
    }
    
    // Food/organic keywords
    if (labelText.contains('food') || 
        labelText.contains('fruit') || 
        labelText.contains('vegetable') ||
        labelText.contains('organic') ||
        labelText.contains('banana') ||
        labelText.contains('apple')) {
      return const TrashItem(
        name: 'Organic Waste',
        category: TrashCategory.organic,
        disposalMethod: 'Compost if possible, otherwise general waste.',
        environmentalImpact: 'Composting reduces methane emissions.',
        funFact: 'Food scraps make excellent fertilizer for plants!',
        recyclingPoints: 15,
        isRecyclable: true,
      );
    }
    
    return null; // Unknown item
  }

  static List<TrashItem> getAllTrashItems() {
    return _trashItems.values.toList();
  }

  static List<TrashItem> getTrashItemsByCategory(TrashCategory category) {
    return _trashItems.values
        .where((item) => item.category == category)
        .toList();
  }
}