/// Single reality check schedule: one window per day with configurable interval.
class RealityCheckSchedule {
  const RealityCheckSchedule({
    this.id,
    required this.enabled,
    required this.intervalMinutes,
    required this.startTime,
    required this.endTime,
  });

  final String? id;
  final bool enabled;
  final int intervalMinutes;
  /// Start of window as "HH:mm" (e.g. "08:00").
  final String startTime;
  /// End of window as "HH:mm" (e.g. "20:00").
  final String endTime;

  /// Times within the window at which to trigger (e.g. [8, 12, 16, 20] for every 4h from 8–20).
  List<int> get triggerHours {
    final start = _parseHourMinute(startTime);
    final end = _parseHourMinute(endTime);
    if (start == null || end == null || intervalMinutes <= 0) return [];
    final startMinutes = start.$1 * 60 + start.$2;
    var endMinutes = end.$1 * 60 + end.$2;
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    final interval = intervalMinutes;
    final hours = <int>[];
    for (var m = startMinutes; m <= endMinutes; m += interval) {
      final h = (m ~/ 60) % 24;
      hours.add(h);
    }
    return hours..sort();
  }

  static (int, int)? _parseHourMinute(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return null;
    return (h, m);
  }

  RealityCheckSchedule copyWith({
    String? id,
    bool? enabled,
    int? intervalMinutes,
    String? startTime,
    String? endTime,
  }) {
    return RealityCheckSchedule(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  factory RealityCheckSchedule.fromJson(Map<String, dynamic> json) {
    return RealityCheckSchedule(
      id: json['id'] as String?,
      enabled: json['is_active'] as bool? ?? true,
      intervalMinutes: json['interval_minutes'] as int? ?? 240,
      startTime: json['start_time'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? '20:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'is_active': enabled,
      'interval_minutes': intervalMinutes,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
