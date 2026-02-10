import 'package:flutter/material.dart';

class WorkoutExercise {
  final String id;
  final String name;
  final String description;
  final String instructions;
  final String benefits;
  final String muscles;
  final List<String> tags;
  final int sets;
  final int reps;
  final int weight;
  final int estimatedMinutes;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.benefits,
    required this.muscles,
    required this.tags,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.estimatedMinutes,
  });

  get recommendedWeight => null;

  String? get title => null;

  // Добавляем copyWith метод (это нужно для изменения объекта)
  WorkoutExercise copyWith({
    String? id,
    String? name,
    String? description,
    String? instructions,
    String? benefits,
    String? muscles,
    List<String>? tags,
    int? sets,
    int? reps,
    int? weight,
    int? estimatedMinutes,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      benefits: benefits ?? this.benefits,
      muscles: muscles ?? this.muscles,
      tags: tags ?? this.tags,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}
