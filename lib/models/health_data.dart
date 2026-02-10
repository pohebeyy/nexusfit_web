class HealthData {
  String? id;
  DateTime date;
  int steps;
  int heartRate;
  double sleepHours;
  int waterGlassesConsumed;
  double weight;
  int calories;
  int activeMinutes;
  double? stressLevel;
  String? mood;
  int? workoutMinutes;

  HealthData({
    this.id,
    required this.date,
    this.steps = 0,
    this.heartRate = 72,
    this.sleepHours = 7.0,
    this.waterGlassesConsumed = 0,
    this.weight = 75.0,
    this.calories = 0,
    this.activeMinutes = 0,
    this.stressLevel,
    this.mood,
    this.workoutMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'heartRate': heartRate,
      'sleepHours': sleepHours,
      'waterGlassesConsumed': waterGlassesConsumed,
      'weight': weight,
      'calories': calories,
      'activeMinutes': activeMinutes,
      'stressLevel': stressLevel,
      'mood': mood,
      'workoutMinutes': workoutMinutes,
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'],
      date: DateTime.parse(json['date']),
      steps: json['steps'] ?? 0,
      heartRate: json['heartRate'] ?? 72,
      sleepHours: json['sleepHours'] ?? 7.0,
      waterGlassesConsumed: json['waterGlassesConsumed'] ?? 0,
      weight: json['weight'] ?? 75.0,
      calories: json['calories'] ?? 0,
      activeMinutes: json['activeMinutes'] ?? 0,
      stressLevel: json['stressLevel'],
      mood: json['mood'],
      workoutMinutes: json['workoutMinutes'],
    );
  }
}

class BodyAnalysis {
  final String id;
  final DateTime date;
  final double bodyFatPercentage;
  final double muscleMassPercentage;
  final double boneWeight;
  final double waterPercentage;
  final String? photoUrl;
  final Map<String, dynamic> measurements;

  const BodyAnalysis({
    required this.id,
    required this.date,
    required this.bodyFatPercentage,
    required this.muscleMassPercentage,
    required this.boneWeight,
    required this.waterPercentage,
    this.photoUrl,
    this.measurements = const {},
  });

  factory BodyAnalysis.fromJson(Map<String, dynamic> json) {
    return BodyAnalysis(
      id: json['id'],
      date: DateTime.parse(json['date']),
      bodyFatPercentage: json['bodyFatPercentage'].toDouble(),
      muscleMassPercentage: json['muscleMassPercentage'].toDouble(),
      boneWeight: json['boneWeight'].toDouble(),
      waterPercentage: json['waterPercentage'].toDouble(),
      photoUrl: json['photoUrl'],
      measurements: json['measurements'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMassPercentage': muscleMassPercentage,
      'boneWeight': boneWeight,
      'waterPercentage': waterPercentage,
      'photoUrl': photoUrl,
      'measurements': measurements,
    };
  }
}
