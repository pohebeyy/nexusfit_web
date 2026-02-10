class DayAnalytics {
  final DateTime date;
  final double progressToGoal;
  final String message;
  final bool isAvailable;
  final String workoutStatus;
  final String workoutName;
  final int workoutDuration;
  final int workoutCalories;
  final String workoutInsight;
  final int sleepHours;
  final int sleepGoal;
  final String sleepInsight;
  final int caloriesIntake;
  final int caloriesGoal;
  final String caloriesInsight;
  final List<String> muscleGroupsWorked;

  DayAnalytics({
    required this.date,
    required this.progressToGoal,
    required this.message,
    required this.isAvailable,
    required this.workoutStatus,
    required this.workoutName,
    required this.workoutDuration,
    required this.workoutCalories,
    required this.workoutInsight,
    required this.sleepHours,
    required this.sleepGoal,
    required this.sleepInsight,
    required this.caloriesIntake,
    required this.caloriesGoal,
    required this.caloriesInsight,
    required this.muscleGroupsWorked,
  });
}
