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

  Map<String, dynamic> toJson() => {
        'id': id,
        'note': note,
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CheckInRecord.fromJson(Map<String, dynamic> json) => CheckInRecord(
        id: json['id'],
        note: json['note'],
        imagePath: json['imagePath'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        accuracy: json['accuracy'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  String serialize() => jsonEncode(toJson());

  factory CheckInRecord.deserialize(String str) =>
      CheckInRecord.fromJson(jsonDecode(str));
}