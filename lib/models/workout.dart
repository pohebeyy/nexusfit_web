class Workout {
  final String id;
  final String name;
  final String description;
  final String type;
  final String difficulty;
  final int durationMinutes;
  final int estimatedCalories;
  final List<Exercise> exercises;
  final DateTime? scheduledFor;
  final DateTime? completedAt;
  final bool isCompleted;
  final String? notes;

  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exercises,
    this.scheduledFor,
    this.completedAt,
    this.isCompleted = false,
    this.notes,
  });
  Workout copyWith({
  String? id,
  String? name,
  String? description,
  String? type,
  String? difficulty,
  int? durationMinutes,
  int? estimatedCalories,
  List<Exercise>? exercises,
  DateTime? scheduledFor,
  DateTime? completedAt,
  bool? isCompleted,
  String? notes,
}) {
  return Workout(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    type: type ?? this.type,
    difficulty: difficulty ?? this.difficulty,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    estimatedCalories: estimatedCalories ?? this.estimatedCalories,
    exercises: exercises ?? this.exercises,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    completedAt: completedAt ?? this.completedAt,
    isCompleted: isCompleted ?? this.isCompleted,
    notes: notes ?? this.notes,
  );
}

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      difficulty: json['difficulty'],
      durationMinutes: json['durationMinutes'],
      estimatedCalories: json['estimatedCalories'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      scheduledFor: json['scheduledFor'] != null 
          ? DateTime.parse(json['scheduledFor'])
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'difficulty': difficulty,
      'durationMinutes': durationMinutes,
      'estimatedCalories': estimatedCalories,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final String type;
  final String muscleGroup;
  final int? sets;
  final int? reps;
  final double? weight;
  final int? durationSeconds;
  final int? restSeconds;
  final String? instructions;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.muscleGroup,
    this.sets,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.restSeconds,
    this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      muscleGroup: json['muscleGroup'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      durationSeconds: json['durationSeconds'],
      restSeconds: json['restSeconds'],
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'instructions': instructions,
    };
  }

  bool get isCardio => type == 'cardio';
 String get displayText {
  if (isCardio && durationSeconds != null) {
    return '${durationSeconds! ~/ 60} мин';
  } else if (sets != null && reps != null) {
    if (weight != null) {
      return '$sets x $reps @ ${weight}кг';
    } else {
      return '$sets x $reps';
    }
  }
  return description;
}

}

class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final String goal;
  final String intensity;
  final int durationWeeks;
  final List<Workout> workouts;
  final DateTime createdAt;
  final DateTime? startedAt;
  final bool isActive;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.intensity,
    required this.durationWeeks,
    required this.workouts,
    required this.createdAt,
    this.startedAt,
    this.isActive = false,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      goal: json['goal'],
      intensity: json['intensity'],
      durationWeeks: json['durationWeeks'],
      workouts: (json['workouts'] as List)
          .map((w) => Workout.fromJson(w))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'])
          : null,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'goal': goal,
      'intensity': intensity,
      'durationWeeks': durationWeeks,
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  int get completedWorkouts => workouts.where((w) => w.isCompleted).length;
  double get progressPercentage => workouts.isEmpty ? 0.0 : completedWorkouts / workouts.length;
}
