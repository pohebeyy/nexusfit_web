import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionApi {
  static const String _baseUrl = 'https://n8n.nexusfit.ru/webhook';
  
  // Пока хардкодим почту. Позже вы сможете брать её из SharedPreferences или провайдера авторизации
  static const String _userEmail = 'akk@gmail.com'; 

  Future<Map<String, dynamic>> analyzeFood(String foodText) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/narution'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({
          'email': _userEmail,     // Оставили только email
          'food_text': foodText,   // И текст еды
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
