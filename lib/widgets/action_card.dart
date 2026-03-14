import 'package:flutter/material.dart';
import '../models/deep_link_action.dart';

class ActionCardWidget extends StatefulWidget {
  final ActionCardData card;
  final VoidCallback? onActionTap;

  const ActionCardWidget({
    required this.card,
    this.onActionTap,
    super.key,
  });

  @override
  State<ActionCardWidget> createState() => _ActionCardWidgetState();
}

class _ActionCardWidgetState extends State<ActionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            if (_isExpanded) {
              _animController.forward();
            } else {
              _animController.reverse();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.card.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.card.changes.length} изменений',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(
                        CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
                      ),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: const Color(0xFF6C5CE7),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                // Changes list (expandable)
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: _animController,
                    curve: Curves.easeInOut,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ...widget.card.changes.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: const Color(0xFF6C5CE7),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        widget.card.primaryAction,
                        isPrimary: true,
                      ),
                    ),
                    if (widget.card.secondaryAction != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          widget.card.secondaryAction!,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(DeepLinkAction action, {required bool isPrimary}) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
              )
            : null,
        color: isPrimary ? null : const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
                width: 1.5,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onActionTap?.call();
            _showActionFeedback(action);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionFeedback(DeepLinkAction action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${action.label}'),
        backgroundColor: const Color(0xFF6C5CE7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
