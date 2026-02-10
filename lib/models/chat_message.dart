import 'package:flutter/material.dart';
import 'deep_link_action.dart';

enum MessageType { user, ai, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isTyping;
  final List<ActionCardData>? actionCards;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
    this.actionCards,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values[json['type'] as int? ?? 0],
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTyping: json['isTyping'] as bool? ?? false,
      actionCards: (json['actionCards'] as List?)
          ?.map((e) => ActionCardData.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
      'actionCards': actionCards?.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isTyping,
    List<ActionCardData>? actionCards,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      actionCards: actionCards ?? this.actionCards,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isFromAI => type == MessageType.ai;
  bool get isFromUser => type == MessageType.user;
  bool get isSystem => type == MessageType.system;
}

class QuickReply {
  final String text;
  final IconData? icon;

  const QuickReply({
    required this.text,
    this.icon,
  });
}
