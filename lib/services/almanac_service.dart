import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/almanac_item.dart';
import '../models/trash_item.dart';

class AlmanacService extends ChangeNotifier {
  static final AlmanacService _instance = AlmanacService._internal();
  factory AlmanacService() => _instance;
  AlmanacService._internal();

  List<AlmanacItem> _allItems = [];
  List<AlmanacCategory> _categories = [];
  AlmanacProgress _progress = AlmanacProgress.initial();
  bool _isInitialized = false;

  // Getters
  List<AlmanacItem> get allItems => _allItems;
  List<AlmanacCategory> get categories => _categories;
  AlmanacProgress get progress => _progress;
  bool get isInitialized => _isInitialized;
  
  int get totalItems => _allItems.length;
  int get viewedItems => _progress.totalViewed;
  int get scannedItems => _progress.totalScanned;
  double get overallProgress => _allItems.isEmpty ? 0.0 : viewedItems / totalItems;

  Future<void> initialize() async {
    debugPrint('Initializing Almanac Service...');
    await _loadProgress();
    _generateAlmanacData();
    _isInitialized = true;
    debugPrint('Almanac Service initialized with ${_allItems.length} items across ${_categories.length} categories');
    notifyListeners();
  }

  void _generateAlmanacData() {
    _allItems = _createAllItems();
    _categories = _createCategories();
  }

  List<AlmanacItem> _createAllItems() {
    return [
      // PLASTIC ITEMS
      AlmanacItem(
        id: 'plastic_bottle',
        name: 'Plastic Water Bottle',
        description: 'Single-use plastic bottles commonly used for water and beverages',
        category: TrashCategory.plastic,
        aliases: ['water bottle', 'drink bottle', 'PET bottle'],
        disposalMethod: 'Empty completely, remove cap, place in recycling bin',
        recyclingInfo: 'Can be recycled into new bottles, clothing, carpets',
        tips: ['Remove labels if possible', 'Rinse clean', 'Check recycling number'],
        funFact: 'It takes 450 years for a plastic bottle to decompose naturally!',
        imageAsset: 'assets/images/plastic_bottle.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Home', 'School', 'Parks', 'Vending machines'],
        environmentalImpact: 'Single-use plastic bottles contribute significantly to ocean pollution and take centuries to break down.',
        decompositionTime: 450,
        isHazardous: false,
        relatedItems: ['plastic_cap', 'soda_bottle'],
      ),
      
      AlmanacItem(
        id: 'plastic_bag',
        name: 'Plastic Shopping Bag',
        description: 'Thin plastic bags used for shopping and carrying items',
        category: TrashCategory.plastic,
        aliases: ['shopping bag', 'grocery bag', 'carrier bag'],
        disposalMethod: 'Take to special collection bins at grocery stores',
        recyclingInfo: 'Cannot go in regular recycling - needs special processing',
        tips: ['Reuse multiple times before disposing', 'Bundle together for collection'],
        funFact: 'Plastic bags can take up to 1000 years to decompose!',
        imageAsset: 'assets/images/plastic_bag.png',
        difficultyLevel: 2,
        isCommon: true,
        whereToFind: ['Grocery stores', 'Shopping centers', 'Home'],
        environmentalImpact: 'Plastic bags are a major threat to marine life and clog recycling machinery.',
        decompositionTime: 1000,
        isHazardous: false,
        relatedItems: ['plastic_wrap', 'food_packaging'],
      ),

      AlmanacItem(
        id: 'yogurt_container',
        name: 'Yogurt Container',
        description: 'Small plastic containers used for individual yogurt servings',
        category: TrashCategory.plastic,
        aliases: ['yogurt cup', 'dairy container'],
        disposalMethod: 'Rinse clean and place in recycling bin',
        recyclingInfo: 'Usually recyclable - check recycling number on bottom',
        tips: ['Remove foil lid completely', 'Rinse thoroughly'],
        funFact: 'Americans throw away 11 billion yogurt containers every year!',
        imageAsset: 'assets/images/yogurt_container.png',
        difficultyLevel: 2,
        isCommon: true,
        whereToFind: ['Kitchen', 'School lunch', 'Cafeterias'],
        environmentalImpact: 'Small containers add up quickly in landfills but are recyclable when clean.',
        decompositionTime: 50,
        isHazardous: false,
        relatedItems: ['food_containers', 'plastic_lids'],
      ),

      // PAPER ITEMS
      AlmanacItem(
        id: 'newspaper',
        name: 'Newspaper',
        description: 'Daily or weekly printed news publication',
        category: TrashCategory.paper,
        aliases: ['paper', 'news', 'journal'],
        disposalMethod: 'Place in paper recycling bin or bundle together',
        recyclingInfo: 'Easily recyclable into new paper products',
        tips: ['Remove plastic bags', 'Keep dry', 'Bundle with string if needed'],
        funFact: 'Recycling one ton of newspaper saves 3.3 cubic yards of landfill space!',
        imageAsset: 'assets/images/newspaper.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Home', 'Coffee shops', 'Libraries', 'Newsstands'],
        environmentalImpact: 'Paper is biodegradable and highly recyclable, making it an eco-friendly option.',
        decompositionTime: 1,
        isHazardous: false,
        relatedItems: ['magazines', 'cardboard'],
      ),

      AlmanacItem(
        id: 'cardboard_box',
        name: 'Cardboard Box',
        description: 'Corrugated cardboard shipping or storage container',
        category: TrashCategory.paper,
        aliases: ['shipping box', 'package', 'corrugated cardboard'],
        disposalMethod: 'Flatten and place in recycling bin',
        recyclingInfo: 'Highly recyclable - can become new cardboard',
        tips: ['Remove all tape and labels', 'Flatten to save space', 'Keep dry'],
        funFact: 'Cardboard can be recycled 5-7 times before the fibers become too weak!',
        imageAsset: 'assets/images/cardboard_box.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Online deliveries', 'Moving boxes', 'Storage'],
        environmentalImpact: 'Cardboard recycling saves trees and reduces methane emissions from landfills.',
        decompositionTime: 1,
        isHazardous: false,
        relatedItems: ['paper', 'packaging'],
      ),

      // GLASS ITEMS
      AlmanacItem(
        id: 'glass_jar',
        name: 'Glass Jar',
        description: 'Glass container used for food storage or preserves',
        category: TrashCategory.glass,
        aliases: ['mason jar', 'preserve jar', 'food jar'],
        disposalMethod: 'Remove lid, rinse clean, place in glass recycling',
        recyclingInfo: 'Infinitely recyclable without quality loss',
        tips: ['Remove metal lids', 'Rinse thoroughly', 'Check for cracks'],
        funFact: 'Glass can be recycled indefinitely without losing quality or purity!',
        imageAsset: 'assets/images/glass_jar.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Kitchen', 'Pantry', 'Grocery stores'],
        environmentalImpact: 'Glass recycling saves energy and raw materials while reducing landfill waste.',
        decompositionTime: 0, // Glass doesn't decompose naturally
        isHazardous: false,
        relatedItems: ['glass_bottle', 'metal_lid'],
      ),

      AlmanacItem(
        id: 'wine_bottle',
        name: 'Wine Bottle',
        description: 'Glass bottle used for wine and other beverages',
        category: TrashCategory.glass,
        aliases: ['glass bottle', 'beverage bottle'],
        disposalMethod: 'Remove cork and labels, rinse, recycle with glass',
        recyclingInfo: 'Can be melted down to make new glass products',
        tips: ['Remove cork first', 'Labels can usually stay on', 'Rinse clean'],
        funFact: 'A glass bottle can go from recycling bin to store shelf in just 30 days!',
        imageAsset: 'assets/images/wine_bottle.png',
        difficultyLevel: 2,
        isCommon: false,
        whereToFind: ['Restaurants', 'Home', 'Events'],
        environmentalImpact: 'Glass recycling significantly reduces energy consumption compared to making new glass.',
        decompositionTime: 0,
        isHazardous: false,
        relatedItems: ['cork', 'glass_jar'],
      ),

      // METAL ITEMS
      AlmanacItem(
        id: 'aluminum_can',
        name: 'Aluminum Can',
        description: 'Lightweight metal can used for beverages',
        category: TrashCategory.metal,
        aliases: ['soda can', 'beer can', 'drink can'],
        disposalMethod: 'Rinse clean and place in recycling bin',
        recyclingInfo: 'Highly valuable for recycling - becomes new cans',
        tips: ['Rinse thoroughly', 'Can leave tabs attached', 'Crush to save space'],
        funFact: 'Aluminum cans can be recycled and back on store shelves in just 60 days!',
        imageAsset: 'assets/images/aluminum_can.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Vending machines', 'Cafeterias', 'Events', 'Home'],
        environmentalImpact: 'Aluminum recycling saves 90% of the energy needed to make new aluminum.',
        decompositionTime: 200,
        isHazardous: false,
        relatedItems: ['steel_can', 'metal_lid'],
      ),

      AlmanacItem(
        id: 'steel_can',
        name: 'Steel Food Can',
        description: 'Metal can used for canned food products',
        category: TrashCategory.metal,
        aliases: ['tin can', 'food can', 'soup can'],
        disposalMethod: 'Remove label, rinse clean, recycle with metals',
        recyclingInfo: 'Steel is magnetically separated and highly recyclable',
        tips: ['Remove paper labels', 'Rinse thoroughly', 'Can crush to save space'],
        funFact: 'Steel cans contain about 25% recycled steel already!',
        imageAsset: 'assets/images/steel_can.png',
        difficultyLevel: 2,
        isCommon: true,
        whereToFind: ['Kitchen', 'Pantry', 'Camping'],
        environmentalImpact: 'Steel recycling conserves iron ore and reduces mining impact.',
        decompositionTime: 50,
        isHazardous: false,
        relatedItems: ['aluminum_can', 'can_opener'],
      ),

      // ORGANIC ITEMS
      AlmanacItem(
        id: 'apple_core',
        name: 'Apple Core',
        description: 'Organic waste from eating an apple',
        category: TrashCategory.organic,
        aliases: ['fruit waste', 'apple remains', 'food scraps'],
        disposalMethod: 'Compost bin or organic waste collection',
        recyclingInfo: 'Composts into nutrient-rich soil amendment',
        tips: ['Remove any stickers', 'Compost with brown materials', 'Avoid if treated with chemicals'],
        funFact: 'Apple cores decompose in just 1-2 months in compost!',
        imageAsset: 'assets/images/apple_core.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Kitchen', 'School lunch', 'Picnics'],
        environmentalImpact: 'Organic waste creates methane in landfills but valuable compost when properly processed.',
        decompositionTime: 1,
        isHazardous: false,
        relatedItems: ['banana_peel', 'food_scraps'],
      ),

      AlmanacItem(
        id: 'banana_peel',
        name: 'Banana Peel',
        description: 'Natural organic waste from eating a banana',
        category: TrashCategory.organic,
        aliases: ['banana skin', 'fruit peel'],
        disposalMethod: 'Compost bin or organic waste collection',
        recyclingInfo: 'Excellent for composting - rich in potassium',
        tips: ['Great for compost', 'Can use as natural fertilizer', 'Avoid throwing in nature'],
        funFact: 'Banana peels can help your garden plants grow better due to their potassium content!',
        imageAsset: 'assets/images/banana_peel.png',
        difficultyLevel: 1,
        isCommon: true,
        whereToFind: ['Kitchen', 'School', 'Hiking trails'],
        environmentalImpact: 'While biodegradable, banana peels should still be composted rather than littered.',
        decompositionTime: 1,
        isHazardous: false,
        relatedItems: ['apple_core', 'vegetable_scraps'],
      ),

      // ELECTRONIC ITEMS
      AlmanacItem(
        id: 'old_phone',
        name: 'Old Smartphone',
        description: 'Obsolete or broken mobile phone device',
        category: TrashCategory.electronic,
        aliases: ['cell phone', 'mobile phone', 'smartphone'],
        disposalMethod: 'Take to electronics recycling center or manufacturer program',
        recyclingInfo: 'Contains valuable metals that can be recovered',
        tips: ['Remove personal data first', 'Remove battery if possible', 'Find certified e-waste recycler'],
        funFact: 'One million recycled phones can recover 35,000 pounds of copper, 772 pounds of silver, and 75 pounds of gold!',
        imageAsset: 'assets/images/old_phone.png',
        difficultyLevel: 4,
        isCommon: false,
        whereToFind: ['Old devices drawer', 'Electronics stores', 'Upgrade replacements'],
        environmentalImpact: 'E-waste contains toxic materials but also valuable metals that should be recovered.',
        decompositionTime: 1000,
        isHazardous: true,
        relatedItems: ['batteries', 'cables'],
      ),

      AlmanacItem(
        id: 'batteries',
        name: 'Household Batteries',
        description: 'Small batteries used in household devices',
        category: TrashCategory.electronic,
        aliases: ['AA batteries', 'AAA batteries', 'remote batteries'],
        disposalMethod: 'Take to battery collection point or hazardous waste facility',
        recyclingInfo: 'Metals can be recovered but require special processing',
        tips: ['Never throw in regular trash', 'Tape terminals to prevent fires', 'Collect multiple batteries together'],
        funFact: 'A single battery can contaminate 600,000 liters of water!',
        imageAsset: 'assets/images/batteries.png',
        difficultyLevel: 3,
        isCommon: true,
        whereToFind: ['Electronics', 'Remote controls', 'Toys', 'Flashlights'],
        environmentalImpact: 'Batteries contain heavy metals that are toxic but valuable for recycling.',
        decompositionTime: 100,
        isHazardous: true,
        relatedItems: ['old_phone', 'electronics'],
      ),

      // TEXTILE ITEMS
      AlmanacItem(
        id: 'old_tshirt',
        name: 'Old T-Shirt',
        description: 'Worn out or unwanted cotton clothing',
        category: TrashCategory.textile,
        aliases: ['old clothes', 'worn shirt', 'fabric'],
        disposalMethod: 'Donate, repurpose, or take to textile recycling',
        recyclingInfo: 'Can be recycled into new textiles or industrial rags',
        tips: ['Donate if still wearable', 'Use as cleaning rags', 'Check for textile recycling programs'],
        funFact: 'The average American throws away 70 pounds of textiles per year!',
        imageAsset: 'assets/images/old_tshirt.png',
        difficultyLevel: 2,
        isCommon: true,
        whereToFind: ['Closet cleanouts', 'Outgrown clothes', 'Worn garments'],
        environmentalImpact: 'Textile waste is growing rapidly, but many textiles can be recycled or repurposed.',
        decompositionTime: 5,
        isHazardous: false,
        relatedItems: ['old_shoes', 'fabric_scraps'],
      ),

      // HAZARDOUS ITEMS
      AlmanacItem(
        id: 'paint_can',
        name: 'Paint Can',
        description: 'Metal can containing or previously containing paint',
        category: TrashCategory.hazardous,
        aliases: ['paint container', 'latex paint', 'oil paint'],
        disposalMethod: 'Take to hazardous waste facility - never regular trash',
        recyclingInfo: 'Requires special processing due to chemical content',
        tips: ['Let paint dry completely first', 'Keep original labels', 'Never pour down drains'],
        funFact: 'Paint is the most common household hazardous waste!',
        imageAsset: 'assets/images/paint_can.png',
        difficultyLevel: 5,
        isCommon: false,
        whereToFind: ['Garage', 'Home improvement projects', 'Art supplies'],
        environmentalImpact: 'Paint contains chemicals that can contaminate soil and water if not properly disposed.',
        decompositionTime: 0,
        isHazardous: true,
        relatedItems: ['chemical_containers', 'cleaning_products'],
      ),
    ];
  }

  List<AlmanacCategory> _createCategories() {
    return [
      AlmanacCategory(
        category: TrashCategory.plastic,
        title: 'Plastic Items',
        description: 'Items made from various types of plastic polymers',
        icon: '🥤',
        color: Colors.blue,
        items: _allItems.where((item) => item.category == TrashCategory.plastic).toList(),
        generalTips: [
          'Check the recycling number on plastic items',
          'Rinse containers clean before recycling',
          'Remove caps and lids when instructed',
          'Avoid single-use plastics when possible'
        ],
        recyclingOverview: 'Most rigid plastics can be recycled, but plastic bags need special collection points.',
      ),
      
      AlmanacCategory(
        category: TrashCategory.paper,
        title: 'Paper & Cardboard',
        description: 'Items made from paper, cardboard, and paperboard',
        icon: '📄',
        color: Colors.brown,
        items: _allItems.where((item) => item.category == TrashCategory.paper).toList(),
        generalTips: [
          'Keep paper dry for recycling',
          'Remove tape, staples, and plastic',
          'Flatten cardboard boxes',
          'Shredded paper needs special handling'
        ],
        recyclingOverview: 'Paper is highly recyclable and can be made into new paper products multiple times.',
      ),

      AlmanacCategory(
        category: TrashCategory.glass,
        title: 'Glass Items',
        description: 'Items made from glass materials',
        icon: '🍾',
        color: Colors.green,
        items: _allItems.where((item) => item.category == TrashCategory.glass).toList(),
        generalTips: [
          'Remove lids and caps',
          'Rinse clean but labels can stay',
          'Don\'t break glass before recycling',
          'Separate by color if required'
        ],
        recyclingOverview: 'Glass can be recycled infinitely without losing quality or strength.',
      ),

      AlmanacCategory(
        category: TrashCategory.metal,
        title: 'Metal Items',
        description: 'Items made from aluminum, steel, and other metals',
        icon: '🥫',
        color: Colors.grey,
        items: _allItems.where((item) => item.category == TrashCategory.metal).toList(),
        generalTips: [
          'Rinse food containers clean',
          'Remove paper labels',
          'Aluminum and steel can be mixed',
          'Magnets help identify steel'
        ],
        recyclingOverview: 'Metals are highly valuable for recycling and can be reused indefinitely.',
      ),

      AlmanacCategory(
        category: TrashCategory.organic,
        title: 'Organic Waste',
        description: 'Natural, biodegradable organic materials',
        icon: '🍎',
        color: Colors.green[700]!,
        items: _allItems.where((item) => item.category == TrashCategory.organic).toList(),
        generalTips: [
          'Compost when possible',
          'Remove stickers and bands',
          'Mix green and brown materials',
          'Keep compost balanced and moist'
        ],
        recyclingOverview: 'Organic waste can be composted into valuable soil amendment instead of going to landfills.',
      ),

      AlmanacCategory(
        category: TrashCategory.electronic,
        title: 'Electronics',
        description: 'Electronic devices and components',
        icon: '📱',
        color: Colors.purple,
        items: _allItems.where((item) => item.category == TrashCategory.electronic).toList(),
        generalTips: [
          'Remove personal data first',
          'Find certified e-waste recyclers',
          'Never throw in regular trash',
          'Check manufacturer take-back programs'
        ],
        recyclingOverview: 'E-waste contains valuable metals but also toxic materials requiring special handling.',
      ),

      AlmanacCategory(
        category: TrashCategory.textile,
        title: 'Textiles',
        description: 'Clothing, fabric, and textile materials',
        icon: '👕',
        color: Colors.pink,
        items: _allItems.where((item) => item.category == TrashCategory.textile).toList(),
        generalTips: [
          'Donate items in good condition',
          'Repurpose into cleaning rags',
          'Look for textile recycling programs',
          'Consider clothing swaps'
        ],
        recyclingOverview: 'Textiles can often be donated, repurposed, or recycled rather than thrown away.',
      ),

      AlmanacCategory(
        category: TrashCategory.hazardous,
        title: 'Hazardous Waste',
        description: 'Items that require special disposal due to toxicity',
        icon: '⚠️',
        color: Colors.red,
        items: _allItems.where((item) => item.category == TrashCategory.hazardous).toList(),
        generalTips: [
          'Never put in regular trash',
          'Find local hazardous waste facilities',
          'Keep in original containers',
          'Follow all safety instructions'
        ],
        recyclingOverview: 'Hazardous waste requires special handling to protect environment and human health.',
      ),
    ];
  }

  // Search functionality
  List<AlmanacItem> searchItems(String query) {
    if (query.trim().isEmpty) return _allItems;
    
    return _allItems.where((item) => item.matchesSearch(query)).toList();
  }

  List<AlmanacItem> getItemsByCategory(TrashCategory category) {
    return _allItems.where((item) => item.category == category).toList();
  }

  AlmanacItem? getItemById(String id) {
    try {
      return _allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  AlmanacCategory? getCategoryInfo(TrashCategory category) {
    try {
      return _categories.firstWhere((cat) => cat.category == category);
    } catch (e) {
      return null;
    }
  }

  // Progress tracking
  Future<void> markItemViewed(String itemId) async {
    final newViewedItems = Map<String, bool>.from(_progress.viewedItems);
    newViewedItems[itemId] = true;
    
    _progress = _progress.copyWith(
      viewedItems: newViewedItems,
      lastUpdated: DateTime.now(),
    );
    
    await _saveProgress();
    notifyListeners();
  }

  Future<void> markItemScanned(String itemId) async {
    final newScannedItems = Map<String, bool>.from(_progress.scannedItems);
    newScannedItems[itemId] = true;
    
    // Also mark as viewed
    final newViewedItems = Map<String, bool>.from(_progress.viewedItems);
    newViewedItems[itemId] = true;
    
    _progress = _progress.copyWith(
      viewedItems: newViewedItems,
      scannedItems: newScannedItems,
      lastUpdated: DateTime.now(),
    );
    
    await _saveProgress();
    notifyListeners();
  }

  // Learning statistics
  Map<String, dynamic> getLearningStats() {
    return {
      'totalItems': totalItems,
      'viewedItems': viewedItems,
      'scannedItems': scannedItems,
      'overallProgress': overallProgress,
      'categoryProgress': _categories.map((category) => {
        'category': category.category.name,
        'title': category.title,
        'progress': _progress.getProgressForCategory(category.category, category.items),
        'itemsLearned': category.items.where((item) => _progress.hasViewedItem(item.id)).length,
        'totalItems': category.items.length,
      }).toList(),
    };
  }

  // Find items that might be confused with scanned item
  List<AlmanacItem> getSimilarItems(String scannedItemName) {
    final searchResults = searchItems(scannedItemName);
    return searchResults.take(3).toList();
  }

  // Persistence
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('almanac_progress', jsonEncode(_progress.toJson()));
      debugPrint('Almanac progress saved');
    } catch (e) {
      debugPrint('Error saving almanac progress: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressString = prefs.getString('almanac_progress');
      
      if (progressString != null) {
        final progressData = jsonDecode(progressString) as Map<String, dynamic>;
        _progress = AlmanacProgress.fromJson(progressData);
        debugPrint('Almanac progress loaded successfully');
      } else {
        debugPrint('No saved almanac progress found');
      }
    } catch (e) {
      debugPrint('Error loading almanac progress: $e');
      _progress = AlmanacProgress.initial();
    }
  }

  // Reset progress (for testing)
  Future<void> resetProgress() async {
    _progress = AlmanacProgress.initial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('almanac_progress');
    notifyListeners();
  }
}