import '../models/meal.dart';
import '../data/mock_data.dart';

class NutritionService {
  static final NutritionService _instance = NutritionService._internal();

  factory NutritionService() {
    return _instance;
  }

  NutritionService._internal();

  List<Meal> _meals = [];

  Future<void> initMeals() async {
    _meals = MockData.getMockMeals();
  }

  List<Meal> getMeals() => _meals;

  Future<Meal> analyzeFoodImage(String imagePath) async {
    await Future.delayed(Duration(seconds: 2));

    final mockMeal = Meal(
      id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Бутерброд с колбасой',
      description: 'Хлеб, колбаса, сыр, помидор',
      calories: 420,
      protein: 18,
      carbs: 35,
      fats: 22,
      fiber: 2,
      sugar: 3,
      consumedAt: DateTime.now(),
      mealType: 'snack',
      imageUrl: imagePath,
    );

    _meals.add(mockMeal);
    return mockMeal;
  }

  String getNutritionRecommendation(Meal meal) {
    if (meal.sugar > 30) {
      return 'Много сладкого в этом блюде. Стресс? Может заменим на что-то полезное?';
    } else if (meal.protein < 10) {
      return 'Тебе не хватает белка. Добавим курицу или рыбу?';
    } else if (meal.fats > 30) {
      return 'Жира многовато. Выбери что-нибудь полегче?';
    }
    return 'Хороший выбор! Этот прием пищи отлично подходит к твоим целям.';
  }

  Future<List<String>> scanFridge(List<String> ingredients) async {
    await Future.delayed(Duration(seconds: 1));

    const recipes = [
      'Курица с овощами',
      'Омлет с беконом',
      'Салат из помидоров и огурцов',
      'Суп из курицы',
      'Гарнир из риса',
    ];

    return recipes;
  }

  double calculateTotalCalories(DateTime date) {
    return _meals
        .where((m) => m.consumedAt.day == date.day && m.consumedAt.month == date.month)
        .fold(0.0, (sum, meal) => sum + meal.calories);
  }
}
