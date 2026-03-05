import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/data/UserModel.dart';

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

  Future<bool> signUp({
    required String email, 
    required String password, 
    required String name
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/reguser');
      
      print('Отправляем запрос на: $url'); 
      print('Данные: email=$email, name=$name');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'goal': 'general_fitness',
          'body_type': 'mesomorph',
          'experience': 'beginner',
          'equipment': ['собственный вес']
        }),
      );

      print('Статус код от сервера: ${response.statusCode}');
      print('Ответ от сервера: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _isLoading = false;
          notifyListeners();
          return true; 
        } else {
          _error = data['message'] ?? 'Ошибка регистрации';
        }
      } else {
        _error = 'Ошибка регистрации. Сервер вернул: ${response.statusCode}';
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/login');
      
      print('Отправка запроса на вход: $url');
      print('Email: $email');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Сохраняем токен и данные пользователя
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('user_email', data['user']['email']);
          await prefs.setString('user_name', data['user']['name'] ?? '');
          await prefs.setInt('user_id', data['user']['id']);
          
          _token = data['token'];
          _user = UserModel(
            id: data['user']['id'].toString(),
            email: data['user']['email'],
            name: data['user']['name'] ?? '',
          );
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Неверный email или пароль';
        }
      } else {
        _error = 'Ошибка сервера: ${response.statusCode}';
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
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Добавить endpoint для сброса пароля в n8n
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
