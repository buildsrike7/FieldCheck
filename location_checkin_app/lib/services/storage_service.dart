import 'package:shared_preferences/shared_preferences.dart';
import '../models/check_in_record.dart';

class StorageService {
  static const String _storageKey = 'check_in_records_v1';

  static Future<List<CheckInRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_storageKey) ?? [];
    return jsonList.map((item) => CheckInRecord.fromJson(item)).toList();
  }

  static Future<void> saveRecord(CheckInRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_storageKey) ?? [];
    jsonList.insert(0, record.toJson()); // Newest first
    await prefs.setStringList(_storageKey, jsonList);
  }

  static Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_storageKey) ?? [];
    jsonList.removeWhere((item) {
      final record = CheckInRecord.fromJson(item);
      return record.id == id;
    });
    await prefs.setStringList(_storageKey, jsonList);
  }
}