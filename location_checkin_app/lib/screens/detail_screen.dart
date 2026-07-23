import 'dart:io';
import 'package:flutter/material.dart';
import '../models/check_in_record.dart';

class DetailScreen extends StatelessWidget {
  final CheckInRecord record;

  const DetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: File(record.imagePath).existsSync()
                  ? Image.file(
                      File(record.imagePath),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Image file not found')),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Note',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              record.note,
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 30),
            const Text(
              'Location Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Latitude', record.latitude.toString()),
            _buildDetailRow('Longitude', record.longitude.toString()),
            _buildDetailRow('Accuracy', '${record.accuracy.toStringAsFixed(1)} meters'),
            const Divider(height: 30),
            const Text(
              'Timestamp',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              record.timestamp.toLocal().toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}