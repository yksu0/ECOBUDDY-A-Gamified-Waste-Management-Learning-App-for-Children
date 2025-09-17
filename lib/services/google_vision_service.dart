import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/trash_item.dart';

class GoogleVisionService {
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
  static String _apiKey = 'AIzaSyCwNoDPnl1YiUsQ_wTe7CEKwNFwkoJBD1M'; // Fallback API key

  // Initialize the service - try to get API key from Android build config
  static Future<void> initialize() async {
    try {
      // Try to get API key from Android string resources
      if (Platform.isAndroid) {
        const platform = MethodChannel('flutter/platform_views');
        // For now, we'll stick with the hardcoded key since the platform channel approach is complex
        debugPrint('Using hardcoded API key for simplicity');
      }
      debugPrint('Google Vision Service initialized with API key: ${_apiKey.substring(0, 8)}...');
    } catch (e) {
      debugPrint('Failed to get API key from platform, using fallback: $e');
      // _apiKey is already set to the fallback value
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
    double maxConfidence = 0.0;

    try {
      // Extract labels from label detection
      final responses = responseData['responses'] as List?;
      if (responses != null && responses.isNotEmpty) {
        final firstResponse = responses[0] as Map<String, dynamic>;
        
        // Process label annotations
        final labelAnnotations = firstResponse['labelAnnotations'] as List?;
        if (labelAnnotations != null) {
          for (final annotation in labelAnnotations) {
            final description = annotation['description'] as String?;
            final score = (annotation['score'] as num?)?.toDouble() ?? 0.0;
            
            if (description != null && score > 0.5) { // Only include confident labels
              labels.add(description);
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
            
            if (name != null && score > 0.5) {
              labels.add(name);
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

    // Find matching trash item
    final TrashItem? identifiedTrash = TrashDatabase.findTrashItem(labels);

    return VisionApiResponse(
      labels: labels,
      confidence: maxConfidence,
      identifiedTrash: identifiedTrash,
      rawResponse: jsonEncode(responseData),
    );
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