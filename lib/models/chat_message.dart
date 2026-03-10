// chat_message.dart
class ChatMessage {
  final String content;
  final bool isFromUser;
  final bool isReplacement;
  final String? oldExercise;
  final String? newExercise;
  bool isApplied; // Флаг, чтобы скрыть кнопку после применения

  ChatMessage({
    required this.content,
    required this.isFromUser,
    this.isReplacement = false,
    this.oldExercise,
    this.newExercise,
    this.isApplied = false,
  });
}
