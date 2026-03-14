class AppConstants {
  static const String appName = 'AI Fitness Coach';
  static const String appVersion = '1.0.0';

  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyUserProfile = 'user_profile';
  static const String keyChatHistory = 'chat_history';
  static const String keyWorkoutHistory = 'workout_history';
  static const String keyNutritionData = 'nutrition_data';
  static const String keyHealthData = 'health_data';

  static const int defaultDailyCalories = 2000;
  static const int defaultDailyProtein = 150;
  static const int defaultDailyCarbs = 250;
  static const int defaultDailyFats = 67;
  static const int defaultDailySteps = 10000;

  static const String goalLoseWeight = 'lose_weight';
  static const String goalGainMuscle = 'gain_muscle';
  static const String goalStayFit = 'stay_fit';
  static const String goalImproveHealth = 'improve_health';

  static const List<String> motivationalMessages = [
    'Привет! Помнишь, вчера спина болела, как сейчас?',
    'Готов к новой тренировке? Давай покажем!',
    'Заметил сладкое. Стресс? Заменим на полезное?',
    'Не хватает 15г белка. Давай добавим?',
    'Отличная тренировка! Чувствуешь прогресс?',
    'Пора пить воду! Уже 3 часа.',
  ];
}

class AppStrings {
  static const String welcomeTitle = 'Добро пожаловать';
  static const String getStarted = 'Начать';
  static const String scanFood = 'Сканировать еду';
  static const String workoutPlan = 'План тренировок';
  static const String analytics = 'Аналитика';
  static const String aiCoach = 'AI Коуч';
  
}
