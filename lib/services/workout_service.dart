import '../models/workout.dart';
import '../data/mock_data.dart';

class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();

  factory WorkoutService() {
    return _instance;
  }

  WorkoutService._internal();

  List<Workout> _workouts = [];

  Future<void> initWorkouts() async {
    _workouts = MockData.getMockWorkouts();
  }

  List<Workout> getWorkouts() => _workouts;

  Future<Workout> generateWorkoutPlan(String intensity) async {
    await Future.delayed(Duration(seconds: 1));

    final workouts = MockData.getMockWorkouts();
    return workouts.first;
  }

  Future<void> completeWorkout(String workoutId) async {
    final index = _workouts.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      _workouts[index] = _workouts[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
    }
  }

  int getTodayWorkoutMinutes() {
    final today = DateTime.now();
    return _workouts
        .where((w) =>
            w.completedAt != null &&
            w.completedAt!.day == today.day &&
            w.completedAt!.month == today.month)
        .fold(0, (sum, w) => sum + w.durationMinutes);
  }

  Workout? getTodayWorkout() {
    final today = DateTime.now();
    return _workouts.firstWhere(
      (w) =>
          w.scheduledFor != null &&
          w.scheduledFor!.day == today.day &&
          !w.isCompleted,
      orElse: () => _workouts.isNotEmpty ? _workouts.first : _workouts.first,
    );
  }
  
  Workout copyWithUpdates(Workout workout, {
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Workout(
      id: workout.id,
      name: workout.name,
      description: workout.description,
      type: workout.type,
      difficulty: workout.difficulty,
      durationMinutes: workout.durationMinutes,
      estimatedCalories: workout.estimatedCalories,
      exercises: workout.exercises,
      scheduledFor: workout.scheduledFor,
      completedAt: completedAt ?? workout.completedAt,
      isCompleted: isCompleted ?? workout.isCompleted,
      notes: workout.notes,
    );
  }
}
