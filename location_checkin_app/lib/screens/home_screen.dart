import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/check_in_record.dart';
import 'new_check_in_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<CheckInRecord> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('check_in_records');

    if (!mounted) return;

    if (recordsJson != null && recordsJson.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(recordsJson);
      setState(() {
        records = decodedList.map((item) => CheckInRecord.fromMap(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        records = [];
        isLoading = false;
      });
    }
  }

  Future<void> saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(records.map((r) => r.toMap()).toList());
    await prefs.setString('check_in_records', encodedList);
  }

  void deleteRecord(CheckInRecord record) async {
    setState(() {
      records.removeWhere((item) => item.id == record.id);
    });
    await saveRecords();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldCheck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Logs',
            onPressed: loadRecords,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? buildEmptyState()
              : buildRecordList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewCheckInScreen()),
          );

          if (result == true && mounted) {
            loadRecords();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'No check-ins yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first check-in.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildRecordList() {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        return Dismissible(
          key: Key(record.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text('Are you sure you want to delete this record?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (_) => deleteRecord(record),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: record.imagePath.isNotEmpty
                      ? Image.file(File(record.imagePath), fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)))
                      : Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                ),
              ),
              title: Text(
                record.note.isNotEmpty ? record.note : 'Check-In Record',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  record.timestamp.toLocal().toString().split('.')[0],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckInDetailScreen(record: record),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}