import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:startap/services/api/StringApi.dart';

class PhotoService {
 static Future<Map<String, dynamic>?> analyzePhoto(File imageFile) async {
  try {
    final bytes = await imageFile.readAsBytes();
    debugPrint('📸 Отправляю фото: ${bytes.length} байт на ${StringApi.apiPhoto}');

    final response = await http.post(
      Uri.parse(StringApi.apiPhoto),
      headers: {'Content-Type': 'image/jpeg'},
      body: bytes,
    );

    debugPrint('📸 Статус: ${response.statusCode}');
    debugPrint('📸 Ответ: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data is List ? data[0] : data;

      if (result['success'] == true && result['parsed'] == true) {
        final dishes = result['dishes'] as List;
        final total = result['total'] as Map<String, dynamic>;
        final firstName = dishes.isNotEmpty
            ? (dishes[0]['dish'] ?? 'Блюдо')
            : 'Блюдо';

        return {
          'meal_name': firstName,
          'calories': (total['calories'] as num?)?.toInt() ?? 0,
          'protein': (total['protein'] as num?)?.toInt() ?? 0,
          'carbs': (total['carbs'] as num?)?.toInt() ?? 0,
          'fats': (total['fats'] as num?)?.toInt() ?? 0,
          'dishes': dishes,
        };
      } else {
        debugPrint('📸 Парсинг не удался: success=${result['success']}, parsed=${result['parsed']}');
      }
    }
  } catch (e, stack) {
    debugPrint('📸 ОШИБКА: $e');
    debugPrint('📸 Stack: $stack');
  }
  return null;
}

}
