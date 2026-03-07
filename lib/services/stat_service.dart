import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:startap/models/stat_response.dart';
import 'package:startap/services/api/StringApi.dart';

class StatService {
  static Future<StatResponse?> fetchMonthStats(String email) async {
    return _fetch({'email': email, 'period': 'month'});
  }

  static Future<StatResponse?> fetchDayStats(String email, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    return _fetch({'email': email, 'period': 'day', 'date': dateStr});
  }

  static Future<StatResponse?> _fetch(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(StringApi.stat),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        // Проверка на пустой ответ сервера
        if (response.body.trim().isEmpty) return null;

        // Декодируем как Map (объект), а не List (список)
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          return StatResponse.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('Stat error: $e');
    }
    return null;
  }
  static Future<bool> logActivity({
    required String email,
    required int userId,
    required int steps,
    required int activeCalories,
    required int activeMinutes,
    required int heartRateAvg,
    required DateTime date,
  }) async {
    final url = Uri.parse('https://n8n.nexusfit.ru/webhook/activty');
    
    final body = {
      "email": email,
      "userId": userId,
      "steps": steps,
      "active_calories": activeCalories,
      "active_minutes": activeMinutes,
      "heart_rate_avg": heartRateAvg,
      "date": date.toIso8601String().split('T')[0], // Форматируем в YYYY-MM-DD
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Успешно, сервер вернул: {"success": true, ... }
        return true; 
      }
      return false;
    } catch (e) {
      print('Ошибка при отправке активности: $e');
      return false;
    }
  }
  static Future<Map<String, int>?> fetchDailyActivity(String email, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    try {
      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/day-stats?email=$email&date=$dateStr');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Возвращаем только минуты и калории
          return {
            'active_minutes': data['active_minutes'] ?? 0,
            'active_calories': data['active_calories'] ?? 0,
            'workouts_completed': data['workouts']?['completed'] ?? 0,
          };
        }
      }
    } catch (e) {
      debugPrint('Ошибка получения активности: $e');
    }
    return null;
  }

}
