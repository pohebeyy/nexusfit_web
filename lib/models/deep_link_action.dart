import 'package:flutter/material.dart';

enum ActionType {
  replaceExercise,
  removeExercise,
  addExercise,
  modifyWorkout,
  navigateToScreen,
  openDialog,
  executeCustom,
}

class DeepLinkAction {
  final String id;
  final ActionType type;
  final String label;
  final String description;
  final Map<String, dynamic> params;
  final VoidCallback? onExecute;
  final Color? actionColor;

  const DeepLinkAction({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.params,
    this.onExecute,
    this.actionColor,
  });

  factory DeepLinkAction.fromJson(Map<String, dynamic> json) {
    return DeepLinkAction(
      id: json['id'] as String,
      type: ActionType.values[json['type'] as int? ?? 0],
      label: json['label'] as String,
      description: json['description'] as String,
      params: json['params'] as Map<String, dynamic>? ?? {},
      actionColor: json['actionColor'] != null
          ? Color(json['actionColor'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'label': label,
      'description': description,
      'params': params,
      'actionColor': actionColor?.value,
    };
  }
}

class ActionCardData {
  final String title;
  final List<String> changes;
  final DeepLinkAction primaryAction;
  final DeepLinkAction? secondaryAction;

  const ActionCardData({
    required this.title,
    required this.changes,
    required this.primaryAction,
    this.secondaryAction,
  });

  factory ActionCardData.fromJson(Map<String, dynamic> json) {
    return ActionCardData(
      title: json['title'] as String,
      changes: List<String>.from(json['changes'] as List),
      primaryAction:
          DeepLinkAction.fromJson(json['primaryAction'] as Map<String, dynamic>),
      secondaryAction: json['secondaryAction'] != null
          ? DeepLinkAction.fromJson(
              json['secondaryAction'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'changes': changes,
      'primaryAction': primaryAction.toJson(),
      'secondaryAction': secondaryAction?.toJson(),
    };
  }
}
