import 'package:flutter/material.dart';
import 'package:startap/data/onboarding_model.dart';


class OnboardingProvider extends ChangeNotifier {
  final OnboardingData _data = OnboardingData();

  OnboardingData get data => _data;

  void setHasPhoto(bool hasPhoto) {
    _data.hasPhoto = hasPhoto;
    notifyListeners();
  }

  void setGender(String gender) {
    _data.gender = gender;
    notifyListeners();
  }

  void setGoal(String goal) {
    _data.goal = goal;
    notifyListeners();
  }

  void setTargetZones(List<String> zones) {
    _data.targetZones = zones;
    notifyListeners();
  }

  void setHeight(double height) {
    _data.height = height;
    notifyListeners();
  }

  void setWeight(double weight) {
    _data.weight = weight;
    notifyListeners();
  }

  void setTrainingLocation(String location) {
    _data.trainingLocation = location;
    notifyListeners();
  }

  void setEquipment(List<String> equipment) {
    _data.equipment = equipment;
    notifyListeners();
  }

  void setExperience(String experience) {
    _data.experience = experience;
    notifyListeners();
  }

  void setHealthIssues(List<String> issues) {
    _data.healthIssues = issues;
    notifyListeners();
  }

  void reset() {
    _data.hasPhoto = false;
    _data.gender = null;
    _data.goal = null;
    _data.targetZones = null;
    _data.height = null;
    _data.weight = null;
    _data.trainingLocation = null;
    _data.equipment = null;
    _data.experience = null;
    _data.healthIssues = null;
    notifyListeners();
  }
}
