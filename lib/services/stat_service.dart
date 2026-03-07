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

        // --- ДОБАВЛЕНО ДЛЯ ОТЛАДКИ ---
        // Это покажет в консоли Flutter (Debug Console), какой JSON реально приходит!
        debugPrint('ОТВЕТ СЕРВЕРА (${body['period']} / ${body['date'] ?? ''}): ${response.body}');
        // -----------------------------

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          return StatResponse.fromJson(data);
        } else {
          debugPrint('Сервер вернул success: false. Данные: $data');
        }
      } else {
        debugPrint('Ошибка сервера: статус ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Stat error (_fetch): $e');
    }
    return null;
  }

  // Функция для записи активности (работает так же, как ваш скрипт в PowerShell)
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

      // ДОБАВЛЕНО ДЛЯ ОТЛАДКИ
      debugPrint('ОТВЕТ ПРИ ЗАПИСИ АКТИВНОСТИ: ${response.body}');

      if (response.statusCode == 200) {
        return true; 
      }
      return false;
    } catch (e) {
      debugPrint('Ошибка при отправке активности: $e');
      return false;
    }
  }
}
