import 'dart:async';
import 'package:startap/models/ProfileModel.dart';



class ProfileApi {
  // Имитируем “серверное” хранилище в памяти:
  ProfileModel _serverProfile = ProfileModel(
    firstName: 'Иван',
    lastName: 'Иванов',
    email: 'ivan@example.com',
    goalText: 'Снизить процент жира',
    injuries: ['астма'],
    preset: EquipmentPreset.homeBasic,
    equipmentEnabled: {
      'Коврик',
      'Гантели',
    },
    aiContext: {
      'experience': 'beginner',
      'weekly_workouts': 3,
    },
  );

  Future<ProfileModel> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _serverProfile.copyWith();
  }

  Future<ProfileModel> updateProfile(ProfileModel updated) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _serverProfile = updated.copyWith();
    return _serverProfile.copyWith();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 250));
  }

  Future<void> updateSubscriptionStub() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
