import 'package:flutter/material.dart';
import '../models/deep_link_action.dart';


class AICoachService {
 final List<Map<String, dynamic>> _chatHistory = [];
 final Map<String, dynamic> _userContext = {};
 bool _isDisposed = false;


 List<Map<String, dynamic>> get chatHistory => _chatHistory;
 Map<String, dynamic> get userContext => _userContext;


 Future<void> initChat() async {
 _chatHistory.clear();
  _userContext.clear();


 // Загрузить контекст пользователя из БД
// (симуляция)
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
  }


  Future<void> sendMessage(String userMessage) async {
    if (_isDisposed) return;


    // Добавить сообщение пользователя
    _chatHistory.add({
      'id': _generateId(),
      'text': userMessage,
      'type': 'text',
      'isMe': true,
      'timestamp': DateTime.now().toIso8601String(),
    });


    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 800));


    if (_isDisposed) return;


    // Генерировать ответ коуча с контекстом
    final aiResponse = _generateContextualResponse(userMessage);


    _chatHistory.add(aiResponse);
  }


  Map<String, dynamic> _generateContextualResponse(String userMessage) {
    final messageWithContext = _buildContextString();
    debugPrint('📊 Context for AI:\n$messageWithContext');


    // Примеры ответов в зависимости от сообщения
    if (userMessage.toLowerCase().contains('боль') ||
        userMessage.toLowerCase().contains('больно')) {
      return _generateInjuryResponse(userMessage);
    } else if (userMessage.toLowerCase().contains('тренировка')) {
      return _generateWorkoutResponse(userMessage);
    } else if (userMessage.toLowerCase().contains('питание')) {
      return _generateNutritionResponse(userMessage);
    } else if (userMessage.toLowerCase().contains('мотивация')) {
      return _generateMotivationResponse(userMessage);
    }


    return _generateGenericResponse(userMessage);
  }


  Map<String, dynamic> _generateInjuryResponse(String userMessage) {
    final actionCard = ActionCardData(
      title: 'Рекомендуемые изменения',
      changes: [
        'Приседания → Сгибания ног лежа',
        'Выпады → Убрать из плана',
      ],
      primaryAction: DeepLinkAction(
        id: 'replace_exercise_1',
        type: ActionType.replaceExercise,
        label: 'Применить изменения',
        description: 'Заменить упражнения в плане',
        params: {
          'oldExercise': 'Приседания',
          'newExercise': 'Сгибания ног лежа',
          'workoutId': 'workout_123',
        },
        actionColor: const Color(0xFF6C5CE7),
      ),
      secondaryAction: DeepLinkAction(
        id: 'view_alternatives',
        type: ActionType.navigateToScreen,
        label: 'Посмотреть альтернативы',
        description: 'Открыть список альтернативных упражнений',
        params: {
          'route': '/exercise_alternatives',
          'bodyPart': 'legs',
        },
      ),
    );


    return {
      'id': _generateId(),
      'text': 'Вижу, у тебя проблемы с ногой. Неделю назад была травма икры, вчера была тяжелая тренировка, '
          'мало спал (5 часов) и пил воды. Скорее всего, воспаление + неполное восстановление.\n\n'
          'Мой совет:\n'
          '• Лёд 15 минут\n'
          '• Высокое положение ноги\n'
          '• Много воды сегодня\n'
          '• Завтра полный отдых от ног\n\n'
          'Я модифицировал твой план тренировки.',
      'type': 'text_with_actions',
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
      'actionCards': [actionCard.toJson()],
    };
  }


  Map<String, dynamic> _generateWorkoutResponse(String userMessage) {
    final actionCard = ActionCardData(
      title: 'Предложу план',
      changes: [
        'День 1: Грудь + Трицепс',
        'День 2: Спина + Бицепс',
        'День 3: Ноги',
        'День 4: Плечи + Кор',
      ],
      primaryAction: DeepLinkAction(
        id: 'apply_workout_plan',
        type: ActionType.modifyWorkout,
        label: 'Применить план',
        description: 'Добавить недельный план в приложение',
        params: {
          'planId': 'weekly_split_001',
          'startDate': DateTime.now().toIso8601String(),
        },
        actionColor: const Color(0xFF6C5CE7),
      ),
      secondaryAction: DeepLinkAction(
        id: 'customize_workout',
        type: ActionType.navigateToScreen,
        label: 'Настроить',
        description: 'Открыть редактор плана',
        params: {
          'route': '/workout_editor',
        },
      ),
    );


    return {
      'id': _generateId(),
      'text': 'Окей, составлю классный план для тебя! Я вижу, что ты ищешь полноценную программу.\n\n'
          'Исходя из твоих целей, рекомендую сплит 4 дня в неделю:',
      'type': 'text_with_actions',
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
      'actionCards': [actionCard.toJson()],
    };
  }


  Map<String, dynamic> _generateNutritionResponse(String userMessage) {
    return {
      'id': _generateId(),
      'text': 'Питание - это 80% результата! 💪\n\n'
          'Основные правила:\n'
          '• Белок 1.6-2.2г на кг веса\n'
          '• Углеводы после тренировки\n'
          '• Жиры не менее 25% калорий\n'
          '• Вода минимум 2.5л в день\n\n'
          'Учитывая, что ты пьешь мало воды, начни с этого 💧',
      'type': 'text',
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }


  Map<String, dynamic> _generateMotivationResponse(String userMessage) {
    return {
      'id': _generateId(),
      'text': 'Мотивация приходит и уходит, но дисциплина остается навсегда! 🔥\n\n'
          'Что я вижу в твоих данных:\n'
          '✅ Ты тренируешься регулярно\n'
          '✅ Интересуешься развитием\n'
          '⚠️ Не хватает восстановления (мало сна)\n\n'
          'Пару советов:\n'
          '1. Спи по 7-8 часов - это даст энергию\n'
          '2. Отслеживай прогресс - видишь рост?\n'
          '3. Общайся с людьми в зале - вдохновляет\n\n'
          'Ты на правильном пути! 💯',
      'type': 'text',
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }


  Map<String, dynamic> _generateGenericResponse(String userMessage) {
    return {
      'id': _generateId(),
      'text': 'Интересный вопрос! 🤔 '
          'На основе твоих данных: возраст ${_userContext['age']}, '
          'последняя тренировка была ${_daysSinceLastWorkout()} дня назад.\n\n'
          'Скажи мне подробнее, чтобы я мог дать более точный совет!',
      'type': 'text',
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }


  Future<void> sendMotivationalMessage() async {
    if (_isDisposed) return;


    final message = {
      'id': _generateId(),
      'text': '🚀 Ты сегодня потренировался? '
          'Погнали! Каждая тренировка - это шаг к твоей цели!',
      'type': 'text',
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
    };


    _chatHistory.add(message);
  }


  String _buildContextString() {
    final sb = StringBuffer();
    sb.writeln('=== USER CONTEXT ===');
    sb.writeln('Name: ${_userContext['name']}');
    sb.writeln('Age: ${_userContext['age']}');
    sb.writeln('Last Workout: ${_userContext['lastWorkout']}');
    sb.writeln('Sleep Hours: ${_userContext['sleepHours']}');
    sb.writeln('Hydration: ${_userContext['hydration']}');
    sb.writeln('Injuries: ${_userContext['injuries']}');
    sb.writeln('Motivation: ${_userContext['motivation']}');
    return sb.toString();
  }


  int _daysSinceLastWorkout() {
    final lastWorkout = _userContext['lastWorkout'] as DateTime?;
    if (lastWorkout == null) return 0;
    return DateTime.now().difference(lastWorkout).inDays;
  }


  String _generateId() => '${DateTime.now().millisecondsSinceEpoch}_$_randomSuffix';


  String get _randomSuffix =>
      (DateTime.now().millisecond + DateTime.now().microsecond).toString();


  void dispose() {
    _isDisposed = true;
  }
}