class ActivityDay {
  final DateTime date;
  final int steps;
  final int caloriesBurned;
  final int activeMinutes;
  final double distance;
  final bool isCompleted;
  final String workoutName;
  final bool skipped;

  ActivityDay({
    required this.date,
    required this.steps,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.distance,
    required this.isCompleted,
    this.workoutName = 'Тренировка',
    this.skipped = false,
  });
}
