import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reality_check.dart';
import '../models/reality_check_schedule.dart';

/// Repository for reality check CRUD operations.
class RealityCheckRepository {
  RealityCheckRepository(this._client);

  final SupabaseClient _client;

  /// Fetches the single schedule for the current user (type='schedule').
  /// Returns a default schedule if none exists.
  Future<RealityCheckSchedule> getScheduleForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const RealityCheckSchedule(
        enabled: false,
        intervalMinutes: 240,
        startTime: '08:00',
        endTime: '20:00',
      );
    }
    final response = await _client
        .from('reality_checks')
        .select()
        .eq('user_id', user.id)
        .eq('type', 'schedule')
        .maybeSingle();
    if (response == null) {
      return const RealityCheckSchedule(
        enabled: false,
        intervalMinutes: 240,
        startTime: '08:00',
        endTime: '20:00',
      );
    }
    return RealityCheckSchedule.fromJson(Map<String, dynamic>.from(response));
  }

  /// Saves the single schedule (upsert: update if id set, else insert).
  Future<void> saveSchedule(RealityCheckSchedule schedule) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final payload = {
      'user_id': user.id,
      'name': 'Schedule',
      'type': 'schedule',
      'interval_minutes': schedule.intervalMinutes,
      'start_time': schedule.startTime,
      'end_time': schedule.endTime,
      'is_active': schedule.enabled,
    };

    if (schedule.id != null && schedule.id!.isNotEmpty) {
      await _client
          .from('reality_checks')
          .update(payload)
          .eq('id', schedule.id!);
    } else {
      await _client.from('reality_checks').insert(payload);
    }
  }

  Future<List<RealityCheck>> getRealityChecksForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('reality_checks')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RealityCheck.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String name,
    required String type,
    int? intervalMinutes,
    String? eventDescription,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _client.from('reality_checks').insert({
      'user_id': user.id,
      'name': name,
      'type': type,
      'interval_minutes': intervalMinutes,
      'event_description': eventDescription,
      'is_active': true,
    });
  }

  Future<void> update({
    required String id,
    required String name,
    required String type,
    int? intervalMinutes,
    String? eventDescription,
  }) async {
    await _client.from('reality_checks').update({
      'name': name,
      'type': type,
      'interval_minutes': intervalMinutes,
      'event_description': eventDescription,
    }).eq('id', id);
  }

  Future<void> setActive(String id, bool isActive) async {
    await _client.from('reality_checks').update({'is_active': isActive}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('reality_checks').delete().eq('id', id);
  }
}
