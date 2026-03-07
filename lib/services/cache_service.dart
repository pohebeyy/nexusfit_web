import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Ключи для кэша
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';

  /// Сохраняет данные при логине/регистрации
  static Future<void> saveUserData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  /// Достает email пользователя. Если нет - возвращает null
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Очищает кэш (вызывать при кнопке "Выйти из аккаунта")
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
