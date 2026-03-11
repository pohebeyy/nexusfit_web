class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  
  // Поля для карточки замены упражнения
  final bool isReplacement;
  final String? oldExercise;
  final String? newExercise;
  bool isApplied; // Меняется на true после нажатия кнопки

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.isReplacement = false,
    this.oldExercise,
    this.newExercise,
    this.isApplied = false,
  });
}
