import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/check_in_record.dart';
import 'camera_screen.dart';

class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => NewCheckInScreenState();
}

class NewCheckInScreenState extends State<NewCheckInScreen> {
  String? imagePath;
  Position? currentPosition;
  bool isFetchingLocation = false;
  bool isSaving = false;
  String? locationError;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkAndFetchLocation();
  }

  Future<void> checkAndFetchLocation() async {
    setState(() {
      isFetchingLocation = true;
      locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          locationError = 'GPS is disabled.';
          isFetchingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            locationError = 'Location permission denied.';
            isFetchingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          locationError = 'Location permanently denied.';
          isFetchingLocation = false;
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      if (!mounted) return;
      setState(() {
        currentPosition = position;
        isFetchingLocation = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      setState(() {
        locationError = 'Failed to get GPS.';
        isFetchingLocation = false;
      });
    }
  }

  Future<void> openCamera() async {
    final String? path = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (path != null && mounted) {
      setState(() => imagePath = path);
    }
  }

  Future<void> saveCheckIn() async {
    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture an image first')),
      );
      return;
    }

    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Awaiting valid GPS coordinates...')),
      );
      return;
    }

    setState(() => isSaving = true);

    final newRecord = CheckInRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath!,
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
      accuracy: currentPosition!.accuracy,
      timestamp: DateTime.now(),
      note: noteController.text.trim(),
    );

    final prefs = await SharedPreferences.getInstance();
    final String? existingJson = prefs.getString('check_in_records');
    List<dynamic> recordsList = existingJson != null ? jsonDecode(existingJson) : [];

    recordsList.insert(0, newRecord.toMap());
    await prefs.setString('check_in_records', jsonEncode(recordsList));

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Check-In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Note', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter observation note...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity),
                    )
                  : const Center(
                      child: Text('IMG / X', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: checkAndFetchLocation,
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Get Location'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFetchingLocation)
                    const Text('fetching... (loading state)', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                  else if (locationError != null)
                    Text(locationError!, style: const TextStyle(color: Colors.red, fontSize: 13))
                  else if (currentPosition != null) ...[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Latitude'), Text(currentPosition!.latitude.toStringAsFixed(5))]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Longitude'), Text(currentPosition!.longitude.toStringAsFixed(5))]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Accuracy'), Text('${currentPosition!.accuracy.toStringAsFixed(1)} m')]),
                  ] else
                    const Text('GPS location unavailable'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isSaving ? null : saveCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}