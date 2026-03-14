import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/services/nutrition_service.dart';


class NutritionProvider extends ChangeNotifier {
  final NutritionApi _api = NutritionApi();

  static const String _cacheKey = 'nutrition_meals_cache';
  static const String _cacheDateKey = 'nutrition_cache_date';

  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCalories =>
      _meals.fold(0, (sum, m) => sum + ((m['calories'] as num?)?.toInt() ?? 0));
  int get totalProtein =>
      _meals.fold(0, (sum, m) => sum + ((m['protein_g'] as num?)?.toInt() ?? 0));
  int get totalFat =>
      _meals.fold(0, (sum, m) => sum + ((m['fat_g'] as num?)?.toInt() ?? 0));
  int get totalCarbs =>
      _meals.fold(0, (sum, m) => sum + ((m['carbs_g'] as num?)?.toInt() ?? 0));

  Future<void> init() async {
    await _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final cachedDate = prefs.getString(_cacheDateKey) ?? '';

    if (cachedDate != today) {
      // Новый день — очищаем кэш
      await prefs.remove(_cacheKey);
      await prefs.setString(_cacheDateKey, today);
      _meals = [];
      notifyListeners();
      return;
    }

    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _meals = list.cast<Map<String, dynamic>>();
        notifyListeners();
      } catch (_) {
        _meals = [];
      }
    }
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_cacheDateKey, today);
    await prefs.setString(_cacheKey, jsonEncode(_meals));
  }

  Future<Map<String, dynamic>?> analyzeFood(String foodText) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.analyzeFood(foodText);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> addMeal(Map<String, dynamic> meal) async {
    final now = TimeOfDay.now();
    final entry = {
      'meal_name': meal['meal_name'] ?? 'Еда',
      'calories':  (meal['calories'] as num?)?.toInt() ?? 0,
      'protein_g': (meal['protein_g'] as num?)?.toInt() ?? 0,
      'fat_g':     (meal['fat_g'] as num?)?.toInt() ?? 0,
      'carbs_g':   (meal['carbs_g'] as num?)?.toInt() ?? 0,
      'ai_message': meal['ai_message'] ?? '',
      'emoji':     meal['emoji'] ?? '🍽️',
      'mealType':  _getMealTypeByTime(now),
      'dt':        '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'added_at':  DateTime.now().toIso8601String(),
    };

    _meals.insert(0, entry);
    await _saveToCache();
    notifyListeners();
  }

  Future<void> removeMeal(int index) async {
    if (index < 0 || index >= _meals.length) return;
    _meals.removeAt(index);
    await _saveToCache();
    notifyListeners();
  }

  String _getMealTypeByTime(TimeOfDay time) {
    final h = time.hour;
    if (h >= 5 && h < 12) return 'breakfast';
    if (h >= 12 && h < 17) return 'lunch';
    return 'dinner';
  }
}
