import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdaptationService {
  // Замените URL на свой, если нужно
  static const String adaptUrl = 'https://n8n.nexusfit.ru/webhook/adapt';

  static Future<bool> adaptTodayWorkout({
    required String email,
    required List<String> circumstances,
    required String customText,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String todayKey = DateTime.now().toIso8601String().split('T')[0];
      
      // Читаем весь 30-дневный календарь из кэша
      final String? rawJson = prefs.getString('calendar_workouts');
      if (rawJson == null) {
        debugPrint('Календарь пуст, нечего адаптировать');
        return false;
      }
      
      Map<String, dynamic> calendarCache = jsonDecode(rawJson);
      
      // Достаем тренировку конкретно на сегодня
      if (!calendarCache.containsKey(todayKey)) {
        debugPrint('На сегодня тренировки нет в кэше');
        return false;
      }
      final currentWorkout = calendarCache[todayKey];

      // Отправляем запрос в n8n
      final response = await http.post(
        Uri.parse(adaptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'circumstances': circumstances,
          'custom_text': customText,
          'current_workout': currentWorkout // Отдаем ИИ саму тренировку!
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['adapted_workout'] != null) {
          
          // ЗАМЕНЯЕМ тренировку на сегодня новым ответом ИИ
          calendarCache[todayKey] = data['adapted_workout'];
          
          // Сохраняем весь календарь обратно в память
          await prefs.setString('calendar_workouts', jsonEncode(calendarCache));
          
          // Для совместимости с виджетом главной карточки, перезаписываем одиночные ключи
          await prefs.setString('workout_date', todayKey);
          await prefs.setString('workout_yaml', jsonEncode(data['adapted_workout']));
          
          return true;
        } else {
          debugPrint('Ошибка адаптации от сервера: ${data['error']}');
        }
      } else {
        debugPrint('HTTP ошибка адаптации: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка адаптации (сеть/кэш): $e');
    }
    return false;
  }
}
