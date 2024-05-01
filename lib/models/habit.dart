class Habit {
  int habitId;
  String name;
  int goal;
  int status;
  int completed;
  String description;
  int totalTimesDone;
  int longestStreak;
  int daysBetweenLast;
  String dateStarted;

  Habit({
    required this.completed,
    required this.habitId,
    required this.name,
    required this.goal,
    required this.status,
    required this.description,
    required this.totalTimesDone,
    required this.longestStreak,
    required this.daysBetweenLast,
    required this.dateStarted,
  });

  Map<String, Object?> toMap() {
    return {
      "name": name,
      "goal": goal,
      "status": status,
      "completed": 0,
      "description": description,
      "totalTimesDone": totalTimesDone,
      "longestStreak": longestStreak,
      "daysBetweenLast": daysBetweenLast,
      "dateStarted": dateStarted.toString(),
    };
  }
}
