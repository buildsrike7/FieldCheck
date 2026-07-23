import 'dart:convert';

class CheckInRecord {
  final String id;
  final String note;
  final String imagePath;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  CheckInRecord({
    required this.id,
    required this.note,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CheckInRecord.fromMap(Map<String, dynamic> map) {
    return CheckInRecord(
      id: map['id'] ?? '',
      note: map['note'] ?? '',
      imagePath: map['imagePath'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      accuracy: map['accuracy'] ?? 0.0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CheckInRecord.fromJson(String source) =>
      CheckInRecord.fromMap(json.decode(source));
}