class LogEntry {
  final String id;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String note;

  // 새로 추가된 필드들
  final String? place;      // 장소 (텍스트)
  final String? tags;       // 태그 문자열 (#카페, #산책 등)
  final bool isAnonymous;   // 익명 공유 여부

  LogEntry({
    required this.id,
    required this.timestamp,
    this.latitude,
    this.longitude,
    required this.note,
    this.place,
    this.tags,
    this.isAnonymous = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'note': note,
        'place': place,
        'tags': tags,
        'isAnonymous': isAnonymous,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      note: json['note'] as String? ?? '',
      place: json['place'] as String?,
      tags: json['tags'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
    );
  }
}
