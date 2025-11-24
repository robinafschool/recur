/// Model representing a journal entry with metadata
class JournalEntry {
  final String date;
  final String time;
  final String preview;
  final List<String> tags;

  JournalEntry({
    required this.date,
    required this.time,
    required this.preview,
    required this.tags,
  });
}

