import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/models/ProfileModel.dart';
import 'package:startap/services/api/StringApi.dart';

class ProfileApi {
  // Достаем почту с дефолтным значением для тестов
  Future<String> _getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? 'akk@gmail.com'; 
  }

  Future<ProfileModel> fetchProfile() async {
    debugPrint('>>> fetchProfile ВЫЗВАН');
    try {
      final email = await _getSavedEmail();

      debugPrint('>>> fetchProfile email: $email');

      final response = await http.post(
        Uri.parse(StringApi.profileGet),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'email': email}),
      );

      debugPrint('>>> fetchProfile статус: ${response.statusCode}');
      debugPrint('>>> fetchProfile ответ: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) return _fallbackProfile();

        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final json = data is List ? data.first : data;
        return ProfileModel.fromJson(json as Map<String, dynamic>);
      } else {
        debugPrint('fetchProfile error: ${response.statusCode}');
        return _fallbackProfile();
      }
    } catch (e) {
      debugPrint('fetchProfile exception: $e');
      return _fallbackProfile();
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel updated) async {
    try {
      final cachedEmail = await _getSavedEmail();
      
      // Если в объекте updated нет почты, используем ту, что в кэше
      final actualEmail = updated.email.isNotEmpty 
          ? updated.email 
          : cachedEmail;

      debugPrint('>>> updateProfile email: $actualEmail');
      debugPrint('>>> updateProfile equipment: ${updated.equipmentEnabled.toList()}');

      final response = await http.post(
        Uri.parse(StringApi.profileUpdate),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({
          'email':     actualEmail,
          'heightCm':  updated.heightCm,
          'weightKg':  updated.weightKg,
          'goalText':  updated.goalText,
          'injuries':  updated.injuries,
          'equipment': updated.equipmentEnabled.toList(),
          'preset':    updated.preset.name,
        })),
      );

      debugPrint('>>> updateProfile статус: ${response.statusCode}');
      debugPrint('>>> updateProfile ответ: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) return updated;

        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final json = data is List ? data.first : data;
        return ProfileModel.fromJson(json as Map<String, dynamic>);
      } else {
        debugPrint('updateProfile error: ${response.statusCode}');
        return updated;
      }
    } catch (e) {
      debugPrint('updateProfile exception: $e');
      return updated;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  ProfileModel _fallbackProfile() {
    return ProfileModel(
      firstName: '',
      lastName: '',
      email: '',
      goalText: '',
      injuries: [],
      preset: EquipmentPreset.homeBasic,
      equipmentEnabled: {'Коврик', 'Гантели'},
      aiContext: {},
    );
  }
}
