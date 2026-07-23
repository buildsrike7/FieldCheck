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