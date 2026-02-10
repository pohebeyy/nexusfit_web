import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'action_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;
  final VoidCallback? onActionTap;

  const MessageBubble({
    required this.message,
    required this.index,
    this.onActionTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: message.isFromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: message.isFromUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!message.isFromUser) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      gradient: message.isFromUser
                          ? const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
                            )
                          : null,
                      color: message.isFromUser ? null : const Color(0xFF1D1E33),
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(message.isFromUser ? 20 : 4),
                        topRight:
                            Radius.circular(message.isFromUser ? 4 : 20),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: message.isFromUser
                              ? const Color(0xFF6C5CE7).withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                if (message.isFromUser) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1E33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action Cards
          if (message.actionCards != null && message.actionCards!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 48,
                right: 0,
                top: 12,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: message.actionCards!
                    .map((card) => ActionCardWidget(
                          card: card,
                          onActionTap: onActionTap,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
