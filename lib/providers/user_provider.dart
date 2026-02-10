import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../data/mock_data.dart';
import '../utils/constants.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _user != null;

  Future<void> initUser() async {
    _isLoading = true;
    notifyListeners();

    final userJson = StorageService.getString(AppConstants.keyUserProfile);
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } else {
      _user = MockData.getMockUser();
      await saveUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _user = user;
    await saveUser();
    notifyListeners();
  }

  Future<void> saveUser() async {
    if (_user != null) {
      await StorageService.setString(
        AppConstants.keyUserProfile,
        jsonEncode(_user!.toJson()),
      );
    }
  }

  Future<void> completeOnboarding() async {
    await StorageService.setBool(AppConstants.keyOnboardingCompleted, true);
    notifyListeners();
  }

  void logout() {
    _user = null;
    StorageService.clear();
    notifyListeners();
  }
}


