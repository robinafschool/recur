/// Model representing a reality check for lucid dreaming
class RealityCheck {
  final String id;
  final String name;
  final String type; // 'interval' or 'event'
  final int? intervalMinutes;
  final String? eventDescription;
  final bool isActive;

  RealityCheck({
    required this.id,
    required this.name,
    required this.type,
    this.intervalMinutes,
    this.eventDescription,
    required this.isActive,
  });

  /// Create from JSON (database)
  factory RealityCheck.fromJson(Map<String, dynamic> json) {
    return RealityCheck(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      intervalMinutes: json['interval_minutes'] as int?,
      eventDescription: json['event_description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert to JSON (for database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'interval_minutes': intervalMinutes,
      'event_description': eventDescription,
      'is_active': isActive,
    };
  }

  /// Create a copy with updated fields
  RealityCheck copyWith({
    String? id,
    String? name,
    String? type,
    int? intervalMinutes,
    String? eventDescription,
    bool? isActive,
  }) {
    return RealityCheck(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      eventDescription: eventDescription ?? this.eventDescription,
      isActive: isActive ?? this.isActive,
    );
  }
}
