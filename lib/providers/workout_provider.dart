import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final _workoutService = WorkoutService();
  List<Workout> _workouts = [];
  bool _isLoading = false;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;

  Future<void> initWorkouts() async {
    _isLoading = true;
    notifyListeners();
    await _workoutService.initWorkouts();
    _workouts = _workoutService.getWorkouts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateWorkoutPlan(String intensity) async {
    _isLoading = true;
    notifyListeners();
    final workout = await _workoutService.generateWorkoutPlan(intensity);
    _workouts.add(workout);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeWorkout(String workoutId) async {
    await _workoutService.completeWorkout(workoutId);
    _workouts = _workoutService.getWorkouts();
    notifyListeners();
  }

  int getTodayWorkoutMinutes() {
    return _workoutService.getTodayWorkoutMinutes();
  }

  Workout? getTodayWorkout() {
    return _workoutService.getTodayWorkout();
  }

  void saveExerciseRpe({required sessionId, required String exerciseId, required int rpe, required int durationSeconds}) {}
}
