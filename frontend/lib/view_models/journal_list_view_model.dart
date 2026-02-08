import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry_record.dart';
import '../providers/providers.dart';

class JournalListNotifier extends AsyncNotifier<List<JournalEntryRecord>> {
  @override
  Future<List<JournalEntryRecord>> build() async {
    final repo = ref.watch(journalRepositoryProvider);
    return repo.getEntriesForCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(journalRepositoryProvider);
      return repo.getEntriesForCurrentUser();
    });
  }
}

final journalListProvider =
    AsyncNotifierProvider<JournalListNotifier, List<JournalEntryRecord>>(
  JournalListNotifier.new,
);
