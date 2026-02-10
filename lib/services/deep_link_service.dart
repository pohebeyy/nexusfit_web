import 'package:flutter/material.dart';
import '../models/deep_link_action.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();

  factory DeepLinkService() {
    return _instance;
  }

  DeepLinkService._internal();

  // Callback для обработки действий
  final List<Function(DeepLinkAction)> _listeners = [];

  void addListener(Function(DeepLinkAction) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(DeepLinkAction) listener) {
    _listeners.remove(listener);
  }

  Future<void> executeAction(DeepLinkAction action) async {
    // Логирование
    debugPrint('🔗 DeepLink Action: ${action.id} | Type: ${action.type}');

    // Уведомление всех слушателей
    for (final listener in _listeners) {
      listener(action);
    }

    // Дополнительная обработка в зависимости от типа
    switch (action.type) {
      case ActionType.replaceExercise:
        _handleReplaceExercise(action);
        break;
      case ActionType.removeExercise:
        _handleRemoveExercise(action);
        break;
      case ActionType.addExercise:
        _handleAddExercise(action);
        break;
      case ActionType.modifyWorkout:
        _handleModifyWorkout(action);
        break;
      case ActionType.navigateToScreen:
        _handleNavigation(action);
        break;
      case ActionType.openDialog:
        _handleDialog(action);
        break;
      case ActionType.executeCustom:
        if (action.onExecute != null) {
          action.onExecute!();
        }
        break;
    }
  }

  void _handleReplaceExercise(DeepLinkAction action) {
    final oldExercise = action.params['oldExercise'] as String?;
    final newExercise = action.params['newExercise'] as String?;
    debugPrint('💪 Replace: $oldExercise → $newExercise');
  }

  void _handleRemoveExercise(DeepLinkAction action) {
    final exercise = action.params['exercise'] as String?;
    debugPrint('🗑️ Remove: $exercise');
  }

  void _handleAddExercise(DeepLinkAction action) {
    final exercise = action.params['exercise'] as String?;
    debugPrint('➕ Add: $exercise');
  }

  void _handleModifyWorkout(DeepLinkAction action) {
    debugPrint('🎯 Modify workout with params: ${action.params}');
  }

  void _handleNavigation(DeepLinkAction action) {
    final route = action.params['route'] as String?;
    debugPrint('🔀 Navigate to: $route');
  }

  void _handleDialog(DeepLinkAction action) {
    final title = action.params['title'] as String?;
    debugPrint('📋 Open dialog: $title');
  }
}
