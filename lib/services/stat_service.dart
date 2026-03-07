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
}
