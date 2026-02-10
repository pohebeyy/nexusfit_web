import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/deep_link_action.dart';
import '../services/ai_coach_service.dart';
import '../services/deep_link_service.dart';

class AICoachProvider extends ChangeNotifier {
  final _aiCoachService = AICoachService();
  final _deepLinkService = DeepLinkService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AICoachProvider() {
    _deepLinkService.addListener(_onDeepLinkActionExecuted);
  }

  Future<void> initChat() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _aiCoachService.initChat();
      _messages = _convertToMessages(_aiCoachService.chatHistory);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка инициализации чата: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _aiCoachService.sendMessage(message);
      _messages = _convertToMessages(_aiCoachService.chatHistory);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка отправки сообщения: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMotivationalMessage() async {
    try {
      _errorMessage = null;
      await _aiCoachService.sendMotivationalMessage();
      _messages = _convertToMessages(_aiCoachService.chatHistory);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка: $e';
      notifyListeners();
    }
  }

  Future<void> executeDeepLink(DeepLinkAction action) async {
    await _deepLinkService.executeAction(action);
  }

  void _onDeepLinkActionExecuted(DeepLinkAction action) {
    debugPrint('Action executed in provider: ${action.id}');
    // Здесь можно добавить дополнительную логику
    notifyListeners();
  }

  List<ChatMessage> _convertToMessages(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) {
      final isUser = map['isMe'] as bool? ?? false;
      final type = isUser ? MessageType.user : MessageType.ai;

      // Парсим action cards если они есть
      List<ActionCardData>? actionCards;
      if (map['actionCards'] != null) {
        actionCards = (map['actionCards'] as List)
            .map((e) => ActionCardData.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return ChatMessage(
        id: map['id'] as String,
        content: map['text'] as String,
        type: type,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isTyping: false,
        actionCards: actionCards,
        metadata: {
          'messageType': map['type'],
          'context': _aiCoachService.userContext,
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _deepLinkService.removeListener(_onDeepLinkActionExecuted);
    _aiCoachService.dispose();
    super.dispose();
  }
}
