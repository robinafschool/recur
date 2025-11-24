/// Model representing a scheduled action or habit
class ScheduledAction {
  final String time;
  final String type;
  final String content;
  final String reason;

  ScheduledAction({
    required this.time,
    required this.type,
    required this.content,
    required this.reason,
  });
}

