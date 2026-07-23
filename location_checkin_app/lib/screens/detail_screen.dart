import 'dart:io';
import 'package:flutter/material.dart';
import '../models/check_in_record.dart';

class DetailScreen extends StatelessWidget {
  final CheckInRecord record;

  const DetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image Viewer / Placeholder block matching wireframe 3
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: File(record.imagePath).existsSync()
                  ? Image.file(
                      File(record.imagePath),
                      height: 220,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'IMG / X',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NOTE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Text(
                record.note,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Latitude', style: TextStyle(color: Colors.grey)),
                        Text(record.latitude.toStringAsFixed(5), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Longitude', style: TextStyle(color: Colors.grey)),
                        Text(record.longitude.toStringAsFixed(5), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Accuracy', style: TextStyle(color: Colors.grey)),
                        Text('${record.accuracy.toStringAsFixed(1)} m', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Created At', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${record.timestamp.toLocal()}'.split('.')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}