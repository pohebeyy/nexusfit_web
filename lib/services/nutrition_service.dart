import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NutritionApi {
  static const String _baseUrl = 'https://n8n.nexusfit.ru/webhook';

  Future<Map<String, dynamic>> analyzeFood(String foodText) async {
    try {
      // --- ДОСТАЕМ ПОЧТУ ИЗ КЭША ---
      final prefs = await SharedPreferences.getInstance();
      final String userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
      debugPrint('Текущая почта для отправки питания: $userEmail');
      // -----------------------------

      final response = await http.post(
        Uri.parse('$_baseUrl/narution'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({
          'email': userEmail,     // Подставляем найденную почту
          'food_text': foodText,  // Текст еды
        })),
      );

      debugPrint('>>> nutrition статус: ${response.statusCode}');
      debugPrint('>>> nutrition ответ: ${response.body}');

      if (response.statusCode == 200) {
        // Защита от пустого ответа, чтобы избежать краша (FormatException)
        if (response.body.trim().isEmpty) {
          throw Exception('Сервер вернул пустой ответ (200 OK)');
        }

        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final json = data is List ? data.first : data;
        return json as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('>>> nutrition exception: $e');
    }

    // Фолбэк, если сервер недоступен или выдал ошибку
    return {
      'meal_name': foodText,
      'calories': 0,
      'protein_g': 0,
      'fat_g': 0,
      'carbs_g': 0,
      'ai_message': 'Не удалось получить данные от сервера',
    };
  }
}
