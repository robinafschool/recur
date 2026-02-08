import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';
import 'supabase_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(supabaseClientProvider));
});

final realityCheckRepositoryProvider = Provider<RealityCheckRepository>((ref) {
  return RealityCheckRepository(ref.watch(supabaseClientProvider));
});
