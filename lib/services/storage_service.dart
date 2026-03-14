import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<bool> setJsonList(String key, List<Map<String, dynamic>> list) {
    return _prefs.setString(key, jsonEncode(list));
  }

  static List<Map<String, dynamic>>? getJsonList(String key) {
    final json = _prefs.getString(key);
    if (json != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    }
    return null;
  }

  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  static Future<bool> clear() {
    return _prefs.clear();
  }
}
