import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:startap/models/ProfileModel.dart';

import '../services/profile_api.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileApi api;
  ProfileProvider({required this.api});

  ProfileModel? _profile;
  bool _loading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool get isLoading => _loading;
  String? get error => _error;

  // Приватный изменяемый список оборудования
  List<String> _equipmentCatalog = [
    'Коврик',
    'Гантели',
    'Штанга',
    'Блины',
    'Скамья',
    'Турник',
    'Резинки',
    'Тренажер Смита',
    'Кроссовер / Кабели',
    'Жим ногами',
    'Гребной тренажер',
    'Беговая дорожка',
  ];

  // Геттер для доступа к каталогу
  List<String> get equipmentCatalog => _equipmentCatalog;

  Set<String> presetEquipment(EquipmentPreset preset) {
    switch (preset) {
      case EquipmentPreset.commercialGym:
        return {
          'Коврик',
          'Гантели',
          'Штанга',
          'Блины',
          'Скамья',
          'Турник',
          'Резинки',
          'Тренажер Смита',
          'Кроссовер / Кабели',
          'Жим ногами',
          'Гребной тренажер',
          'Беговая дорожка',
        };
      case EquipmentPreset.homeBasic:
        return {'Коврик', 'Гантели'};
      case EquipmentPreset.noEquipment:
        return {'Турник'};
      case EquipmentPreset.custom:
        return _profile?.equipmentEnabled ?? <String>{};
    }
  }

  // Метод добавления кастомного оборудования
  // Метод добавления кастомного оборудования
Future<void> addCustomEquipment(String equipmentName) async {
  if (equipmentName.isEmpty) return;
  
  // Проверяем дубликаты
  if (_equipmentCatalog.contains(equipmentName)) {
    return;
  }
  
  // Добавляем в каталог
  _equipmentCatalog.add(equipmentName);
  
  // Добавляем в активное оборудование профиля
  if (_profile != null) {
    final updatedEnabled = Set<String>.from(_profile!.equipmentEnabled);
    updatedEnabled.add(equipmentName);
    
    final next = _profile!.copyWith(
      equipmentEnabled: updatedEnabled,
      preset: EquipmentPreset.custom,
    );
    
    // Просто вызываем save, он сам вызовет notifyListeners
    await save(next);
  } else {
    // Если профиля нет, вызываем notifyListeners только один раз
    notifyListeners();
  }
}


  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await api.fetchProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> save(ProfileModel profile) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await api.updateProfile(profile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setPreset(EquipmentPreset preset) async {
    final p = _profile;
    if (p == null) return;

    final next = p.copyWith(
      preset: preset,
      equipmentEnabled: presetEquipment(preset),
    );
    await save(next);
  }

  Future<void> toggleEquipment(String item, bool enabled) async {
    final p = _profile;
    if (p == null) return;

    final set = Set<String>.from(p.equipmentEnabled);
    if (enabled) {
      set.add(item);
    } else {
      set.remove(item);
    }

    final next = p.copyWith(
      preset: EquipmentPreset.custom,
      equipmentEnabled: set,
    );
    await save(next);
  }

  Future<void> addInjury(String text) async {
    final p = _profile;
    if (p == null) return;

    final t = text.trim();
    if (t.isEmpty) return;

    final next = p.copyWith(injuries: [...p.injuries, t]);
    await save(next);
  }

  Future<void> removeInjuryAt(int index) async {
    final p = _profile;
    if (p == null) return;
    if (index < 0 || index >= p.injuries.length) return;

    final list = [...p.injuries]..removeAt(index);
    await save(p.copyWith(injuries: list));
  }

  Future<void> updateAiContextFromJson(String jsonText) async {
    final p = _profile;
    if (p == null) return;

    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON должен быть объектом (Map).');
    }

    await save(p.copyWith(aiContext: decoded));
  }

  Future<void> createCustomPreset({
    required String name,
    required Set<String> equipment,
  }) async {
    final p = _profile;
    if (p == null) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final preset = EquipmentPresetModel(id: id, name: name, equipmentEnabled: equipment);

    await save(p.copyWith(customPresets: [...p.customPresets, preset]));
  }

  Future<void> applyCustomPreset(String presetId) async {
    final p = _profile;
    if (p == null) return;

    final found = p.customPresets.where((e) => e.id == presetId).toList();
    if (found.isEmpty) return;

    await save(p.copyWith(
      preset: EquipmentPreset.custom,
      equipmentEnabled: Set<String>.from(found.first.equipmentEnabled),
    ));
  }

  Future<void> deleteCustomPreset(String presetId) async {
    final p = _profile;
    if (p == null) return;

    final next = p.customPresets.where((e) => e.id != presetId).toList();
    await save(p.copyWith(customPresets: next));
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    try {
      await api.logout();
      _profile = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
