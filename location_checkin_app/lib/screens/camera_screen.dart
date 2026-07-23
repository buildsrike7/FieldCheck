import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    
    if (!mounted) return;

    if (!status.isGranted) {
      await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Camera Permission Denied'),
          content: const Text('This app needs camera access to capture check-in photos. Please enable it in your settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    try {
      final cameras = await availableCameras();
      
      if (!mounted) return;
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;
      setState(() => _isCameraReady = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Photo')),
      body: !_isCameraReady
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (innerContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: _isCameraReady
          ? FloatingActionButton(
              onPressed: () async {
                try {
                  await _initializeControllerFuture;
                  
                  if (!mounted) return;
                  final image = await _controller!.takePicture();
                  
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, image.path);
                } catch (e) {
                  debugPrint('Error capturing image: $e');
                }
              },
              child: const Icon(Icons.camera),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}