class Meal {
  final String id;
  final String name;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final DateTime consumedAt;
  final String? imageUrl;
  final String mealType;
  final List<FoodItem> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.consumedAt,
    required this.mealType,
    this.imageUrl,
    this.ingredients = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      fiber: json['fiber'].toDouble(),
      sugar: json['sugar'].toDouble(),
      consumedAt: DateTime.parse(json['consumedAt']),
      mealType: json['mealType'],
      imageUrl: json['imageUrl'],
      ingredients: (json['ingredients'] as List?)
          ?.map((item) => FoodItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'consumedAt': consumedAt.toIso8601String(),
      'mealType': mealType,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
    };
  }
}

class FoodItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;

  const FoodItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      caloriesPer100g: json['caloriesPer100g'].toDouble(),
      proteinPer100g: json['proteinPer100g'].toDouble(),
      carbsPer100g: json['carbsPer100g'].toDouble(),
      fatsPer100g: json['fatsPer100g'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatsPer100g': fatsPer100g,
    };
  }

  double get totalCalories => (caloriesPer100g * quantity) / 100;
  double get totalProtein => (proteinPer100g * quantity) / 100;
  double get totalCarbs => (carbsPer100g * quantity) / 100;
  double get totalFats => (fatsPer100g * quantity) / 100;
}

class NutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final int goalCalories;
  final int goalProtein;
  final int goalCarbs;
  final int goalFats;
  final DateTime date;

  const NutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.goalCalories,
    required this.goalProtein,
    required this.goalCarbs,
    required this.goalFats,
    required this.date,
  });

  double get caloriesProgress => totalCalories / goalCalories;
  double get proteinProgress => totalProtein / goalProtein;
  double get carbsProgress => totalCarbs / goalCarbs;
  double get fatsProgress => totalFats / goalFats;

  int get remainingCalories => (goalCalories - totalCalories).round();
  int get remainingProtein => (goalProtein - totalProtein).round();
  int get remainingCarbs => (goalCarbs - totalCarbs).round();
  int get remainingFats => (goalFats - totalFats).round();
}
