import '../models/user.dart';
import '../models/chat_message.dart';
import '../models/meal.dart';
import '../models/workout.dart';
import '../models/health_data.dart';

class MockData {
  static User getMockUser() {
    return User(
      id: 'user_1',
      name: 'Алексей',
      email: 'alexey@example.com',
      age: 28,
      gender: 'male',
      height: 180,
      weight: 85,
      goal: 'lose_weight',
      activityLevel: 'moderate',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      bodyFatPercentage: 22.5,
      dailyCalorieGoal: 2000,
      dailyProteinGoal: 150,
      dailyCarbsGoal: 250,
      dailyFatsGoal: 67,
      dailyStepsGoal: 10000,
    );
  }

  

  static List<Meal> getMockMeals() {
    return [
      Meal(
        id: 'meal_1',
        name: 'Омлет с беконом',
        description: 'Завтрак: 2 яйца, 50г бекона, хлеб',
        calories: 350,
        protein: 25,
        carbs: 15,
        fats: 20,
        fiber: 2,
        sugar: 1,
        consumedAt: DateTime.now().subtract(Duration(hours: 8)),
        mealType: 'breakfast',
        ingredients: [
          FoodItem(
            id: 'food_1',
            name: 'Яйца',
            quantity: 2,
            unit: 'шт',
            caloriesPer100g: 155,
            proteinPer100g: 13,
            carbsPer100g: 1.1,
            fatsPer100g: 11,
          ),
          FoodItem(
            id: 'food_2',
            name: 'Бекон',
            quantity: 50,
            unit: 'г',
            caloriesPer100g: 541,
            proteinPer100g: 37,
            carbsPer100g: 0,
            fatsPer100g: 43,
          ),
        ],
      ),
      Meal(
        id: 'meal_2',
        name: 'Курица с рисом',
        description: 'Обед: 150г курицы, 100г риса',
        calories: 520,
        protein: 45,
        carbs: 55,
        fats: 12,
        fiber: 1,
        sugar: 0,
        consumedAt: DateTime.now().subtract(Duration(hours: 2)),
        mealType: 'lunch',
      ),
    ];
  }

  static List<Workout> getMockWorkouts() {
    return [
      Workout(
        id: 'workout_1',
        name: 'Тренировка спины',
        description: 'Полная тренировка спины для набора массы',
        type: 'strength',
        difficulty: 'intermediate',
        durationMinutes: 60,
        estimatedCalories: 350,
        exercises: [
          Exercise(
            id: 'ex_1',
            name: 'Подтягивания',
            description: 'Классические подтягивания',
            type: 'strength',
            muscleGroup: 'back',
            sets: 4,
            reps: 8,
          ),
          Exercise(
            id: 'ex_2',
            name: 'Тяга штанги в наклоне',
            description: 'Тяга для спины',
            type: 'strength',
            muscleGroup: 'back',
            sets: 4,
            reps: 10,
            weight: 80,
          ),
          Exercise(
            id: 'ex_3',
            name: 'Гиперэкстензия',
            description: 'Разгибания спины',
            type: 'strength',
            muscleGroup: 'back',
            sets: 3,
            reps: 12,
          ),
        ],
        isCompleted: true,
        completedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Workout(
        id: 'workout_2',
        name: 'Кардио утром',
        description: 'Лёгкое кардио',
        type: 'cardio',
        difficulty: 'beginner',
        durationMinutes: 30,
        estimatedCalories: 250,
        exercises: [
          Exercise(
            id: 'ex_4',
            name: 'Бег',
            description: 'Бег в среднем темпе',
            type: 'cardio',
            muscleGroup: 'full_body',
            durationSeconds: 1800,
          ),
        ],
        isCompleted: false,
        scheduledFor: DateTime.now().add(Duration(hours: 2)),
      ),
    ];
  }

  static List<HealthData> getMockHealthData() {
    final today = DateTime.now();
    return [
      HealthData(
        id: 'health_1',
        date: today,
        steps: 8500,
        heartRate: 72,
        sleepHours: 7,
        waterGlassesConsumed: 6,
        stressLevel: 0.4,
        mood: 'отличное',
        workoutMinutes: 60,
      ),
      HealthData(
        id: 'health_2',
        date: today.subtract(Duration(days: 1)),
        steps: 12300,
        heartRate: 70,
        sleepHours: 8,
        waterGlassesConsumed: 8,
        stressLevel: 0.3,
        mood: 'хорошее',
        workoutMinutes: 45,
      ),
      HealthData(
        id: 'health_3',
        date: today.subtract(Duration(days: 2)),
        steps: 9800,
        heartRate: 75,
        sleepHours: 6,
        waterGlassesConsumed: 5,
        stressLevel: 0.6,
        mood: 'нейтральное',
        workoutMinutes: 0,
      ),
    ];
  }

  static WorkoutPlan getMockWorkoutPlan() {
    return WorkoutPlan(
      id: 'plan_1',
      name: 'Недельный план',
      description: 'Интенсивный план для похудения',
      goal: 'lose_weight',
      intensity: 'hard',
      durationWeeks: 4,
      workouts: getMockWorkouts(),
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
      isActive: true,
    );
  }
}
