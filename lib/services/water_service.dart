import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WaterService {
  static Future<bool> logWater(int amountMl) async {
    try {
      // --- ДОСТАЕМ ПОЧТУ ИЗ КЭША ---
      final prefs = await SharedPreferences.getInstance();
      final String userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
      debugPrint('Текущая почта для записи воды: $userEmail');
      // -----------------------------

      final response = await http.post(
        Uri.parse('https://n8n.nexusfit.ru/webhook/water'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail, // Подставляем почту из кэша
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
