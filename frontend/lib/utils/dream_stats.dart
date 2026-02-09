import '../models/journal_entry_record.dart';

/// Statistics derived from dream journal entries for analytics and motivation.
class DreamStats {
  const DreamStats({
    required this.totalDreams,
    required this.recordingDays,
    required this.currentStreak,
    required this.avgWordsPerDream,
    required this.dreamsPerDayLast7,
    required this.last7DayLabels,
    required this.dreamsThisWeek,
    required this.dreamsLastWeek,
  });

  final int totalDreams;
  final int recordingDays;
  final int currentStreak;
  final double avgWordsPerDream;
  final List<int> dreamsPerDayLast7;
  final List<String> last7DayLabels;
  final int dreamsThisWeek;
  final int dreamsLastWeek;

  bool get hasData => totalDreams > 0;

  /// Builds stats from the given journal entries (any order).
  static DreamStats fromEntries(List<JournalEntryRecord> entries) {
    if (entries.isEmpty) {
      final now = DateTime.now();
      final labels = List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        return _shortDayLabel(d, i == 6);
      });
      return DreamStats(
        totalDreams: 0,
        recordingDays: 0,
        currentStreak: 0,
        avgWordsPerDream: 0,
        dreamsPerDayLast7: List.filled(7, 0),
        last7DayLabels: labels,
        dreamsThisWeek: 0,
        dreamsLastWeek: 0,
      );
    }

    final totalDreams = entries.length;
    final uniqueDates = entries.map((e) => e.date).toSet();
    final recordingDays = uniqueDates.length;

    int totalWords = 0;
    for (final e in entries) {
      totalWords += _wordCount(e.content);
    }
    final avgWordsPerDream = totalDreams > 0 ? totalWords / totalDreams : 0.0;

    final now = DateTime.now();
    final today = _dateKey(now);
    final currentStreak = _computeStreak(uniqueDates, today);

    final last7Keys = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _dateKey(d);
    });
    final countByDate = <String, int>{};
    for (final e in entries) {
      countByDate[e.date] = (countByDate[e.date] ?? 0) + 1;
    }
    final dreamsPerDayLast7 = last7Keys.map((k) => countByDate[k] ?? 0).toList();
    final last7DayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _shortDayLabel(d, i == 6);
    });

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final todayStart = DateTime(now.year, now.month, now.day);
    int dreamsThisWeek = 0;
    int dreamsLastWeek = 0;
    for (final e in entries) {
      final t = DateTime.tryParse(e.date);
      if (t == null) continue;
      final day = DateTime(t.year, t.month, t.day);
      if (!day.isBefore(thisWeekStart) && !day.isAfter(todayStart)) {
        dreamsThisWeek++;
      } else if (!day.isBefore(lastWeekStart) && day.isBefore(thisWeekStart)) {
        dreamsLastWeek++;
      }
    }

    return DreamStats(
      totalDreams: totalDreams,
      recordingDays: recordingDays,
      currentStreak: currentStreak,
      avgWordsPerDream: avgWordsPerDream,
      dreamsPerDayLast7: dreamsPerDayLast7,
      last7DayLabels: last7DayLabels,
      dreamsThisWeek: dreamsThisWeek,
      dreamsLastWeek: dreamsLastWeek,
    );
  }

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static String _shortDayLabel(DateTime d, bool isToday) {
    if (isToday) return 'Today';
    return '${_weekdays[d.weekday - 1]} ${d.day}';
  }

  static int _wordCount(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  static String _dateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static int _computeStreak(Set<String> uniqueDates, String today) {
    if (uniqueDates.isEmpty) return 0;
    if (!uniqueDates.contains(today)) return 0;
    var d = DateTime.parse(today);
    var count = 0;
    while (true) {
      final key = _dateKey(d);
      if (!uniqueDates.contains(key)) break;
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }
}
