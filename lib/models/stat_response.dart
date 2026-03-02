class StatResponse {
  final String period;
  final String date;
  final int totalCalories;
  final double avgCaloriesPerMeal;
  final int totalMeals;
  final double totalWaterLiters;
  final double avgWaterLiters;
  final int totalWaterLogs;
  final int sleepTotalLogs;
  final double sleepAvgHours;
  final double sleepTotalHours;
  final int workoutsTotal;
  final int workoutsCompleted;
  final double workoutsAvgDuration;
  final int workoutsTotalMinutes;

  StatResponse({
    required this.period,
    required this.date,
    required this.totalCalories,
    required this.avgCaloriesPerMeal,
    required this.totalMeals,
    required this.totalWaterLiters,
    required this.avgWaterLiters,
    required this.totalWaterLogs,
    required this.sleepTotalLogs,
    required this.sleepAvgHours,
    required this.sleepTotalHours,
    required this.workoutsTotal,
    required this.workoutsCompleted,
    required this.workoutsAvgDuration,
    required this.workoutsTotalMinutes,
  });

  factory StatResponse.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutrition'] as Map<String, dynamic>;
    final water     = json['water']     as Map<String, dynamic>;
    final sleep     = json['sleep']     as Map<String, dynamic>;
    final workouts  = json['workouts']  as Map<String, dynamic>;

    return StatResponse(
      period:              json['period'] ?? 'month',
      date:                json['date']   ?? '',
      totalCalories:       (nutrition['total_calories']        as num).toInt(),
      avgCaloriesPerMeal:  (nutrition['avg_calories_per_meal'] as num).toDouble(),
      totalMeals:          (nutrition['total_meals']           as num).toInt(),
      totalWaterLiters:    (water['total_liters']              as num).toDouble(),
      avgWaterLiters:      (water['avg_liters']                as num).toDouble(),
      totalWaterLogs:      (water['total_logs']                as num).toInt(),
      sleepTotalLogs:      (sleep['total_logs']                as num).toInt(),
      sleepAvgHours:       (sleep['avg_hours']                 as num).toDouble(),
      sleepTotalHours:     (sleep['total_hours']               as num).toDouble(),
      workoutsTotal:       (workouts['total']                  as num).toInt(),
      workoutsCompleted:   (workouts['completed']              as num).toInt(),
      workoutsAvgDuration: (workouts['avg_duration']           as num).toDouble(),
      workoutsTotalMinutes:(workouts['total_minutes']          as num).toInt(),
    );
  }
}
