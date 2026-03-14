import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/data/onboarding_model.dart'; // Твоя старая модель остается

class OnboardingProvider extends ChangeNotifier {
  final OnboardingData _data = OnboardingData();
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  OnboardingData get data => _data;
  int? get age => _age;
  // ==========================================
  // ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ (которых нет в OnboardingData)
  // ==========================================
  int? _age;
  double? _targetWeight;
  String? _targetBodyFat;
  List<String>? _dietRestrictions;
  String? _flexibilityLevel;
  Map<String, String>? _problemAreas;
  Map<String, dynamic>? _sleepData; 
  

  // ==========================================
  // ГЕТТЕРЫ (Чтобы YourStrategyScreen мог читать данные)
  // ==========================================
  double? get currentWeight => _data.weight;
  double? get targetWeight => _targetWeight;
  String? get targetBodyFat => _targetBodyFat;
  List<String>? get targetZones => _data.targetZones;
  String? get trainingLocation => _data.trainingLocation;
  String? get experienceLevel => _data.experience;
  List<String>? get equipment => _data.equipment;
  String? get flexibilityLevel => _flexibilityLevel;
  Map<String, dynamic>? get sleepData => _sleepData;
  List<String>? get dietRestrictions => _dietRestrictions;

  // ==========================================
  // МЕТОДЫ СОХРАНЕНИЯ (Связанные с UI экранами)
  // ==========================================

  void setHasPhoto(bool hasPhoto) {
    _data.hasPhoto = hasPhoto;
    notifyListeners();
  }

  void setGender(String gender) {
    _data.gender = gender;
    notifyListeners();
  }

  void setAge(int age) {
    _age = age;
    notifyListeners();
  }

  void setHeight(double height) {
    _data.height = height;
    notifyListeners();
  }

  // Заменил setWeight на setCurrentWeight (как мы вызываем в B1)
  void setCurrentWeight(double weight) {
    _data.weight = weight;
    notifyListeners();
  }

  void setTargetWeight(double weight) {
    _targetWeight = weight;
    notifyListeners();
  }

  void setTargetBodyFat(String bodyFat) {
    _targetBodyFat = bodyFat;
    notifyListeners();
  }

  void setGoal(String goal) {
    _data.goal = goal;
    notifyListeners();
  }

  void setTargetZones(List<String> zones) {
    _data.targetZones = zones;
    notifyListeners();
  }

  void setTrainingLocation(String location) {
    _data.trainingLocation = location;
    notifyListeners();
  }

  void setEquipment(List<String> equipment) {
    _data.equipment = equipment;
    notifyListeners();
  }

  // Заменил setExperience на setExperienceLevel
  void setExperienceLevel(String experience) {
    _data.experience = experience;
    notifyListeners();
  }

  void setHealthIssues(List<String> issues) {
    _data.healthIssues = issues;
    notifyListeners();
  }

  void setFlexibilityLevel(String level) {
    _flexibilityLevel = level;
    notifyListeners();
  }

  void setProblemAreas(Map<String, String> areas) {
    _problemAreas = areas;
    notifyListeners();
  }

  void setSleepData({
    required String duration,
    required String quality,
    required String schedule,
    required List<String> issues,
  }) {
    _sleepData = {
      'duration': duration,
      'quality': quality,
      'schedule': schedule,
      'issues': issues,
    };
    notifyListeners();
  }

  void setDietRestrictions(List<String> restrictions) {
    _dietRestrictions = restrictions;
    notifyListeners();
  }

  void reset() {
    _data.hasPhoto = false;
    _data.gender = null;
    _data.goal = null;
    _data.targetZones = null;
    _data.height = null;
    _data.weight = null;
    _data.trainingLocation = null;
    _data.equipment = null;
    _data.experience = null;
    _data.healthIssues = null;

    _age = null;
    _targetWeight = null;
    _targetBodyFat = null;
    _dietRestrictions = null;
    _flexibilityLevel = null;
    _problemAreas = null;
    _sleepData = null;
    
    notifyListeners();
  }

  // ==========================================
  // ОТПРАВКА ДАННЫХ В N8N
  // ==========================================
  Future<bool> submitOnboarding() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Получаем email юзера
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');

      if (userEmail == null) {
        print('Ошибка: Email пользователя не найден');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/profilepost');
      print('Отправляем данные онбординга для: $userEmail');

      // 2. Формируем единый JSON со ВСЕМИ собранными данными
      final payload = {
        'email': userEmail,
        'has_photo': _data.hasPhoto,
        
        // Базовые параметры
        'gender': _data.gender ?? 'male',
        'age': _age ?? 25,
        'heightCm': _data.height ?? 170.0, 
        'weightKg': _data.weight ?? 70.0,
        
        // Цели
        'goalText': _data.goal ?? 'general_fitness',
        'targetWeightKg': _targetWeight,
        'targetBodyFat': _targetBodyFat,
        'priority_zones': _data.targetZones ?? [],
        
        // Тренировки
        'experience': _data.experience ?? 'beginner',
        'training_location': _data.trainingLocation ?? 'gym',
        'equipment': _data.equipment ?? [],
        
        // Здоровье и питание
        'injuries': _data.healthIssues ?? [],
        'flexibility': _flexibilityLevel,
        'problem_areas': _problemAreas ?? {},
        'sleep': _sleepData ?? {},
        'diet_restrictions': _dietRestrictions ?? [],
      };

      // 3. Отправляем
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Статус: ${response.statusCode}, Ответ: ${response.body}');

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true; 
      }
      
      _isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      print('Ошибка отправки онбординга: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
