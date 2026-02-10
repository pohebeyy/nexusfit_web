// providers/health_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/health_data.dart';

class HealthProvider extends ChangeNotifier {
  HealthData? _todayData;
  bool _isLoading = false;

  HealthData? get todayData => _todayData;
  bool get isLoading => _isLoading;

  Future<void> initHealthData() async {
    _isLoading = true;
    notifyListeners();
    
    await loadHealthData();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final dataString = prefs.getString('health_$todayKey');
    
    if (dataString != null) {
      final json = jsonDecode(dataString);
      _todayData = HealthData.fromJson(json);
    } else {
      _todayData = HealthData(date: today);
    }
    
    notifyListeners();
  }

  Future<void> updateHealthData(HealthData newData) async {
    _todayData = newData;
    
    final prefs = await SharedPreferences.getInstance();
    final todayKey = '${newData.date.year}-${newData.date.month}-${newData.date.day}';
    
    await prefs.setString('health_$todayKey', jsonEncode(newData.toJson()));
    
    notifyListeners();
  }

  HealthData? getTodayHealthData() => _todayData;

  String getHealthStatus() {
    if (_todayData == null) return 'Нет данных';
    
    if (_todayData!.steps >= 10000 && 
        _todayData!.waterGlassesConsumed >= 8 && 
        _todayData!.sleepHours >= 7) {
      return 'Отличное состояние!';
    } else if (_todayData!.steps >= 5000) {
      return 'Хорошее состояние';
    }
    return 'Нужно больше активности';
  }
}
