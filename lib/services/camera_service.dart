import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isInitializing = false;
  String? _error;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> initializeCamera() async {
    if (_isInitializing || _isInitialized) return;

    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      // Use the back camera (usually index 0)
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      // Initialize controller
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize camera: ${e.toString()}';
      debugPrint(_error);
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<String?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      _error = 'Camera not initialized';
      notifyListeners();
      return null;
    }

    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = path.join(directory.path, 'trash_scan_$timestamp.jpg');

      // Take picture
      final XFile picture = await _controller!.takePicture();
      
      // Copy to our desired location
      final File imageFile = File(imagePath);
      await File(picture.path).copy(imagePath);
      
      // Clean up the original file
      await File(picture.path).delete();

      return imagePath;
    } catch (e) {
      _error = 'Failed to take picture: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null) return;

    try {
      final currentFlashMode = _controller!.value.flashMode;
      final newFlashMode = currentFlashMode == FlashMode.off 
          ? FlashMode.torch 
          : FlashMode.off;
      
      await _controller!.setFlashMode(newFlashMode);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle flash: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  FlashMode get currentFlashMode {
    return _controller?.value.flashMode ?? FlashMode.off;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // For testing - simulate camera without actual camera hardware
  Future<String?> simulateTakePicture() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate camera delay
    
    // In a real implementation, this would return null
    // For demo purposes, we'll return a fake path
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imagePath = path.join(directory.path, 'simulated_trash_$timestamp.jpg');
    
    // Create an empty file to simulate image capture
    final file = File(imagePath);
    await file.writeAsBytes([]);
    
    return imagePath;
  }
}