import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/journal_repository.dart';
import '../providers/providers.dart';

/// UI state for the new journal entry screen.
class JournalEntryState {
  const JournalEntryState({this.isSaving = false});

  final bool isSaving;

  JournalEntryState copyWith({bool? isSaving}) {
    return JournalEntryState(isSaving: isSaving ?? this.isSaving);
  }
}

class JournalEntryViewModel extends StateNotifier<JournalEntryState> {
  JournalEntryViewModel(this._repo) : super(const JournalEntryState());

  final JournalRepository _repo;

  Future<void> saveDreams(List<String> contents) async {
    if (contents.isEmpty) return;
    state = state.copyWith(isSaving: true);
    try {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      final dateStr = date.toIso8601String().split('T')[0];
      final timeStr = now.toIso8601String().split('T')[1].split('.')[0];
      await _repo.insertDreams(
        contents: contents,
        date: dateStr,
        time: timeStr,
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final journalEntryViewModelProvider =
    StateNotifierProvider<JournalEntryViewModel, JournalEntryState>((ref) {
  return JournalEntryViewModel(ref.watch(journalRepositoryProvider));
});