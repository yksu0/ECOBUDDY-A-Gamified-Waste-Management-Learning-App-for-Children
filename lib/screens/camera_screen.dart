import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/google_vision_service.dart';
import '../providers/pet_provider.dart';
import '../models/trash_item.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraService _cameraService;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ChangeNotifierProvider.value(
        value: _cameraService,
        child: Consumer<CameraService>(
          builder: (context, cameraService, child) {
            return SafeArea(
              child: Stack(
                children: [
                  // Camera preview or loading/error state
                  _buildCameraPreview(cameraService),
                  
                  // Top app bar
                  _buildTopAppBar(),
                  
                  // Bottom controls
                  _buildBottomControls(cameraService),
                  
                  // Instructions overlay
                  _buildInstructionsOverlay(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraService cameraService) {
    if (cameraService.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                cameraService.error ?? 'Unknown camera error',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                cameraService.clearError();
                _initializeCamera();
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    if (cameraService.isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    if (!cameraService.isInitialized || cameraService.controller == null) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: cameraService.controller!.value.previewSize!.height,
          height: cameraService.controller!.value.previewSize!.width,
          child: CameraPreview(cameraService.controller!),
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const Expanded(
              child: Text(
                'Scan Trash',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Consumer<CameraService>(
              builder: (context, cameraService, child) {
                return IconButton(
                  onPressed: cameraService.isInitialized 
                      ? () => cameraService.toggleFlash()
                      : null,
                  icon: Icon(
                    cameraService.currentFlashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(CameraService cameraService) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button (placeholder)
            _buildControlButton(
              icon: Icons.photo_library,
              onPressed: () {
                // TODO: Implement gallery selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery selection coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            
            // Capture button
            _buildCaptureButton(cameraService),
            
            // Help button
            _buildControlButton(
              icon: Icons.help_outline,
              onPressed: () => _showHelpDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton(CameraService cameraService) {
    return GestureDetector(
      onTap: cameraService.isInitialized && !_isCapturing
          ? () => _takePicture(cameraService)
          : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          color: _isCapturing 
              ? Colors.grey 
              : (cameraService.isInitialized ? Colors.green : Colors.grey),
        ),
        child: _isCapturing
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
            : const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Point your camera at trash',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Make sure the item is clearly visible and well-lit',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture(CameraService cameraService) async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final imagePath = await cameraService.takePicture();
      
      if (imagePath != null && mounted) {
        // Navigate to results screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              imagePath: imagePath,
              visionResponse: null, // Will be set after analysis
            ),
          ),
        );
      } else {
        throw Exception('Failed to capture image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Scan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📱 Hold your phone steady'),
            SizedBox(height: 8),
            Text('🔦 Use good lighting'),
            SizedBox(height: 8),
            Text('📏 Get close to the item'),
            SizedBox(height: 8),
            Text('🎯 Center the trash in the frame'),
            SizedBox(height: 8),
            Text('📸 Tap the green button to scan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class ScanResultScreen extends StatefulWidget {
  final String imagePath;
  final VisionApiResponse? visionResponse;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    this.visionResponse,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  VisionApiResponse? _visionResponse;
  bool _isAnalyzing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _visionResponse = widget.visionResponse;
    if (_visionResponse == null) {
      _analyzeImage();
    } else {
      _isAnalyzing = false;
    }
  }

  Future<void> _analyzeImage() async {
    try {
      setState(() {
        _isAnalyzing = true;
        _error = null;
      });

      debugPrint('Starting image analysis...');

      // Initialize Google Vision service
      await GoogleVisionService.initialize();
      debugPrint('Google Vision service initialized');
      
      // Check if service is configured
      if (!GoogleVisionService.isConfigured()) {
        throw Exception('Google Vision API not properly configured');
      }
      
      debugPrint('API Key Status: ${GoogleVisionService.getApiKeyStatus()}');
      
      // Analyze the image
      debugPrint('Analyzing image: ${widget.imagePath}');
      final response = await GoogleVisionService.analyzeImage(widget.imagePath);
      debugPrint('Analysis complete. Labels found: ${response.labels.length}');
      
      setState(() {
        _visionResponse = response;
        _isAnalyzing = false;
      });
    } catch (e) {
      debugPrint('Analysis failed: $e');
      setState(() {
        _error = e.toString();
        _isAnalyzing = false;
      });
      
      // Show detailed error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      // Fallback to simulation for demo purposes
      debugPrint('Trying simulation fallback...');
      try {
        final response = await GoogleVisionService.simulateAnalysis(widget.imagePath);
        setState(() {
          _visionResponse = response;
          _error = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using demo mode - AI recognition will be added soon!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        debugPrint('Simulation also failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isAnalyzing) {
      return _buildAnalyzingState();
    } else if (_error != null && _visionResponse == null) {
      return _buildErrorState();
    } else {
      return _buildResultState();
    }
  }

  Widget _buildAnalyzingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Display captured image
          Expanded(
            flex: 2,
            child: _buildImagePreview(),
          ),
          
          const SizedBox(height: 20),
          
          // Analyzing animation
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing your trash...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI is identifying the item and finding disposal instructions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildImagePreview(),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Analysis Failed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? 'Unknown error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _analyzeImage,
                        child: const Text('Try Again'),
                      ),
                      ElevatedButton(
                        onPressed: () => _completeScanning(context, null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Continue Anyway'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    final trashItem = _visionResponse?.identifiedTrash;
    final labels = _visionResponse?.labels ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display captured image
            _buildImagePreview(),
            
            const SizedBox(height: 20),
            
            if (trashItem != null) ...[
              _buildTrashItemInfo(trashItem),
            ] else ...[
              _buildUnknownItemInfo(labels),
            ],
            
            const SizedBox(height: 20),
            
            // Complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeScanning(context, trashItem),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  trashItem != null 
                      ? 'Great! Help Bud Grow (+${trashItem.recyclingPoints} points)'
                      : 'Thanks for Caring! Help Bud Grow',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: File(widget.imagePath).existsSync()
            ? Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Image Preview',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTrashItemInfo(TrashItem trashItem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(trashItem.category),
                color: Colors.green,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trashItem.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      _getCategoryName(trashItem.category),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: trashItem.isRecyclable ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trashItem.isRecyclable ? 'Recyclable' : 'Non-Recyclable',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoSection(
            'How to Dispose:',
            trashItem.disposalMethod,
            Icons.recycling,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoSection(
            'Environmental Impact:',
            trashItem.environmentalImpact,
            Icons.eco,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoSection(
            'Fun Fact:',
            trashItem.funFact,
            Icons.lightbulb,
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownItemInfo(List<String> labels) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.orange,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unknown Item',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'We couldn\'t identify this specific item, but here\'s what we detected:',
            style: TextStyle(fontSize: 14),
          ),
          
          const SizedBox(height: 8),
          
          if (labels.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: labels.take(5).map((label) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          _buildInfoSection(
            'General Advice:',
            'Check your local recycling guidelines or ask an adult to help identify the proper disposal method.',
            Icons.info,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(TrashCategory category) {
    switch (category) {
      case TrashCategory.plastic:
        return Icons.local_drink;
      case TrashCategory.glass:
        return Icons.wine_bar;
      case TrashCategory.metal:
        return Icons.build;
      case TrashCategory.paper:
        return Icons.description;
      case TrashCategory.organic:
        return Icons.eco;
      case TrashCategory.electronic:
        return Icons.electrical_services;
      case TrashCategory.hazardous:
        return Icons.warning;
      case TrashCategory.textile:
        return Icons.checkroom;
      case TrashCategory.unknown:
        return Icons.help_outline;
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

  void _completeScanning(BuildContext context, TrashItem? trashItem) {
    // Reward the pet for scanning
    final petProvider = context.read<PetProvider>();
    petProvider.scanTrash();
    
    // Additional points for successful identification
    if (trashItem != null) {
      // Could add bonus XP here based on recycling points
      // petProvider.addBonusXp(trashItem.recyclingPoints);
    }
    
    // Clean up the image file
    try {
      File(widget.imagePath).deleteSync();
    } catch (e) {
      // Ignore cleanup errors
    }
    
    // Return to home screen
    Navigator.popUntil(context, (route) => route.isFirst);
    
    // Show success message
    String message = '🎉 Bud is so happy! You helped the environment!';
    if (trashItem != null) {
      message = '🎉 Great job! Bud learned about ${trashItem.name}!';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}