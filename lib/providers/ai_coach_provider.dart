import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../services/api/StringApi.dart';

class AICoachProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // Инициализация (например, приветственное сообщение от бота)
  void initChat() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        content: 'Привет! Я твой AI-коуч. Как прошла тренировка? Что-то болит или нужна мотивация?',
        isFromUser: false,
      ));
      notifyListeners();
    }
  }

  // Метод отправки сообщения
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Добавляем сообщение пользователя в UI
    _messages.add(ChatMessage(
      content: text,
      isFromUser: true,
    ));
    _isLoading = true;
    notifyListeners(); // Обновляем UI, показываем анимацию загрузки

    try {
      // 2. Отправляем запрос в n8n
      final response = await http.post(
        Uri.parse(StringApi.apichat),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'email': 'akk@gmail.com',
          'message': text,
        }),
      );

      if (response.statusCode == 200) {
        // Парсим ответ (с учетом кодировки UTF-8 для корректного отображения кириллицы)
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // В нашем n8n ответ ИИ лежит в поле "aiResponse"
        final aiReply =
          data['aiResponse'] ??
          data['response_text'] ??
          data['response'] ??
          data['message'] ??
          'Извините, я не смог сформулировать ответ.';

        // 3. Добавляем ответ бота в UI
        _messages.add(ChatMessage(
          content: aiReply,
          isFromUser: false,
        ));
      } else {
        _messages.add(ChatMessage(
          content: 'Ошибка сервера. Код: ${response.statusCode}',
          isFromUser: false,
        ));
      }
    } catch (e) {
      debugPrint('Ошибка сети: $e');
      _messages.add(ChatMessage(
        content: 'Проблема с подключением. Проверьте интернет или включите сервер.',
        isFromUser: false,
      ));
    } finally {
      // Отключаем индикатор загрузки
      _isLoading = false;
      notifyListeners();
    }
  }
}
