import 'dart:io';
import 'package:flutter/material.dart';

import '../models/check_in_record.dart';

class CheckInDetailScreen extends StatelessWidget {
  final CheckInRecord record;

  const CheckInDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(record.imagePath),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              record.note.isNotEmpty ? record.note : 'Check-in Record',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Timestamp'),
              subtitle: Text(record.timestamp.toLocal().toString()),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Coordinates'),
              subtitle: Text('Lat: ${record.latitude}\nLong: ${record.longitude}'),
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Accuracy Radius'),
              subtitle: Text('${record.accuracy.toStringAsFixed(2)} meters'),
            ),
          ],
        ),
      ),
    );
  }
}