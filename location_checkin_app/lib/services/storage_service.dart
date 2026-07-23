import 'package:shared_preferences/shared_preferences.dart';
import '../models/check_in_record.dart';

class StorageService {
  static const String _keyRecords = 'field_check_records';

  static Future<List<CheckInRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_keyRecords);
    if (jsonList == null) return [];
    return jsonList.map((str) => CheckInRecord.deserialize(str)).toList();
  }

  static Future<void> saveRecord(CheckInRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.insert(0, record); // Insert newest first
    final List<String> jsonList = records.map((r) => r.serialize()).toList();
    await prefs.setStringList(_keyRecords, jsonList);
  }

  static Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    var records = await getRecords();
    records.removeWhere((r) => r.id == id);
    final List<String> jsonList = records.map((r) => r.serialize()).toList();
    await prefs.setStringList(_keyRecords, jsonList);
  }
}