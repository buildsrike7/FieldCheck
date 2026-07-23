import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/welcome_screen.dart'; // Import WelcomeScreen instead of HomeScreen directly

// Global variable to hold available device cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure Flutter engine bindings are initialized before calling async platform channels
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Fetch available cameras on device startup
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error initializing camera: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Starts on the welcome screen
    );
  }
}