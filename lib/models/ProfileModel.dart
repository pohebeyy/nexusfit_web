import 'dart:convert';

enum EquipmentPreset { commercialGym, homeBasic, noEquipment, custom }

String equipmentPresetTitle(EquipmentPreset p) {
  switch (p) {
    case EquipmentPreset.commercialGym:
      return '🏢 Commercial Gym';
    case EquipmentPreset.homeBasic:
      return '🏠 Home Basic';
    case EquipmentPreset.noEquipment:
      return '🌳 No Equipment';
    case EquipmentPreset.custom:
      return '🛠 Custom';
  }
}

class EquipmentPresetModel {
  final String id; // uuid/string
  String name;
  Set<String> equipmentEnabled;

  EquipmentPresetModel({
    required this.id,
    required this.name,
    Set<String>? equipmentEnabled,
  }) : equipmentEnabled = equipmentEnabled ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'equipmentEnabled': equipmentEnabled.toList(),
      };

  factory EquipmentPresetModel.fromJson(Map<String, dynamic> json) {
    return EquipmentPresetModel(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      equipmentEnabled: ((json['equipmentEnabled'] ?? []) as List)
          .map((e) => e.toString())
          .toSet(),
    );
  }
}

class ProfileModel {
  String firstName;
  String lastName;
  String email;
  DateTime? birthDate;

  double? heightCm;
  double? weightKg;

  String goalText;
  List<String> injuries;

  EquipmentPreset preset; // системные пресеты + custom
  Set<String> equipmentEnabled; // актуальный чек-лист для AI

  /// Кастомные пресеты пользователя (созданные им).
  List<EquipmentPresetModel> customPresets;

  /// “Контекст” для нейронки
  Map<String, dynamic> aiContext;

  ProfileModel({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.goalText = '',
    List<String>? injuries,
    this.preset = EquipmentPreset.homeBasic,
    Set<String>? equipmentEnabled,
    List<EquipmentPresetModel>? customPresets,
    Map<String, dynamic>? aiContext,
  })  : injuries = injuries ?? <String>[],
        equipmentEnabled = equipmentEnabled ?? <String>{},
        customPresets = customPresets ?? <EquipmentPresetModel>[],
        aiContext = aiContext ?? <String, dynamic>{};

  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    String? goalText,
    List<String>? injuries,
    EquipmentPreset? preset,
    Set<String>? equipmentEnabled,
    List<EquipmentPresetModel>? customPresets,
    Map<String, dynamic>? aiContext,
  }) {
    return ProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalText: goalText ?? this.goalText,
      injuries: injuries ?? List<String>.from(this.injuries),
      preset: preset ?? this.preset,
      equipmentEnabled: equipmentEnabled ?? Set<String>.from(this.equipmentEnabled),
      customPresets: customPresets ?? this.customPresets.map((e) => EquipmentPresetModel(
        id: e.id,
        name: e.name,
        equipmentEnabled: Set<String>.from(e.equipmentEnabled),
      )).toList(),
      aiContext: aiContext ?? Map<String, dynamic>.from(this.aiContext),
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'birthDate': birthDate?.toIso8601String(),
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goalText': goalText,
        'injuries': injuries,
        'preset': preset.name,
        'equipmentEnabled': equipmentEnabled.toList(),
        'customPresets': customPresets.map((e) => e.toJson()).toList(),
        'aiContext': aiContext,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.tryParse(json['birthDate'].toString()),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      goalText: (json['goalText'] ?? '') as String,
      injuries: ((json['injuries'] ?? []) as List).map((e) => e.toString()).toList(),
      preset: EquipmentPreset.values.firstWhere(
        (p) => p.name == (json['preset'] ?? EquipmentPreset.homeBasic.name),
        orElse: () => EquipmentPreset.homeBasic,
      ),
      equipmentEnabled: ((json['equipmentEnabled'] ?? []) as List)
          .map((e) => e.toString())
          .toSet(),
      customPresets: ((json['customPresets'] ?? []) as List)
          .whereType<Map<String, dynamic>>()
          .map(EquipmentPresetModel.fromJson)
          .toList(),
      aiContext: (json['aiContext'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
