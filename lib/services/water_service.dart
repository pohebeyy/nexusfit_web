import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:startap/services/api/StringApi.dart';

class WaterService {
  static Future<bool> logWater(String email, int amountMl) async {
    try {
      final response = await http.post(
        // Замените на реальный URL вашего вебхука воды, если он отличается от StringApi.water
        Uri.parse('https://n8n.nexusfit.ru/webhook/water'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'amount_ml': amountMl,
          'date': DateTime.now().toIso8601String().split('T')[0]
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('Water log error: $e');
    }
    return false;
  }
}
