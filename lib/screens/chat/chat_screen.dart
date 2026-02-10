import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_coach_provider.dart';
import '../../models/chat_message.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/quick_suggestions.dart';
import '../../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _fabAnimationController;

  final List<QuickReply> _quickReplies = [
    QuickReply(
      text: 'Болит плечо',
      icon: Icons.favorite_rounded,
    ),
    QuickReply(
      text: 'Как много есть?',
      icon: Icons.restaurant_rounded,
    ),
    QuickReply(
      text: 'Не засыпаю',
      icon: Icons.bedtime_rounded,
    ),
    QuickReply(
      text: 'Упала мотивация',
      icon: Icons.trending_down_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AICoachProvider>().initChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Column(
        children: [
          _buildSliverAppBar(),
          Expanded(
            child: Consumer<AICoachProvider>(
              builder: (context, coachProvider, _) {
                if (coachProvider.messages.isEmpty &&
                    !coachProvider.isLoading) {
                  return _buildEmptyState();
                }

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: coachProvider.messages.length +
                          (coachProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= coachProvider.messages.length) {
                          return const TypingIndicator();
                        }

                        final message = coachProvider.messages[index];
                        return MessageBubble(
                          message: message,
                          index: index,
                          onActionTap: () {
                            _scrollToBottom();
                          },
                        );
                      },
                    ),
                    if (coachProvider.messages.isNotEmpty &&
                        !coachProvider.isLoading)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: const Color(0xFF6C5CE7),
                          onPressed: _scrollToBottom,
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (context.watch<AICoachProvider>().messages.isNotEmpty)
            QuickSuggestionsWidget(
              suggestions: _quickReplies,
              onSuggestionSelected: (text) {
                _textController.text = text;
                _sendMessage();
              },
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFF0A0E21)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Коуч',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Онлайн',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  _showInfoDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Привет! Я твой AI фитнес-коуч',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Задай мне любой вопрос о тренировках,\nпитании или здоровье',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildQuickPrompt(
            'Составь план тренировок',
            Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 12),
          _buildQuickPrompt(
            'Помоги с питанием',
            Icons.restaurant_rounded,
          ),
          const SizedBox(height: 12),
          _buildQuickPrompt(
            'Мотивация для тренировки',
            Icons.emoji_events_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String text, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _textController.text = text;
            _sendMessage();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6C5CE7), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey[800]!.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  minLines: 1,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Напиши сообщение...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    counterText: '',
                  ),
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      _fabAnimationController.forward();
                    } else {
                      _fabAnimationController.reverse();
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Consumer<AICoachProvider>(
              builder: (context, coachProvider, _) {
                return ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _fabAnimationController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: coachProvider.isLoading ? null : _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: coachProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty &&
        !context.read<AICoachProvider>().isLoading) {
      context.read<AICoachProvider>().sendMessage(_textController.text);
      _textController.clear();
      _fabAnimationController.reverse();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'О коуче',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Я - твой персональный AI фитнес-коуч. '
          'Я анализирую твои данные (метрики, историю тренировок, '
          'сон и питание) и даю рекомендации на основе вашей '
          'уникальной ситуации.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Ясно',
              style: TextStyle(color: Color(0xFF6C5CE7)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }
}
