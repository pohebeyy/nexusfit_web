import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart'; // Убедитесь, что этот импорт правильный для вашего проекта
import '../models/deep_link_action.dart'; // Если у вас нет этого файла, скажите, я напишу его код

class AICoachProvider extends ChangeNotifier {
  // === СОСТОЯНИЕ ===
  final List<ChatMessage> _messages = [];
  final Map<String, dynamic> _userContext = {};
  
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _isWaitingForSleepLog = false;

  // === ГЕТТЕРЫ ===
  List<ChatMessage> get messages => _messages;
  Map<String, dynamic> get userContext => _userContext;
  bool get isLoading => _isLoading;

  // Вспомогательный метод для старого кода, где ожидался List<Map>
  // Если у вас где-то используется _chatHistory как Map, мы конвертируем его
  List<Map<String, dynamic>> get _chatHistory {
    return _messages.map((m) => {
      'id': m.id,
      'text': m.content,
      'isMe': m.isFromUser,
      // Добавьте остальные поля, если нужно
    }).toList();
  }

  // === ИНИЦИАЛИЗАЦИЯ ===
  Future<void> initChat() async {
    _messages.clear();
    _userContext.clear();
    _isWaitingForSleepLog = false;
    notifyListeners();

    // Симуляция загрузки контекста
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

    // Проверяем, вводил ли пользователь данные о сне сегодня
    await _checkDailySleepLog();
  }

  Future<void> _checkDailySleepLog() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastLoggedDate = prefs.getString('last_sleep_log_date');

    if (lastLoggedDate != today) {
      _isWaitingForSleepLog = true;
      _addBotMessage('Доброе утро! ☀️ Сколько часов ты спал сегодня?');
    } else if (_messages.isEmpty) {
      // Если чат пустой и про сон уже спрашивали, просто здороваемся
      _addBotMessage('Привет! Готов к тренировке? 💪');
    }
  }

  // === ОТПРАВКА СООБЩЕНИЯ ===
    // === ОТПРАВКА СООБЩЕНИЯ ===
    // === ОТПРАВКА СООБЩЕНИЯ ===
  Future<void> sendMessage(String userMessage) async {
    if (_isDisposed) return;

    // 1. Показываем сообщение пользователя
    _addUserMessage(userMessage);

    // 2. Проверяем, есть ли в сообщении данные о сне (даже если мы об этом не спрашивали!)
    final sleepHours = _extractSleepHours(userMessage);

    if (sleepHours != null) {
      // Бот понял, что юзер сообщает о сне
      _isWaitingForSleepLog = false;
      await _handleSleepLogInput(sleepHours);
      return; // Прерываемся, к нейронке не идем
    }

    // Если мы ждали лог сна, но юзер перевел тему (например, нажал кнопку "как накачать пресс"),
    // мы снимаем ожидание сна и отправляем его запрос нейросети.
    if (_isWaitingForSleepLog) {
      _isWaitingForSleepLog = false;
    }

    // 3. Отправляем вопрос в нейросеть
    await _sendChatMessageToNetwork(userMessage);
  }

  // === УМНЫЙ ПАРСЕР СНА ===
  double? _extractSleepHours(String text) {
    final textLower = text.toLowerCase();
    
    // Ищем любую цифру (целую или с точкой/запятой)
    final match = RegExp(r'\d+([.,]\d+)?').firstMatch(textLower);
    if (match == null) return null; // Нет цифр -> точно не про сон
    
    final double hours = double.parse(match.group(0)!.replaceAll(',', '.'));
    
    // Проверяем наличие ключевых слов о сне
    final hasSleepKeywords = textLower.contains(RegExp(r'(сон|спал|спала|выспался|сном)'));
    
    // Сценарий 1: Мы сами только что спросили про сон утром (_isWaitingForSleepLog == true)
    // Юзеру достаточно написать короткий ответ (например "8", "около 7") или любое сообщение со словом "спал"
    if (_isWaitingForSleepLog && (textLower.length <= 20 || hasSleepKeywords)) {
      return hours;
    }
    
    // Сценарий 2: Юзер В ЛЮБОЙ МОМЕНТ сам написал "сон 3 часа" или "я спал 7 часов"
    // Ограничиваем длину сообщения <= 40, чтобы если он задаст длинный вопрос 
    // ("я спал 8 часов, но у меня болит спина, как мне делать становую тягу?"), 
    // этот сложный вопрос ушел к AI-тренеру, а не просто залогировал сон.
    if (hasSleepKeywords && textLower.length <= 40) {
      return hours;
    }
    
    return null;
  }



  // === ЛОГИКА СНА (n8n webhook) ===
    // === ЛОКАЛЬНАЯ ЛОГИКА СНА ===
    // === ЛОКАЛЬНАЯ ЛОГИКА СНА ===
  Future<void> _handleSleepLogInput(double hours) async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Запоминаем, что сегодня уже спрашивали про сон
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_sleep_log_date', todayDate);
      await prefs.setDouble('last_sleep_hours', hours);
      
      // Логика: Если сон меньше 6 часов, мы считаем это недосыпом
      if (hours < 6.0) {
        // Облегчаем тренировку локально
        bool workoutModified = await _reduceTodayWorkoutIntensityLocally();
        
        if (workoutModified) {
          _addBotMessageWithReplacement(
            text: 'Я вижу, что ты спал всего $hours ч. Твоя ЦНС не восстановилась. Я автоматически облегчил твою сегодняшнюю тренировку, чтобы не словить перетрен.',
            oldEx: 'Обычный план',
            newEx: 'Облегченный план (-20% нагрузки)',
          );
        } else {
          _addBotMessage('Ты спал маловато ($hours ч). У тебя сегодня день отдыха, так что просто восстанавливайся!');
        }
      } 
      else if (hours >= 6.0 && hours <= 7.0) {
        _addBotMessage('Ты спал $hours ч. Это приемлемо, но старайся спать около 8 часов. Тренировку оставляем по плану, но следи за самочувствием.');
      } 
      else {
        _addBotMessage('Отличный сон ($hours ч)! 🚀 Твоя ЦНС полностью восстановлена, сегодня можно выкладываться на 100%!');
      }

    } catch (e) {
      debugPrint('Ошибка обработки сна: $e');
      _addBotMessage('Понял, записал! Учту это в твоем прогрессе.');
    } finally {
      _setLoading(false);
    }
  }


  // Метод, который лезет в SharedPreferences, достает сегодняшнюю тренировку и урезает ее
  Future<bool> _reduceTodayWorkoutIntensityLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      final rawCalendar = prefs.getString('calendar_workouts');

      if (rawCalendar == null) return false;

      final Map<String, dynamic> calendarCache = jsonDecode(rawCalendar);

      if (calendarCache.containsKey(todayDate)) {
        var todayWorkout = calendarCache[todayDate];
        List<dynamic> exercises = todayWorkout['exercises'] ?? [];

        if (exercises.isEmpty) return false;

        // Идем по всем упражнениям и снижаем количество подходов или повторений
        for (int i = 0; i < exercises.length; i++) {
          // Пытаемся распарсить строку "display_string" (например "12x3")
          String display = exercises[i]['display_string'] ?? '';
          if (display.contains('x')) {
            var parts = display.split('x');
            int reps = int.tryParse(parts[0]) ?? 0;
            int sets = int.tryParse(parts[1]) ?? 0;

            if (sets > 1) {
              sets -= 1; // Убираем 1 подход
            } else if (reps > 8) {
              reps -= 4; // Или снижаем повторения
            }

            // Обновляем данные
            exercises[i]['display_string'] = '${reps}x$sets';
            exercises[i]['reps'] = reps.toString();
            exercises[i]['sets'] = sets.toString();
          }
        }

        // Меняем сложность на easy и уменьшаем калории/время
        todayWorkout['difficulty'] = 'easy';
        todayWorkout['workout_name'] = '${todayWorkout['workout_name']} (Лайт)';
        
        // Сохраняем обратно в кэш
        calendarCache[todayDate] = todayWorkout;
        await prefs.setString('calendar_workouts', jsonEncode(calendarCache));

        return true; // Успешно изменили
      }
      return false; // Сегодня нет тренировки
    } catch (e) {
      debugPrint('Ошибка снижения интенсивности: $e');
      return false;
    }
  }


  // === ЛОГИКА ЧАТА (n8n webhook) ===
  Future<void> _sendChatMessageToNetwork(String userMessage) async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
      
      List<dynamic> currentWorkout = [];
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      final rawCalendar = prefs.getString('calendar_workouts');
      
      if (rawCalendar != null) {
        final Map<String, dynamic> calendarCache = jsonDecode(rawCalendar);
        if (calendarCache.containsKey(todayDate)) {
          currentWorkout = calendarCache[todayDate]['exercises'] ?? [];
        }
      }

      final response = await http.post(
        Uri.parse('https://n8n.nexusfit.ru/webhook/chat'), // ЗАМЕНИТЕ НА ВАШ URL ЧАТА
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'message': userMessage,
          'current_workout': currentWorkout,
        }),
      );

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['response'] ?? 'Я тебя понял.';
        final bool isZamena = data['zamena'] == true;
        final zamenaDetails = data['zamena_details'];

        if (isZamena && zamenaDetails != null) {
          final oldEx = zamenaDetails['old_exercise']?.toString() ?? 'Старое';
          final newEx = zamenaDetails['new_exercise']?.toString() ?? 'Новое';
          
          _addBotMessageWithReplacement(text: aiText, oldEx: oldEx, newEx: newEx);
        } else {
          _addBotMessage(aiText);
        }
      } else {
        throw Exception('Ошибка сервера чата: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка отправки сообщения в чат: $e');
      if (!_isDisposed) {
        _addBotMessage('Извини, сейчас нет связи с сервером 📡 Попробуй чуть позже.');
      }
    } finally {
      _setLoading(false);
    }
  }

  // === ПРИМЕНЕНИЕ ЗАМЕНЫ (Кнопка в UI) ===
  void applyReplacement(ChatMessage message) async {
    if (message.oldExercise == null || message.newExercise == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String todayDate = DateTime.now().toIso8601String().split('T')[0];
    final String? rawCalendar = prefs.getString('calendar_workouts');

    if (rawCalendar != null) {
      final Map<String, dynamic> calendarCache = jsonDecode(rawCalendar);
      
      if (calendarCache.containsKey(todayDate)) {
        List<dynamic> exercises = calendarCache[todayDate]['exercises'];
        
        // Заменяем старое упражнение на новое
        for (int i = 0; i < exercises.length; i++) {
          if (exercises[i]['name'] == message.oldExercise) {
            exercises[i]['name'] = message.newExercise;
          }
        }
        
        // Сохраняем обновленный кэш
        await prefs.setString('calendar_workouts', jsonEncode(calendarCache));
        
        // Помечаем сообщение как примененное
        message.isApplied = true;
        notifyListeners();
      }
    }
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

  void _addBotMessageWithReplacement({required String text, required String oldEx, required String newEx}) {
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

  String _generateId() => '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
