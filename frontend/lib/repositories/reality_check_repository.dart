import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reality_check.dart';

/// Repository for reality check CRUD operations.
class RealityCheckRepository {
  RealityCheckRepository(this._client);

  final SupabaseClient _client;

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
