import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this package if not already installed, or use camera's internal flow
import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    // Request Camera permission explicitly
    final status = await Permission.camera.request();
    
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Camera permission is required to take photos.';
        _isInitializing = false;
      });
      return;
    }

    await _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
      );

      try {
        await _controller!.initialize();
      } catch (e) {
        debugPrint('Camera error: $e');
        _errorMessage = 'Failed to initialize camera.';
      }
    } else {
      _errorMessage = 'No cameras found on this device.';
    }

    if (!mounted) return;
    setState(() => _isInitializing = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Camera unavailable.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Take Photo')),
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final navigator = Navigator.of(context);
            final XFile image = await _controller!.takePicture();
            
            if (!mounted) return;
            navigator.pop(image.path);
          } catch (e) {
            debugPrint('Failed to take picture: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}