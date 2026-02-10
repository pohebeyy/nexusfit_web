import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class QuickSuggestionsWidget extends StatelessWidget {
  final List<QuickReply> suggestions;
  final Function(String) onSuggestionSelected;

  const QuickSuggestionsWidget({
    required this.suggestions,
    required this.onSuggestionSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: suggestions
            .asMap()
            .entries
            .map((e) => _buildSuggestionButton(e.value, e.key))
            .toList(),
      ),
    );
  }

  Widget _buildSuggestionButton(QuickReply suggestion, int index) {
    return Padding(
      padding: EdgeInsets.only(right: index == 2 ? 0 : 12),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(20 * (1 - value), 0),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSuggestionSelected(suggestion.text),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (suggestion.icon != null) ...[
                      Icon(
                        suggestion.icon,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      suggestion.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
