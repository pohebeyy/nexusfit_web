import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionApi {
  static const String _baseUrl = 'https://n8n.nexusfit.ru/webhook';
  static const String _defaultUserId = '1';

  Future<Map<String, dynamic>> analyzeFood(String foodText) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/narution'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({
          'user_id': _defaultUserId,
          'message': foodText,
          'food_text': foodText,
        })),
      );

      debugPrint('>>> nutrition статус: ${response.statusCode}');
      debugPrint('>>> nutrition ответ: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final json = data is List ? data.first : data;
        return json as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('>>> nutrition exception: $e');
    }

    // Фолбэк если сервер недоступен
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
