import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry_record.dart';

/// Repository for journal (dream) entries.
class JournalRepository {
  JournalRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all journal entries for the current user, newest first.
  Future<List<JournalEntryRecord>> getEntriesForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => JournalEntryRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Inserts multiple dream entries for the current user.
  /// [contents] are the dream texts; [date] and [time] are applied with optional per-dream time offset.
  Future<void> insertDreams({
    required List<String> contents,
    required String date,
    required String time,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    for (int i = 0; i < contents.length; i++) {
      final timeOffset = _addSecondsToTime(time, i);
      await _client.from('journal_entries').insert({
        'user_id': user.id,
        'content': contents[i],
        'date': date,
        'time': timeOffset,
        'metadata': {'dream_index': i, 'dream_order': i + 1},
      });
    }
  }

  static String _addSecondsToTime(String time, int secondsToAdd) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1].split('.').first) ?? 0;
    int second = parts.length > 2
        ? int.tryParse(parts[2].split('.').first) ?? 0
        : 0;
    second += secondsToAdd;
    if (second >= 60) {
      minute += second ~/ 60;
      second = second % 60;
    }
    if (minute >= 60) {
      hour += minute ~/ 60;
      minute = minute % 60;
    }
    return '$hour:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }
}
