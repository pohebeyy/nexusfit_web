import 'package:flutter/material.dart';

enum MessageType { user, ai, system }

class ChatMessage {
  final String content;
  final bool isFromUser;

  ChatMessage({
    required this.content,
    required this.isFromUser,
  });
}

class QuickReply {
  final String text;
  final IconData? icon;

  const QuickReply({
    required this.text,
    this.icon,
  });
}
