import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/data/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null || _token != null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('user_id');
    final userEmail = prefs.getString('user_email');
    final userName = prefs.getString('user_name');

    if (_token != null && userId != null) {
      _user = UserModel(
        id: userId.toString(),
        email: userEmail ?? '',
        name: userName ?? '',
      );
    }
    notifyListeners();
  }
  Future<bool> _authenticateSocialUser({
    required String email,
    required String name,
    required String provider,
    required String providerId,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/social-auth');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizedEmail,
          'name': name,
          'provider': provider,
          'provider_id': providerId,
        }),
      );

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body);
        } catch (_) {}
      }

      if (response.statusCode == 200 && data != null && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']?.toString() ?? '');
        await prefs.setString('user_email', data['user']?['email']?.toString() ?? normalizedEmail);
        await prefs.setString('user_name', data['user']?['name']?.toString() ?? name);
        if (data['user']?['id'] != null) {
          await prefs.setInt('user_id', data['user']['id']);
        }

        _token = data['token']?.toString();
        _user = UserModel(
          id: data['user']?['id']?.toString() ?? '',
          email: data['user']?['email']?.toString() ?? normalizedEmail,
          name: data['user']?['name']?.toString() ?? name,
        );

        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data?['message']?.toString() ?? 'Ошибка входа через $provider';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
    // === ВХОД ЧЕРЕЗ GOOGLE (FIREBASE WEB) ===
    // === ВХОД ЧЕРЕЗ GOOGLE (FIREBASE WEB) ===
  // Теперь возвращает String? ('new', 'existing' или null в случае ошибки)
  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      final User? user = userCredential.user;

      // 🔥 Магия Firebase: проверяем, новый ли это пользователь
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (user != null) {
        // Отправляем данные в твой вебхук n8n
        bool success = await _authenticateSocialUser(
          email: user.email ?? '',
          name: user.displayName ?? 'Пользователь Google',
          provider: 'google',
          providerId: user.uid,
        );

        if (success) {
          // Если n8n ответил 200 OK, возвращаем статус пользователя
          return isNewUser ? 'new' : 'existing';
        } else {
          return null; // Ошибка со стороны n8n
        }
      } else {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      print('Ошибка Firebase Google Sign In: $e');
      _error = 'Ошибка авторизации Google';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }


  // (Твой метод _authenticateSocialUser оставляем без изменений,
  // просто убедись, что он есть в файле, чтобы отправлять данные в n8n)

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    try {
      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/reguser');

      print('Отправляем запрос на: $url');
      print('Данные: email=$normalizedEmail, name=$trimmedName');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizedEmail,
          'password': password,
          'name': trimmedName,
          'goal': 'general_fitness',
          'body_type': 'mesomorph',
          'experience': 'beginner',
          'equipment': ['собственный вес'],
        }),
      );

      print('Статус код от сервера: ${response.statusCode}');
      print('Ответ от сервера: ${response.body}');

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('Ошибка парсинга JSON: $e');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data != null && data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', normalizedEmail);
          await prefs.setString('user_name', trimmedName);

          _user = UserModel(
            id: data['userId']?.toString() ?? '',
            email: normalizedEmail,
            name: trimmedName,
          );

          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = data?['message']?.toString() ?? 'Ошибка регистрации';
        }
      } else if (response.statusCode == 409) {
        _error = data?['message']?.toString() ??
            'Пользователь с таким email уже существует';
      } else {
        _error = data?['message']?.toString() ??
            'Ошибка регистрации. Сервер вернул: ${response.statusCode}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('КРИТИЧЕСКАЯ ОШИБКА: $e');
      _error = 'Ошибка соединения с сервером: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final normalizedEmail = email.trim().toLowerCase();

    try {
      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/login');

      print('Отправка запроса на вход: $url');
      print('Email: $normalizedEmail');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizedEmail,
          'password': password,
        }),
      );

      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('Ошибка парсинга JSON при логине: $e');
        }
      }

      if (response.statusCode == 200) {
        if (data != null && data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']?.toString() ?? '');
          await prefs.setString(
              'user_email', data['user']?['email']?.toString() ?? normalizedEmail);
          await prefs.setString(
              'user_name', data['user']?['name']?.toString() ?? '');
          if (data['user']?['id'] != null) {
            await prefs.setInt('user_id', data['user']['id']);
          }

          _token = data['token']?.toString();
          _user = UserModel(
            id: data['user']?['id']?.toString() ?? '',
            email: data['user']?['email']?.toString() ?? normalizedEmail,
            name: data['user']?['name']?.toString() ?? '',
          );

          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = data?['message']?.toString() ?? 'Неверный email или пароль';
        }
      } else if (response.statusCode == 401) {
        _error = data?['message']?.toString() ?? 'Неверный email или пароль';
      } else {
        _error =
            data?['message']?.toString() ?? 'Ошибка сервера: ${response.statusCode}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Ошибка при входе: $e');
      _error = 'Ошибка подключения: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');

    _token = null;
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}