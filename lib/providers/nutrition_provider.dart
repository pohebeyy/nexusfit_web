import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/nutrition_service.dart';

class NutritionProvider extends ChangeNotifier {
  final _nutritionService = NutritionService();
  List<Meal> _meals = [];
  bool _isLoading = false;

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;

  Future<void> initMeals() async {
    _isLoading = true;
    notifyListeners();
    await _nutritionService.initMeals();
    _meals = _nutritionService.getMeals();
    _isLoading = false;
    notifyListeners();
  }

  Future<Meal> analyzeFoodImage(String imagePath) async {
    _isLoading = true;
    notifyListeners();
    final meal = await _nutritionService.analyzeFoodImage(imagePath);
    _meals = _nutritionService.getMeals();
    _isLoading = false;
    notifyListeners();
    return meal;
  }

  String getNutritionRecommendation(Meal meal) {
    return _nutritionService.getNutritionRecommendation(meal);
  }

  Future<List<String>> scanFridge(List<String> ingredients) async {
    return _nutritionService.scanFridge(ingredients);
  }

  double getTodayCalories() {
    return _nutritionService.calculateTotalCalories(DateTime.now());
  }
}
