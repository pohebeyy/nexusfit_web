import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:startap/models/ProfileModel.dart';

class ProfileApi {
  static const String _defaultEmail = 'test@fitflow.local';
  static const String _baseUrl = 'http://10.0.2.2:5678/webhook';

  Future<ProfileModel> fetchProfile() async {
    debugPrint('>>> fetchProfile ВЫЗВАН');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/profile'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'email': _defaultEmail}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // n8n может вернуть список или объект
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
    debugPrint('>>> updateProfile email: ${updated.email}');
    debugPrint('>>> updateProfile equipment: ${updated.equipmentEnabled.toList()}');
    
    final response = await http.post(
     Uri.parse('$_baseUrl/profilepost'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: utf8.encode(jsonEncode({
        'email':     updated.email.isNotEmpty ? updated.email : _defaultEmail,
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
    // позже добавим очистку токена
  }

  // Фолбэк если сервер недоступен
  ProfileModel _fallbackProfile() {
    return ProfileModel(
      firstName: '',
      lastName: '',
      email: _defaultEmail,
      goalText: '',
      injuries: [],
      preset: EquipmentPreset.homeBasic,
      equipmentEnabled: {'Коврик', 'Гантели'},
      aiContext: {},
    );
  }
}
