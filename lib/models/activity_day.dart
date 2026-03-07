class ActivityDay {
  final DateTime date;
  final int steps;
  final int caloriesBurned;
  final int activeMinutes;
  final double distance;
  final bool isCompleted;
  final bool skipped;
  final String workoutName;
  final List<Map<String, String>> exercises; // НОВОЕ ПОЛЕ

  ActivityDay({
    required this.date,
    required this.steps,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.distance,
    required this.isCompleted,
    required this.skipped,
    required this.workoutName,
    this.exercises = const [], // НОВОЕ ПОЛЕ (по умолчанию пустой список)
  });
}
