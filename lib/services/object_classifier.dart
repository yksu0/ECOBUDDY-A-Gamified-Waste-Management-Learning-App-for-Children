import '../models/trash_item.dart';

class ObjectClassifier {
  /// Stage 2: Intelligent classification of any object into waste categories
  /// Takes a general object name and determines disposal method
  static ObjectClassification classifyObject(String objectName) {
    final normalizedName = objectName.toLowerCase().trim();
    
    // Food items → Organic waste
    if (_isFoodItem(normalizedName)) {
      return _createFoodWasteClassification(objectName);
    }
    
    // Plastic items → Plastic recycling
    if (_isPlasticItem(normalizedName)) {
      return _createPlasticClassification(objectName);
    }
    
    // Glass items → Glass recycling
    if (_isGlassItem(normalizedName)) {
      return _createGlassClassification(objectName);
    }
    
    // Metal items → Metal recycling
    if (_isMetalItem(normalizedName)) {
      return _createMetalClassification(objectName);
    }
    
    // Paper items → Paper recycling
    if (_isPaperItem(normalizedName)) {
      return _createPaperClassification(objectName);
    }
    
    // Electronic items → Electronic waste
    if (_isElectronicItem(normalizedName)) {
      return _createElectronicClassification(objectName);
    }
    
    // Textile items → Textile recycling/donation
    if (_isTextileItem(normalizedName)) {
      return _createTextileClassification(objectName);
    }
    
    // Hazardous items → Special disposal
    if (_isHazardousItem(normalizedName)) {
      return _createHazardousClassification(objectName);
    }
    
    // Default: General trash with educational note
    return _createGeneralTrashClassification(objectName);
  }
  
  /// Food and organic items
  static bool _isFoodItem(String name) {
    final foodKeywords = [
      // Fruits
      'apple', 'banana', 'orange', 'grape', 'strawberry', 'peach', 'pear', 'pineapple',
      'watermelon', 'melon', 'cherry', 'plum', 'kiwi', 'mango', 'avocado',
      // Vegetables
      'carrot', 'potato', 'tomato', 'onion', 'lettuce', 'cabbage', 'broccoli',
      'cucumber', 'pepper', 'spinach', 'celery', 'corn', 'peas',
      // Other food
      'bread', 'sandwich', 'pizza', 'egg', 'cheese', 'meat', 'chicken', 'fish',
      'pasta', 'rice', 'cereal', 'cookie', 'cake', 'food', 'fruit', 'vegetable',
      // Food waste indicators
      'peel', 'core', 'shell', 'bone', 'leftover', 'scrap'
    ];
    
    return foodKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Plastic items
  static bool _isPlasticItem(String name) {
    final plasticKeywords = [
      'bottle', 'plastic', 'container', 'cup', 'straw', 'bag', 'wrapper',
      'packaging', 'yogurt', 'milk jug', 'shampoo', 'detergent', 'toy',
      'pen', 'ruler', 'utensil', 'fork', 'knife', 'spoon', 'plate'
    ];
    
    return plasticKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Glass items
  static bool _isGlassItem(String name) {
    final glassKeywords = [
      'glass', 'jar', 'bottle', 'wine', 'beer', 'mason jar', 'vase',
      'mirror', 'window', 'drinking glass', 'tumbler'
    ];
    
    return glassKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Metal items
  static bool _isMetalItem(String name) {
    final metalKeywords = [
      'can', 'aluminum', 'steel', 'iron', 'metal', 'tin', 'foil',
      'soda can', 'food can', 'wire', 'nail', 'screw', 'coin'
    ];
    
    return metalKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Paper items
  static bool _isPaperItem(String name) {
    final paperKeywords = [
      'paper', 'newspaper', 'magazine', 'book', 'cardboard', 'box',
      'envelope', 'letter', 'document', 'receipt', 'ticket', 'napkin',
      'tissue', 'paper towel', 'toilet paper'
    ];
    
    return paperKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Electronic items
  static bool _isElectronicItem(String name) {
    final electronicKeywords = [
      'phone', 'smartphone', 'computer', 'laptop', 'tablet', 'camera',
      'television', 'tv', 'radio', 'speaker', 'headphone', 'charger',
      'cable', 'battery', 'remote', 'keyboard', 'mouse', 'monitor',
      'electronic', 'device', 'gadget'
    ];
    
    return electronicKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Textile items
  static bool _isTextileItem(String name) {
    final textileKeywords = [
      'clothing', 'shirt', 'pants', 'dress', 'shoe', 'sock', 'hat',
      'jacket', 'coat', 'sweater', 'jeans', 'fabric', 'cloth',
      'towel', 'blanket', 'pillow', 'curtain'
    ];
    
    return textileKeywords.any((keyword) => name.contains(keyword));
  }
  
  /// Hazardous items
  static bool _isHazardousItem(String name) {
    final hazardousKeywords = [
      'battery', 'paint', 'chemical', 'cleaning', 'bleach', 'ammonia',
      'pesticide', 'fertilizer', 'motor oil', 'gasoline', 'propane',
      'lighter', 'matches', 'medicine', 'pill', 'syringe'
    ];
    
    return hazardousKeywords.any((keyword) => name.contains(keyword));
  }
  
  // Classification creators
  static ObjectClassification _createFoodWasteClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.organic,
        disposalMethod: 'Compost if possible, or dispose in organic waste bin. Remove any non-organic parts first.',
        environmentalImpact: 'Composting reduces methane emissions and creates nutrient-rich soil. Food waste in landfills produces harmful greenhouse gases.',
        funFact: 'Food scraps can be turned into compost in 2-8 weeks, creating natural fertilizer!',
        recyclingPoints: 15,
        isRecyclable: true,
      ),
      confidence: 0.9, // High confidence for classification logic
      suggestedActions: [
        'Start a compost bin at home',
        'Check if your area has organic waste collection',
        'Use food scraps for gardening',
      ],
    );
  }
  
  static ObjectClassification _createPlasticClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.plastic,
        disposalMethod: 'Check the recycling number on the item. Clean and place in plastic recycling bin if accepted in your area.',
        environmentalImpact: 'Plastic can take 400-1000 years to decompose. Recycling saves energy and reduces ocean pollution.',
        funFact: 'One recycled plastic bottle saves enough energy to power a lightbulb for 3 hours!',
        recyclingPoints: 20,
        isRecyclable: true,
      ),
      confidence: 0.85,
      suggestedActions: [
        'Look for the recycling number (1-7)',
        'Clean the item before recycling',
        'Consider reusing before throwing away',
      ],
    );
  }
  
  static ObjectClassification _createGlassClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.glass,
        disposalMethod: 'Remove caps and labels. Place in glass recycling bin. Be careful of broken glass.',
        environmentalImpact: 'Glass is 100% recyclable and can be recycled indefinitely without losing quality.',
        funFact: 'Recycled glass melts at a lower temperature, saving energy in manufacturing!',
        recyclingPoints: 25,
        isRecyclable: true,
      ),
      confidence: 0.9,
      suggestedActions: [
        'Remove all caps and lids',
        'Rinse clean',
        'Handle broken glass carefully',
      ],
    );
  }
  
  static ObjectClassification _createMetalClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.metal,
        disposalMethod: 'Rinse clean and place in metal recycling bin. Check if your area accepts this type of metal.',
        environmentalImpact: 'Metal recycling saves 95% of the energy needed to make new metal from raw materials.',
        funFact: 'Aluminum cans can be recycled and back on store shelves in just 60 days!',
        recyclingPoints: 30,
        isRecyclable: true,
      ),
      confidence: 0.85,
      suggestedActions: [
        'Rinse out food residue',
        'Remove labels if possible',
        'Check local metal recycling rules',
      ],
    );
  }
  
  static ObjectClassification _createPaperClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.paper,
        disposalMethod: 'Keep dry and clean. Place in paper recycling bin. Remove any plastic parts.',
        environmentalImpact: 'Recycling paper saves trees, water, and energy. One ton of recycled paper saves 17 trees!',
        funFact: 'Paper can be recycled 5-7 times before the fibers become too short to use!',
        recyclingPoints: 15,
        isRecyclable: true,
      ),
      confidence: 0.8,
      suggestedActions: [
        'Keep paper dry and clean',
        'Remove any plastic parts',
        'Consider reusing for notes first',
      ],
    );
  }
  
  static ObjectClassification _createElectronicClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.electronic,
        disposalMethod: 'Take to electronic waste recycling center. Do not put in regular trash. Remove personal data first.',
        environmentalImpact: 'E-waste contains valuable metals but also toxic materials. Proper recycling recovers materials and prevents pollution.',
        funFact: 'One smartphone contains over 30 different elements, including gold and silver!',
        recyclingPoints: 50,
        isRecyclable: true,
      ),
      confidence: 0.9,
      suggestedActions: [
        'Find local e-waste recycling center',
        'Remove personal data',
        'Consider donating if still working',
      ],
    );
  }
  
  static ObjectClassification _createTextileClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.textile,
        disposalMethod: 'Donate if in good condition, or take to textile recycling center. Some areas have clothing bins.',
        environmentalImpact: 'Textile production uses lots of water and energy. Reusing and recycling clothes reduces environmental impact.',
        funFact: 'It takes 2,700 liters of water to make one cotton t-shirt!',
        recyclingPoints: 35,
        isRecyclable: true,
      ),
      confidence: 0.8,
      suggestedActions: [
        'Donate if in good condition',
        'Look for textile recycling bins',
        'Consider upcycling projects',
      ],
    );
  }
  
  static ObjectClassification _createHazardousClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.hazardous,
        disposalMethod: 'Take to hazardous waste collection center. Never put in regular trash or recycling.',
        environmentalImpact: 'Hazardous materials can contaminate soil and water. Proper disposal protects the environment and public health.',
        funFact: 'Many communities have special collection days for hazardous waste disposal.',
        recyclingPoints: 40,
        isRecyclable: false,
      ),
      confidence: 0.95,
      suggestedActions: [
        'Find hazardous waste collection center',
        'Never mix with regular trash',
        'Check community collection events',
      ],
    );
  }
  
  static ObjectClassification _createGeneralTrashClassification(String objectName) {
    return ObjectClassification(
      detectedObject: objectName,
      trashItem: TrashItem(
        name: objectName,
        category: TrashCategory.unknown,
        disposalMethod: 'If unsure about disposal, check with local waste management or place in general trash bin.',
        environmentalImpact: 'When in doubt, research proper disposal methods to minimize environmental impact.',
        funFact: 'Learning about proper waste disposal helps protect our planet for future generations!',
        recyclingPoints: 10,
        isRecyclable: false,
      ),
      confidence: 0.6,
      suggestedActions: [
        'Research proper disposal method',
        'Contact local waste management',
        'Consider if item can be reused',
      ],
    );
  }
}