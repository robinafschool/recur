import 'package:flutter_test/flutter_test.dart';
import 'package:recur/models/journal_entry_record.dart';

void main() {
  group('JournalEntryRecord', () {
    test('fromJson parses API response', () {
      final json = {
        'id': 'id-1',
        'user_id': 'user-1',
        'content': 'Dream content',
        'date': '2025-02-08',
        'time': '14:30:00',
        'metadata': {'dream_index': 0},
        'created_at': '2025-02-08T14:30:00Z',
      };
      final record = JournalEntryRecord.fromJson(json);
      expect(record.id, 'id-1');
      expect(record.userId, 'user-1');
      expect(record.content, 'Dream content');
      expect(record.date, '2025-02-08');
      expect(record.time, '14:30:00');
      expect(record.metadata, {'dream_index': 0});
      expect(record.createdAt, isNotNull);
    });

    test('toJson round-trip', () {
      final record = JournalEntryRecord(
        id: 'id-2',
        userId: 'user-2',
        content: 'Another dream',
        date: '2025-02-07',
        time: null,
        metadata: null,
        createdAt: null,
      );
      final json = record.toJson();
      expect(JournalEntryRecord.fromJson(json).id, record.id);
      expect(JournalEntryRecord.fromJson(json).content, record.content);
    });

    test('equality', () {
      final a = JournalEntryRecord(
        id: 'x',
        userId: 'u',
        content: 'c',
        date: '2025-02-08',
      );
      final b = JournalEntryRecord(
        id: 'x',
        userId: 'u',
        content: 'c',
        date: '2025-02-08',
      );
      expect(a, equals(b));
    });
  });
}
