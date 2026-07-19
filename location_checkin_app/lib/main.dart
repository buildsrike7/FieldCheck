import 'dart:async'; 
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed to check for Flutter Web
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global list to store available cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera hardware list initialization error: $e");
  }
  runApp(const MyApp());
}

// ==========================================
// DATA MODEL
// ==========================================
class CheckInRecord {
  final String id;
  final String imagePath;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String note;

  CheckInRecord({
    required this.id,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory CheckInRecord.fromMap(Map<String, dynamic> map) => CheckInRecord(
        id: map['id'],
        imagePath: map['imagePath'],
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        accuracy: (map['accuracy'] as num? ?? 0.0).toDouble(),
        timestamp: DateTime.parse(map['timestamp']),
        note: map['note'] ?? "",
      );
}

// ==========================================
// APPLICATION ENTRANCE
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Check-In App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WelcomeAnimationScreen(), 
    );
  }
}

// ==========================================
// WELCOME ANIMATION SCREEN
// ==========================================
class WelcomeAnimationScreen extends StatefulWidget {
  const WelcomeAnimationScreen({super.key});

  @override
  State<WelcomeAnimationScreen> createState() => _WelcomeAnimationScreenState();
}

class _WelcomeAnimationScreenState extends State<WelcomeAnimationScreen> {
  Timer? _welcomeTimer;
  double _opacity = 0.0;
  double _scale = 0.6;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    _welcomeTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Check-In History'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 3, 3),
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 700),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 96,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'FieldCheck',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Secure Check-Ins',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// REAL WORKING CAMERA SCREEN
// ==========================================
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    if (kIsWeb) {
      _initCamera();
      return;
    }

    final status = await Permission.camera.status;
    if (!mounted) return;
    
    if (status.isGranted) {
      _initCamera();
    } else {
      final requestStatus = await Permission.camera.request();
      if (!mounted) return;
      
      if (requestStatus.isGranted) {
        _initCamera();
      } else {
        setState(() {
          _errorMessage = "Camera access denied. Please allow camera access in App Settings.";
        });
      }
    }
  }

  void _initCamera() {
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      setState(() {
        _initializeControllerFuture = _controller!.initialize();
      });
    } else {
      setState(() {
        _errorMessage = "No hardware camera detected on this device.";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _initializeControllerFuture;
      final XFile image = await _controller!.takePicture();
      
      if (!mounted) return;
      Navigator.pop(context, image);
    } catch (e) {
      debugPrint("Error taking picture: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error taking picture: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Check-In Photo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_off_outlined, size: 64, color: Colors.white70),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (!kIsWeb)
                      ElevatedButton(
                        onPressed: () => openAppSettings(),
                        child: const Text('Open Settings'),
                      ),
                  ],
                ),
              ),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      Center(
                        child: CameraPreview(_controller!),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: FloatingActionButton(
                              onPressed: _takePicture,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              child: const Icon(Icons.camera_alt, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Camera Init Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
              },
            ),
    );
  }
}

// ==========================================
// NEW CHECK-IN ENTRY SCREEN
// ==========================================
class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final TextEditingController _noteController = TextEditingController();
  
  XFile? _capturedPhoto;
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  String? _locationStatusMessage;

  Future<void> _takePhoto() async {
    if (!kIsWeb) {
      final permissionStatus = await Permission.camera.request();
      if (!mounted) return;
      
      if (!permissionStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera permission is required to take a check-in photo.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }
    }

    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera hardware detected on this device.')),
      );
      return;
    }

    final XFile? photo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
    if (!mounted) return;

    if (photo != null) {
      setState(() {
        _capturedPhoto = photo;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationStatusMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      
      if (!serviceEnabled) {
        setState(() {
          _isFetchingLocation = false;
          _locationStatusMessage = "Device GPS Location services are disabled.";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please turn on your device location/GPS services.')),
        );
        return;
      }

      if (!kIsWeb) {
        final permissionStatus = await Permission.locationWhenInUse.request();
        if (!mounted) return;

        if (!permissionStatus.isGranted) {
          setState(() {
            _isFetchingLocation = false;
            _locationStatusMessage = "Location permission denied.";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission is required to check-in coordinates.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      } else {
        LocationPermission webPerm = await Geolocator.requestPermission();
        if (webPerm == LocationPermission.denied || webPerm == LocationPermission.deniedForever) {
          setState(() {
            _isFetchingLocation = false;
            _locationStatusMessage = "Location permission denied by browser.";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingLocation = false;
        _locationStatusMessage = "Failed to secure location: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to acquire location: $e')),
      );
    }
  }

  void _saveCheckIn() {
    if (_capturedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a required photo before saving.')),
      );
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please obtain your required GPS location before saving.')),
      );
      return;
    }

    final newRecord = CheckInRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: _capturedPhoto!.path,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      accuracy: _currentPosition!.accuracy,
      timestamp: DateTime.now(),
      note: _noteController.text,
    );

    Navigator.pop(context, newRecord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Check-In',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Note',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.teal),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Stack(
              clipBehavior: Clip.none,
              children: [
                OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
                  label: const Text('Take Photo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('required', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12, style: BorderStyle.solid),
              ),
              child: _capturedPhoto == null
                  ? const Center(
                      child: Text(
                        'IMG  /  X',
                        style: TextStyle(fontSize: 16, color: Colors.black38, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb 
                          ? Image.network(_capturedPhoto!.path, fit: BoxFit.cover)
                          : Image.file(File(_capturedPhoto!.path), fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 24),

            Stack(
              clipBehavior: Clip.none,
              children: [
                OutlinedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.flag_outlined, color: Colors.black),
                  label: const Text('Get Location', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('required', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isFetchingLocation)
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                        ),
                        SizedBox(width: 12),
                        Text('fetching... (loading state)', style: TextStyle(color: Colors.black54)),
                      ],
                    )
                  else if (_currentPosition == null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _locationStatusMessage ?? 'No GPS Coordinates Acquired',
                            style: TextStyle(
                              color: _locationStatusMessage != null ? Colors.red.shade700 : Colors.black38,
                              fontWeight: _locationStatusMessage != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_locationStatusMessage != null && !kIsWeb)
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                            onPressed: () => openAppSettings(),
                            child: const Text('Settings', style: TextStyle(fontSize: 12)),
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDisabledLocationRow('Latitude'),
                    const SizedBox(height: 12),
                    _buildDisabledLocationRow('Longitude'),
                    const SizedBox(height: 12),
                    _buildDisabledLocationRow('Accuracy'),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Latitude', style: TextStyle(color: Colors.black54)),
                        Text(_currentPosition!.latitude.toStringAsFixed(6), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Longitude', style: TextStyle(color: Colors.black54)),
                        Text(_currentPosition!.longitude.toStringAsFixed(6), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Accuracy', style: TextStyle(color: Colors.black54)),
                        Text('${_currentPosition!.accuracy.toStringAsFixed(1)} m', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            Stack(
              clipBehavior: Clip.none,
              children: [
                ElevatedButton(
                  onPressed: _saveCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Positioned(
                  right: 8,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('required', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledLocationRow(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38)),
        Container(
          height: 12,
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// WIREFRAME: CHECK-IN DETAIL SCREEN
// ==========================================
class CheckInDetailScreen extends StatelessWidget {
  final CheckInRecord record;

  const CheckInDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final List<String> timeParts = record.timestamp.toString().split('.');
    final String cleanTime = timeParts.isNotEmpty ? timeParts[0] : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Check-In Detail',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 320,
              color: Colors.white,
              child: kIsWeb
                  ? Image.network(
                      record.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImageErrorLayout(),
                    )
                  : Image.file(
                      File(record.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImageErrorLayout(),
                    ),
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOTE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.note.isEmpty ? "No manual note written." : record.note,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Latitude', record.latitude.toStringAsFixed(6)),
                  _buildDetailRow('Longitude', record.longitude.toStringAsFixed(6)),
                  _buildDetailRow('Accuracy', '${record.accuracy.toStringAsFixed(1)} m'),
                  _buildDetailRow('Created At', cleanTime),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageErrorLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Image Unavailable',
            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// ==========================================
// CORE UI AND LOGIC (HOME SCREEN)
// ==========================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CheckInRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedRecords();
  }

  Future<void> _loadSavedRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('check_ins');
    if (jsonList != null) {
      if (!mounted) return;
      setState(() {
        _history = jsonList
            .map((item) => CheckInRecord.fromMap(jsonDecode(item)))
            .toList();
      });
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        _history.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList('check_ins', jsonList);
  }

  void _deleteRecord(int index) async {
    setState(() {
      _history.removeAt(index);
    });
    await _saveRecords();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in record permanently deleted'),
      ),
    );
  }

  Future<void> _navigateToNewCheckIn() async {
    final CheckInRecord? newRecord = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewCheckInScreen()),
    );
    if (!mounted) return;

    if (newRecord != null) {
      setState(() {
        _history.insert(0, newRecord);
      });
      await _saveRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'FieldCheck',
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No check-in history records yet.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the "+" Icon below to make your check in!',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final record = _history[index];
                    final List<String> timeParts = record.timestamp.toString().split('.');
                    final String cleanTime = timeParts.isNotEmpty ? timeParts[0] : '';
                    
                    return Dismissible(
                      key: Key(record.id),
                      direction: DismissDirection.endToStart, 
                      // --- TRIGGER CONFIRMATION DIALOG ON SWIPE ---
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Are you sure you want to delete this check-in record? This action cannot be undone.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        _deleteRecord(index);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckInDetailScreen(record: record),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(
                                    record.imagePath,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      width: 50,
                                      height: 50,
                                      child: Icon(Icons.image, color: Colors.grey[600]),
                                    ),
                                  )
                                : Image.file(
                                    File(record.imagePath),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      width: 50,
                                      height: 50,
                                      child: Icon(Icons.image, color: Colors.grey[600]),
                                    ),
                                  ),
                          ),
                          title: Text(
                            'Lat: ${record.latitude.toStringAsFixed(4)}, Lon: ${record.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(cleanTime, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              if (record.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  record.note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewCheckIn,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}