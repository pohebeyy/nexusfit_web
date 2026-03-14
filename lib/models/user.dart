class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String goal;
  final String activityLevel;
  final DateTime createdAt;
  final String? avatar;
  final double? bodyFatPercentage;
  final int dailyCalorieGoal;
  final int dailyProteinGoal;
  final int dailyCarbsGoal;
  final int dailyFatsGoal;
  final int dailyStepsGoal;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activityLevel,
    required this.createdAt,
    this.avatar,
    this.bodyFatPercentage,
    this.dailyCalorieGoal = 2000,
    this.dailyProteinGoal = 150,
    this.dailyCarbsGoal = 250,
    this.dailyFatsGoal = 67,
    this.dailyStepsGoal = 10000,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      age: json['age'],
      gender: json['gender'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      goal: json['goal'],
      activityLevel: json['activityLevel'],
      createdAt: DateTime.parse(json['createdAt']),
      avatar: json['avatar'],
      bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
      dailyCalorieGoal: json['dailyCalorieGoal'] ?? 2000,
      dailyProteinGoal: json['dailyProteinGoal'] ?? 150,
      dailyCarbsGoal: json['dailyCarbsGoal'] ?? 250,
      dailyFatsGoal: json['dailyFatsGoal'] ?? 67,
      dailyStepsGoal: json['dailyStepsGoal'] ?? 10000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
      'avatar': avatar,
      'bodyFatPercentage': bodyFatPercentage,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCarbsGoal': dailyCarbsGoal,
      'dailyFatsGoal': dailyFatsGoal,
      'dailyStepsGoal': dailyStepsGoal,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
    String? activityLevel,
    DateTime? createdAt,
    String? avatar,
    double? bodyFatPercentage,
    int? dailyCalorieGoal,
    int? dailyProteinGoal,
    int? dailyCarbsGoal,
    int? dailyFatsGoal,
    int? dailyStepsGoal,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      dailyFatsGoal: dailyFatsGoal ?? this.dailyFatsGoal,
      dailyStepsGoal: dailyStepsGoal ?? this.dailyStepsGoal,
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Недостаточный вес';
    if (bmiValue < 25) return 'Нормальный вес';
    if (bmiValue < 30) return 'Избыточный вес';
    return 'Ожирение';
  }
}
