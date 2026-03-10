// ai_coach_provider.dart (добавьте импорт 'package:shared_preferences/shared_preferences.dart')
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
// Ваш импорт StringApi

class AICoachProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void initChat() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        content: 'Привет! Я твой AI-коуч. Как прошла тренировка? Что-то болит или нужна мотивация?',
        isFromUser: false,
      ));
      notifyListeners();
    }
  }

     Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(content: text, isFromUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
      
      // ДОБАВЛЕНО: Достаем тренировку на сегодня
      final String todayKey = DateTime.now().toIso8601String().split('T')[0];
      final String? rawJson = prefs.getString('calendar_workouts');
      List<dynamic> todayExercises = [];

      if (rawJson != null) {
        Map<String, dynamic> calendarCache = jsonDecode(rawJson);
        if (calendarCache.containsKey(todayKey)) {
          // Берем список упражнений (защита от null)
          todayExercises = calendarCache[todayKey]['exercises'] ?? [];
        }
      }

      // ДОБАВЛЕНО: Формируем тело запроса с полем current_workout
      final requestBody = {
        'email': userEmail,
        'message': text,
        'current_workout': todayExercises, 
      };

      final response = await http.post(
        Uri.parse('https://n8n.nexusfit.ru/webhook/chat'), 
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(requestBody), // Отправляем новый body
      );

      // ... (дальше ваш код обработки ответа)


      debugPrint('Статус ответа: ${response.statusCode}');
      debugPrint('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Проверяем все возможные варианты ключей, которые может отдать n8n
        final aiReply = data['response'] ?? 
                        data['aiResponse'] ?? 
                        data['response_text'] ?? 
                        data['message'] ?? 
                        'Извините, я не смог сформулировать ответ.';
                        
        final bool zamena = data['zamena'] ?? false;
        final details = data['zamena_details'];

        _messages.add(ChatMessage(
          content: aiReply.toString(),
          isFromUser: false,
          isReplacement: zamena,
          oldExercise: details?['old_exercise'],
          newExercise: details?['new_exercise'],
        ));
      } else {
        _messages.add(ChatMessage(content: 'Ошибка сервера: ${response.statusCode}', isFromUser: false));
      }
    } catch (e) {
      debugPrint('Ошибка парсинга или сети: $e');
      _messages.add(ChatMessage(content: 'Попробуйте позже', isFromUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // МЕТОД ЗАМЕНЫ УПРАЖНЕНИЯ В КЭШЕ
    Future<void> applyReplacement(ChatMessage message) async {
    if (message.oldExercise == null || message.newExercise == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String todayKey = DateTime.now().toIso8601String().split('T')[0];
    final String? rawJson = prefs.getString('calendar_workouts');
    
    if (rawJson != null) {
      Map<String, dynamic> calendarCache = jsonDecode(rawJson);
      
      if (calendarCache.containsKey(todayKey)) {
        var todayWorkout = calendarCache[todayKey];
        List<dynamic> exercises = todayWorkout['exercises'] ?? [];
        bool isChanged = false;
        
        // Ищем упражнение и заменяем
                // Ищем упражнение и заменяем
        for (int i = 0; i < exercises.length; i++) {
          String cachedName = exercises[i]['name'].toString().toLowerCase();
          String targetName = message.oldExercise!.toLowerCase().trim();

          // Используем .contains() вместо == (если ИИ прислал часть названия)
          // Или наоборот, если ИИ прислал полное название с лишним пробелом
          if (cachedName.contains(targetName) || targetName.contains(cachedName)) {
            
            // Если в оригинале был слэш "/", сохраняем его структуру, меняем только нужную часть
            // Но проще всего просто перезаписать имя на новое, чтобы не ломать UI
            exercises[i]['name'] = message.newExercise;
            
            isChanged = true;
            break; 
          }
        }

        
        if (isChanged) {
          todayWorkout['exercises'] = exercises;
          calendarCache[todayKey] = todayWorkout;
          
          await prefs.setString('calendar_workouts', jsonEncode(calendarCache));
          
          // Отмечаем, что применили, чтобы скрыть кнопку
          message.isApplied = true;
          notifyListeners();
        } else {
          debugPrint("Упражнение ${message.oldExercise} не найдено в кэше.");
        }
      }
    }
  }

}
