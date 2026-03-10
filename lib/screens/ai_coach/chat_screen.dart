import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_coach_provider.dart';
import '../../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AICoachProvider>().initChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AICoachProvider>(
              builder: (context, coachProvider, _) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: coachProvider.messages.length + (coachProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == coachProvider.messages.length && coachProvider.isLoading) {
                      return _buildTypingIndicator();
                    }
                    final message = coachProvider.messages[index];
                    return _buildMessageBubble(message, index);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1C1C1E),
      elevation: 0,
      title: Row(
        children: [
          const Text(
            'AI Коуч',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Внутри ChatScreen -> _buildMessageBubble
Widget _buildMessageBubble(ChatMessage message, int index) {
  final isUser = message.isFromUser;
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.psychology_rounded, color: Colors.grey[500], size: 18),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Текстовый баббл
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF2C2C2E) : const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  message.content,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ),
              
              // ЕСЛИ ЭТО ЗАМЕНА, ПОКАЗЫВАЕМ КАРТОЧКУ
              if (message.isReplacement && message.oldExercise != null && message.newExercise != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    border: Border.all(color: Colors.grey[800]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.autorenew, color: Colors.grey[400], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'ПРЕДЛОЖЕНИЕ ПО ЗАМЕНЕ',
                            style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.close, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.oldExercise!,
                              style: TextStyle(color: Colors.grey[500], decoration: TextDecoration.lineThrough),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, top: 4, bottom: 4),
                        child: Icon(Icons.arrow_downward, color: Colors.blue[300], size: 16),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.check_box, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.newExercise!,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: message.isApplied 
                              ? null 
                              : () {
                                  context.read<AICoachProvider>().applyReplacement(message);
                                  // По желанию, можно показать SnackBar об успешной замене
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Тренировка обновлена')),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: message.isApplied ? Colors.grey[800] : const Color(0xFFFF453A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            message.isApplied ? 'ПРИМЕНЕНО' : 'ПРИМЕНИТЬ ИЗМЕНЕНИЯ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: Colors.grey[500],
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = ((value + delay) % 1.0);
        return Transform.translate(
          offset: Offset(0, -4 * (1 - (animValue * 2 - 1).abs())),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildMessageInput() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      border: Border(
        top: BorderSide(
          color: Colors.grey[900]!,
          width: 0.5,
        ),
      ),
    ),
    child: SafeArea(
      child: Column(
        children: [
          // Быстрые кнопки - 2 ряда
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickButton('БОЛИТ ПЛЕЧО'),
                const SizedBox(width: 8),
                _buildQuickButton('УПАЛА МОТИВАЦИЯ'),
                const SizedBox(width: 8),
                _buildQuickButton('КАК НАКАЧАТЬ ПРЕСС'),
                const SizedBox(width: 8),
                _buildQuickButton('ДИЕТА ДЛЯ ПОХУДЕНИЯ'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          const SizedBox(height: 12),
          // Поле ввода
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Напиши свой вопрос...',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic, color: Colors.grey[600]),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Consumer<AICoachProvider>(
                builder: (context, coachProvider, _) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF3B30),
                          Color(0xFFFF6B6B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: coachProvider.isLoading ? null : _sendMessage,
                        child: Center(
                          child: coachProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildQuickButton(String text) {
  return InkWell(
    onTap: () {
      _textController.text = text;
      _sendMessage();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}


  

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      context.read<AICoachProvider>().sendMessage(_textController.text);
      _textController.clear();
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
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
