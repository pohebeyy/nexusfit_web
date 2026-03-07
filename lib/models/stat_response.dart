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
    final nutrition = json['nutrition'] as Map<String, dynamic>? ?? {};
    final water = json['water'] as Map<String, dynamic>? ?? {};
    final sleep = json['sleep'] as Map<String, dynamic>? ?? {};
    final workouts = json['workouts'] as Map<String, dynamic>? ?? {};

    return StatResponse(
      period: json['period'] ?? 'month',
      date: json['date'] ?? '',
      // Исправляем ключи здесь: добавляем подчеркивания!
      totalCalories: (nutrition['total_calories'] as num?)?.toInt() ?? 0,
      avgCaloriesPerMeal: (nutrition['avg_calories_per_meal'] as num?)?.toDouble() ?? 0.0,
      totalMeals: (nutrition['total_meals'] as num?)?.toInt() ?? 0,
      
      totalWaterLiters: (water['total_liters'] as num?)?.toDouble() ?? 0.0,
      avgWaterLiters: (water['avg_liters'] as num?)?.toDouble() ?? 0.0,
      totalWaterLogs: (water['total_logs'] as num?)?.toInt() ?? 0,
      
      sleepTotalLogs: (sleep['total_logs'] as num?)?.toInt() ?? 0,
      sleepAvgHours: (sleep['avg_hours'] as num?)?.toDouble() ?? 0.0,
      sleepTotalHours: (sleep['total_hours'] as num?)?.toDouble() ?? 0.0,
      
      workoutsTotal: (workouts['total'] as num?)?.toInt() ?? 0,
      workoutsCompleted: (workouts['completed'] as num?)?.toInt() ?? 0,
      workoutsAvgDuration: (workouts['avg_duration'] as num?)?.toDouble() ?? 0.0,
      workoutsTotalMinutes: (workouts['total_minutes'] as num?)?.toInt() ?? 0,
    );
  }

}
