import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/trash_item.dart';
import '../config/api_keys.dart';
import '../services/waste_classification_ai.dart';
import 'object_classifier.dart';

class GoogleVisionService {
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
  static String _apiKey = ApiKeys.googleVisionApiKey;

  // Initialize the service - API key is now loaded from secure config
  static Future<void> initialize() async {
    try {
      // Validate that API key is properly configured
      if (_apiKey == 'YOUR_GOOGLE_VISION_API_KEY_HERE' || _apiKey.isEmpty) {
        throw Exception('Google Vision API key not configured. Please add your API key to lib/config/api_keys.dart');
      }
      debugPrint('Google Vision Service initialized with API key: ${_apiKey.substring(0, 8)}...');
    } catch (e) {
      debugPrint('Failed to initialize Google Vision Service: $e');
      rethrow;
    }
  }

  static Future<VisionApiResponse> analyzeImage(String imagePath) async {
    // Initialize if needed
    await initialize();

    try {
      debugPrint('Starting image analysis with Google Vision API...');
      
      // Read and encode image
      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist: $imagePath');
      }
      
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      debugPrint('Image encoded, size: ${imageBytes.length} bytes');

      // Prepare API request
      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'LABEL_DETECTION',
                'maxResults': 20,
              },
              {
                'type': 'OBJECT_LOCALIZATION',
                'maxResults': 10,
              },
            ],
          },
        ],
      };

      debugPrint('Making API call to Google Vision...');

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('API Response status: ${response.statusCode}');
      debugPrint('API Response length: ${response.body.length}');

      if (response.statusCode != 200) {
        debugPrint('API Error Response: ${response.body}');
        throw Exception('Vision API call failed: ${response.statusCode} - ${response.body}');
      }

      // Parse response
      final responseData = jsonDecode(response.body);
      debugPrint('Successfully parsed API response');
      
      return _parseVisionResponse(responseData);
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      rethrow;
    }
  }

  static VisionApiResponse _parseVisionResponse(Map<String, dynamic> responseData) {
    final List<String> labels = [];
    final List<RecognitionResult> allResults = [];
    double maxConfidence = 0.0;

    try {
      // Extract labels from label detection
      final responses = responseData['responses'] as List?;
      if (responses != null && responses.isNotEmpty) {
        final firstResponse = responses[0] as Map<String, dynamic>;
        
        // Process label annotations with confidence tracking
        final labelAnnotations = firstResponse['labelAnnotations'] as List?;
        if (labelAnnotations != null) {
          for (final annotation in labelAnnotations) {
            final description = annotation['description'] as String?;
            final score = (annotation['score'] as num?)?.toDouble() ?? 0.0;
            
            if (description != null && score > 0.3) { // Lower threshold for more options
              // Find possible trash item for this label
              final TrashItem? possibleTrashItem = TrashDatabase.findTrashItem([description]);
              
              allResults.add(RecognitionResult(
                label: description,
                confidence: score,
                possibleTrashItem: possibleTrashItem,
              ));
              
              if (score > 0.5) { // Higher threshold for main labels
                labels.add(description);
              }
              
              if (score > maxConfidence) {
                maxConfidence = score;
              }
            }
          }
        }

        // Process object localizations
        final objectAnnotations = firstResponse['localizedObjectAnnotations'] as List?;
        if (objectAnnotations != null) {
          for (final annotation in objectAnnotations) {
            final name = annotation['name'] as String?;
            final score = (annotation['score'] as num?)?.toDouble() ?? 0.0;
            
            if (name != null && score > 0.3) {
              final TrashItem? possibleTrashItem = TrashDatabase.findTrashItem([name]);
              
              allResults.add(RecognitionResult(
                label: name,
                confidence: score,
                possibleTrashItem: possibleTrashItem,
              ));
              
              if (score > 0.5) {
                labels.add(name);
              }
              
              if (score > maxConfidence) {
                maxConfidence = score;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing Vision API response: $e');
    }

    // Sort results by confidence (highest first)
    allResults.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    // Stage 1: Identify the primary object (highest confidence result)
    String? primaryObject;
    if (allResults.isNotEmpty) {
      primaryObject = allResults.first.label;
    } else if (labels.isNotEmpty) {
      primaryObject = labels.first;
    }
    
    // Stage 2: Specialized AI waste classification using dataset knowledge
    WasteClassification? wasteClassification;
    ObjectClassification? objectClassification;
    TrashItem? identifiedTrash;
    
    if (primaryObject != null) {
      debugPrint('Stage 1: Primary object detected: $primaryObject');
      debugPrint('Stage 2: Using specialized waste classification AI...');
      
      // Use our specialized AI trained on TrashNet, RealWaste, WasteNet datasets
      wasteClassification = WasteClassificationAI.classifyWaste(
        primaryObject,
        labels,
        allResults.isNotEmpty ? allResults.first.confidence : maxConfidence,
      );
      
      // Create or find trash item from AI classification
      identifiedTrash = _createTrashItemFromClassification(wasteClassification, primaryObject);
      
      // Create ObjectClassification for API response
      objectClassification = ObjectClassification(
        detectedObject: primaryObject,
        trashItem: identifiedTrash,
        confidence: wasteClassification.confidence,
        suggestedActions: [
          wasteClassification.disposalMethod,
          wasteClassification.specialInstructions,
        ].where((action) => action.isNotEmpty).toList(),
      );
      
      debugPrint('Stage 2: AI classified as ${wasteClassification.subCategory} - ${wasteClassification.category.name}');
      debugPrint('AI Confidence: ${(wasteClassification.confidence * 100).toStringAsFixed(1)}%');
    } else {
      // Fallback to traditional method if no object detected
      identifiedTrash = TrashDatabase.findTrashItem(labels);
    }

    debugPrint('Analysis complete. Labels found: ${labels.length}');
    debugPrint('All results found: ${allResults.length}');
    debugPrint('Max confidence: ${(maxConfidence * 100).toStringAsFixed(1)}%');
    if (primaryObject != null) {
      debugPrint('Two-stage classification: $primaryObject → ${identifiedTrash?.category.name}');
    }

    return VisionApiResponse(
      labels: labels,
      confidence: maxConfidence,
      identifiedTrash: identifiedTrash,
      rawResponse: jsonEncode(responseData),
      allResults: allResults,
      primaryObject: primaryObject,
      objectClassification: objectClassification,
    );
  }

  // Helper method to create TrashItem from AI classification
  static TrashItem _createTrashItemFromClassification(WasteClassification classification, String objectName) {
    return TrashItem(
      name: classification.subCategory,
      category: classification.category,
      disposalMethod: classification.disposalMethod,
      environmentalImpact: classification.environmentalImpact,
      funFact: 'AI Classification: ${(classification.confidence * 100).toStringAsFixed(1)}% confidence. ${classification.specialInstructions}',
      recyclingPoints: _calculateRecyclingPoints(classification.category),
      isRecyclable: classification.isRecyclable,
    );
  }

  // Calculate recycling points based on category
  static int _calculateRecyclingPoints(TrashCategory category) {
    switch (category) {
      case TrashCategory.plastic:
        return 25;
      case TrashCategory.glass:
        return 30;
      case TrashCategory.metal:
        return 35;
      case TrashCategory.paper:
        return 20;
      case TrashCategory.organic:
        return 15;
      case TrashCategory.electronic:
        return 50;
      case TrashCategory.hazardous:
        return 40;
      case TrashCategory.textile:
        return 25;
      case TrashCategory.unknown:
        return 10;
    }
  }

  // Fallback method for testing without API calls
  static Future<VisionApiResponse> simulateAnalysis(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
    
    // Simulate some common trash labels for testing
    final List<String> mockLabels = [
      'Bottle',
      'Plastic',
      'Container',
      'Recyclable',
    ];
    
    final TrashItem? identifiedTrash = TrashDatabase.findTrashItem(mockLabels);
    
    return VisionApiResponse(
      labels: mockLabels,
      confidence: 0.85,
      identifiedTrash: identifiedTrash,
      rawResponse: '{"mock": "response"}',
    );
  }

  // Check if the service is properly configured
  static bool isConfigured() {
    return _apiKey.isNotEmpty;
  }

  // Get current API key status (for debugging)
  static String getApiKeyStatus() {
    if (_apiKey.isEmpty) return 'Empty';
    return 'Configured (${_apiKey.substring(0, 8)}...)';
  }
}