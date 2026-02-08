/// Database row model for a journal entry (dream).
class JournalEntryRecord {
  final String id;
  final String userId;
  final String content;
  final String date;
  final String? time;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  JournalEntryRecord({
    required this.id,
    required this.userId,
    required this.content,
    required this.date,
    this.time,
    this.metadata,
    this.createdAt,
  });

  factory JournalEntryRecord.fromJson(Map<String, dynamic> json) {
    return JournalEntryRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      time: json['time'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'date': date,
      'time': time,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          content == other.content &&
          date == other.date &&
          time == other.time;

  @override
  int get hashCode => Object.hash(id, userId, content, date, time);
}
