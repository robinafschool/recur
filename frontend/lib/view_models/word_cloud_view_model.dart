import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

/// Word frequency map from dream content (backend-generated, cached briefly).
final wordCloudProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client.functions.invoke('dream-word-cloud');
  if (response.status != 200) {
    throw Exception(response.data?['error'] ?? 'Failed to load word cloud');
  }
  final data = response.data as Map<String, dynamic>?;
  final words = data?['words'] as Map<String, dynamic>?;
  if (words == null) return {};
  return words.map((k, v) => MapEntry(k, (v as num).toInt()));
});
