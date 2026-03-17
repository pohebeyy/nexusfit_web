import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/deep_link_action.dart';

class AICoachProvider extends ChangeNotifier {
  // === СОСТОЯНИЕ ===
  final List<ChatMessage> _messages = [];
  final Map<String, dynamic> _userContext = {};

  bool _isLoading = false;
  bool _isDisposed = false;
  bool _isWaitingForSleepLog = false;

  // флаг для отмены текущего запроса
  bool _cancelRequested = false;

  // === ГЕТТЕРЫ ===
  List<ChatMessage> get messages => _messages;
  Map<String, dynamic> get userContext => _userContext;
  bool get isLoading => _isLoading;

  Future<void> initChat() async {
  _messages.clear();
  _userContext.clear();
  _isWaitingForSleepLog = false;
  _cancelRequested = false;
  _isLoading = false;
  notifyListeners();

  _userContext.addAll({
    'name': 'Алексей',
    'age': 28,
    'lastWorkout': DateTime.now().subtract(const Duration(days: 1)),
    'injuries': ['икра_неделю_назад'],
    'sleepHours': 5,
    'hydration': 'low',
    'motivation': 'medium',
  });

  await Future.delayed(const Duration(milliseconds: 500));
  
  if (_messages.isEmpty) {
    await _checkDailySleepLog();
  }
}


  Future<void> _checkDailySleepLog() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastLoggedDate = prefs.getString('last_sleep_log_date');

    if (lastLoggedDate != today) {
      _isWaitingForSleepLog = true;
      _addBotMessage('Доброе утро! ☀️ Сколько часов ты спал сегодня?');
    } else if (_messages.isEmpty) {
      _addBotMessage('Привет! Готов к тренировке? 💪');
    }
  }

  // === ОТПРАВКА СООБЩЕНИЯ ===
  Future<void> sendMessage(String userMessage) async {
    if (_isDisposed) return;

    // запрет на параллельные запросы
    if (_isLoading) return;

    // добавляем сообщение пользователя
    _addUserMessage(userMessage);

    // сон
    final sleepHours = _extractSleepHours(userMessage);
    if (sleepHours != null) {
      _isWaitingForSleepLog = false;
      await _handleSleepLogInput(sleepHours);
      return;
    }

    if (_isWaitingForSleepLog) {
      _isWaitingForSleepLog = false;
    }

    await _sendChatMessageToNetwork(userMessage);
  }

  // === ОТМЕНА ТЕКУЩЕГО ЗАПРОСА ===
  void cancelCurrentRequest() {
    if (!_isLoading) return;
    _cancelRequested = true;
    _setLoading(false);

    _messages.add(ChatMessage(
      id: _generateId(),
      content: 'Запрос отменён',
      isFromUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // === УМНЫЙ ПАРСЕР СНА ===
  double? _extractSleepHours(String text) {
    final textLower = text.toLowerCase();

    final match = RegExp(r'\d+([.,]\d+)?').firstMatch(textLower);
    if (match == null) return null;

    final double hours =
        double.parse(match.group(0)!.replaceAll(',', '.'));
    final hasSleepKeywords =
        textLower.contains(RegExp(r'(сон|спал|спала|выспался|сном)'));

    if (_isWaitingForSleepLog &&
        (textLower.length <= 20 || hasSleepKeywords)) {
      return hours;
    }

    if (hasSleepKeywords && textLower.length <= 40) {
      return hours;
    }

    return null;
  }

  // === ЛОКАЛЬНАЯ ЛОГИКА СНА ===
  Future<void> _handleSleepLogInput(double hours) async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_sleep_log_date', todayDate);
      await prefs.setDouble('last_sleep_hours', hours);

      if (hours < 6.0) {
        final workoutModified =
            await _reduceTodayWorkoutIntensityLocally();

        if (workoutModified) {
          _addBotMessageWithReplacement(
            text:
                'Я вижу, что ты спал всего $hours ч. Твоя ЦНС не восстановилась. '
                'Я автоматически облегчил твою сегодняшнюю тренировку, чтобы не словить перетрен.',
            oldEx: 'Обычный план',
            newEx: 'Облегченный план (-20% нагрузки)',
          );
        } else {
          _addBotMessage(
            'Ты спал маловато ($hours ч). У тебя сегодня день отдыха, так что просто восстанавливайся!',
          );
        }
      } else if (hours >= 6.0 && hours <= 7.0) {
        _addBotMessage(
          'Ты спал $hours ч. Это приемлемо, но старайся спать около 8 часов. '
          'Тренировку оставляем по плану, но следи за самочувствием.',
        );
      } else {
        _addBotMessage(
          'Отличный сон ($hours ч)! 🚀 Твоя ЦНС полностью восстановлена, '
          'сегодня можно выкладываться на 100%!',
        );
      }
    } catch (e) {
      debugPrint('Ошибка обработки сна: $e');
      _addBotMessage('Понял, записал! Учту это в твоем прогрессе.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _reduceTodayWorkoutIntensityLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      final rawCalendar = prefs.getString('calendar_workouts');

      if (rawCalendar == null) return false;

      final Map<String, dynamic> calendarCache =
          jsonDecode(rawCalendar);

      if (!calendarCache.containsKey(todayDate)) return false;

      var todayWorkout = calendarCache[todayDate];
      List<dynamic> exercises =
          todayWorkout['exercises'] ?? [];

      if (exercises.isEmpty) return false;

      for (int i = 0; i < exercises.length; i++) {
        String display = exercises[i]['display_string'] ?? '';
        if (!display.contains('x')) continue;

        final parts = display.split('x');
        int reps = int.tryParse(parts[0]) ?? 0;
        int sets = int.tryParse(parts[1]) ?? 0;

        if (sets > 1) {
          sets -= 1;
        } else if (reps > 8) {
          reps -= 4;
        }

        exercises[i]['display_string'] = '${reps}x$sets';
        exercises[i]['reps'] = reps.toString();
        exercises[i]['sets'] = sets.toString();
      }

      todayWorkout['difficulty'] = 'easy';
      todayWorkout['workout_name'] =
          '${todayWorkout['workout_name']} (Лайт)';

      calendarCache[todayDate] = todayWorkout;
      await prefs.setString(
          'calendar_workouts', jsonEncode(calendarCache));

      return true;
    } catch (e) {
      debugPrint('Ошибка снижения интенсивности: $e');
      return false;
    }
  }

  // === ЛОГИКА ЧАТА (n8n webhook) ===
  Future<void> _sendChatMessageToNetwork(String userMessage) async {
    _setLoading(true);
    _cancelRequested = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail =
          prefs.getString('user_email') ?? 'akk@gmail.com';

      List<dynamic> currentWorkout = [];
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      final rawCalendar = prefs.getString('calendar_workouts');

      if (rawCalendar != null) {
        final Map<String, dynamic> calendarCache =
            jsonDecode(rawCalendar);
        if (calendarCache.containsKey(todayDate)) {
          currentWorkout =
              calendarCache[todayDate]['exercises'] ?? [];
        }
      }

      final response = await http.post(
        Uri.parse('https://n8n.nexusfit.ru/webhook/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'message': userMessage,
          'current_workout': currentWorkout,
        }),
      );

      if (_isDisposed || _cancelRequested) return;

      if (response.statusCode != 200) {
        throw Exception(
            'Ошибка сервера чата: ${response.statusCode}');
      }

      dynamic raw;
      try {
        raw = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Некорректный JSON от сервера');
      }

      Map<String, dynamic> data;
      if (raw is List && raw.isNotEmpty && raw.first is Map) {
        data = raw.first as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        data = raw;
      } else {
        throw Exception('Некорректный JSON от сервера');
      }

      final aiText = data['response']?.toString() ??
          data['aiResponse']?.toString() ??
          'Я тебя понял.';
      final bool isZamena = data['zamena'] == true;
      final zamenaDetails = data['zamena_details'];

      if (isZamena && zamenaDetails != null) {
        final oldEx =
            zamenaDetails['old_exercise']?.toString() ?? 'Старое';
        final newEx =
            zamenaDetails['new_exercise']?.toString() ?? 'Новое';

        _addBotMessageWithReplacement(
          text: aiText,
          oldEx: oldEx,
          newEx: newEx,
        );
      } else {
        _addBotMessage(aiText);
      }
    } catch (e) {
      debugPrint('Ошибка отправки сообщения в чат: $e');
      if (!_isDisposed && !_cancelRequested) {
        _addBotMessage(
          'Извини, сейчас нет связи с сервером 📡 Попробуй чуть позже.',
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // === ПРИМЕНЕНИЕ ЗАМЕНЫ ===
  void applyReplacement(ChatMessage message) async {
    if (message.oldExercise == null || message.newExercise == null) return;

    final prefs = await SharedPreferences.getInstance();
    final todayDate = DateTime.now().toIso8601String().split('T')[0];
    final rawCalendar = prefs.getString('calendar_workouts');

    if (rawCalendar == null) return;

    final Map<String, dynamic> calendarCache =
        jsonDecode(rawCalendar);

    if (!calendarCache.containsKey(todayDate)) return;

    final exercises =
        calendarCache[todayDate]['exercises'] as List<dynamic>;

    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i]['name'] == message.oldExercise) {
        exercises[i]['name'] = message.newExercise;
      }
    }

    await prefs.setString(
        'calendar_workouts', jsonEncode(calendarCache));

    message.isApplied = true;
    notifyListeners();
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _addUserMessage(String text) {
    _messages.add(ChatMessage(
      id: _generateId(),
      content: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _addBotMessage(String text) {
    _messages.add(ChatMessage(
      id: _generateId(),
      content: text,
      isFromUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _addBotMessageWithReplacement({
    required String text,
    required String oldEx,
    required String newEx,
  }) {
    _messages.add(ChatMessage(
      id: _generateId(),
      content: text,
      isFromUser: false,
      timestamp: DateTime.now(),
      isReplacement: true,
      oldExercise: oldEx,
      newExercise: newEx,
    ));
    notifyListeners();
  }

  String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
