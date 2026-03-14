import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../providers/ai_coach_provider.dart';
import '../../models/chat_message.dart';
import 'package:startap/screens/profile/profile.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late TutorialCoachMark _tutorialCoachMark;
  final GlobalKey quickButtonsKey = GlobalKey();
  final GlobalKey inputFieldKey = GlobalKey();

  bool _tourStartedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AICoachProvider>().initChat();
    });
  }

  // Публичный метод для запуска тура снаружи (из Home)
  // В проде: максимум 1 раз на аккаунт
  Future<void> startChatTour({bool forceForTests = false}) async {
    if (!mounted) return;

    // 1. Проверяем флаг в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_chat_tour_v1') ?? false;

    // Если уже показывали и нет force — выходим
    if (seen && !forceForTests) return;

    // Чтобы в рамках одной "жизни" экрана не спамить,
    // даже если кто-то дергает метод много раз подряд
    if (_tourStartedThisSession && !forceForTests) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _tourStartedThisSession = true;

    _showTutorial(prefs: prefs, forceForTests: forceForTests);
  }

  void _showTutorial({
    required SharedPreferences prefs,
    required bool forceForTests,
  }) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      paddingFocus: 5,
      opacityShadow: 0.8,
      textSkip: "",
      skipWidget: const SizedBox.shrink(),
      onFinish: () async {
        if (!forceForTests) {
          await prefs.setBool('seen_chat_tour_v1', true);
        }
      },
      onSkip: () {
        if (!forceForTests) {
          prefs.setBool('seen_chat_tour_v1', true);
        }
        return true;
      },
    );

    _tutorialCoachMark.show(context: context);
  }

  Widget _buildTourCard({
  required String title,
  required String text,
  required TutorialCoachMarkController controller,
  required int stepIndex,
  required VoidCallback onNext,
  required VoidCallback onPrev,
  required VoidCallback onSkip, // НОВОЕ
  bool isLast = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E).withOpacity(0.98),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFFF4538).withOpacity(0.6),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFF4538).withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4538), Color(0xFFFF6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFF4538),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ПРОПУСТИТЬ
            GestureDetector(
              onTap: onSkip,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'ПРОПУСТИТЬ',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // ДАЛЕЕ / ПОГНАЛИ
            GestureDetector(
              onTap: onNext,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4538), Color(0xFFFF6B35)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4538).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  isLast ? 'ПОГНАЛИ' : 'ДАЛЕЕ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  List<TargetFocus> _createTargets() {
  return [
    TargetFocus(
      identify: "quick_buttons",
      keyTarget: quickButtonsKey,
      shape: ShapeLightFocus.RRect,
      radius: 20,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return _buildTourCard(
              title: "БЫСТРЫЕ КОМАНДЫ",
              text:
                  "Нет времени писать простыню? Жми сюда — Neuro-Collider сразу понимает, что у тебя болит и адаптирует план.",
              controller: controller,
              stepIndex: 0,
              onNext: () => controller.next(),
              onPrev: () {}, // тут "Назад" не нужен
              onSkip: () async {
                controller.skip();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen_chat_tour_v1', true);
              },
              isLast: false,
            );
          },
        ),
      ],
    ),
    TargetFocus(
      identify: "input_field",
      keyTarget: inputFieldKey,
      shape: ShapeLightFocus.RRect,
      radius: 20,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return _buildTourCard(
              title: "NEURO-COLLIDER ВНУТРИ",
              text:
                  "Пиши сюда сон, стресс, травмы, дедлайны. Мы не просто болтаем — мы пересобираем тренировки и нагрузку под твое состояние.",
              controller: controller,
              stepIndex: 1,
              onNext: () async {
                // ПОГНАЛИ — завершаем и ставим флаг
                controller.skip();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen_chat_tour_v1', true);
              },
              onPrev: () => controller.previous(),
              onSkip: () async {
                controller.skip();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen_chat_tour_v1', true);
              },
              isLast: true,
            );
          },
        ),
      ],
    ),
  ];
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
                  itemCount: coachProvider.messages.length +
                      (coachProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == coachProvider.messages.length &&
                        coachProvider.isLoading) {
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
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'AI КОУЧ',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                color: const Color(0xFF2C2C2E),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isFromUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              child: Icon(Icons.psychology_rounded,
                  color: Colors.grey[500], size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.4),
                  ),
                ),
                if (message.isReplacement &&
                    message.oldExercise != null &&
                    message.newExercise != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
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
                            Icon(Icons.autorenew,
                                color: Colors.grey[400], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ПРЕДЛОЖЕНИЕ ПО ЗАМЕНЕ',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.close,
                                color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message.oldExercise!,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 2, top: 4, bottom: 4),
                          child: Icon(Icons.arrow_downward,
                              color: Colors.blue[300], size: 16),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.check_box,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message.newExercise!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                    context
                                        .read<AICoachProvider>()
                                        .applyReplacement(message);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Тренировка обновлена'),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: message.isApplied
                                  ? Colors.grey[800]
                                  : const Color(0xFFFF453A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              message.isApplied
                                  ? 'ПРИМЕНЕНО'
                                  : 'ПРИМЕНИТЬ ИЗМЕНЕНИЯ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Container(
              key: quickButtonsKey,
              child: SingleChildScrollView(
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
            ),
            const SizedBox(height: 12),
            Container(
              key: inputFieldKey,
              child: Row(
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
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon:
                                Icon(Icons.mic, color: Colors.grey[600]),
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
                            onTap: coachProvider.isLoading
                                ? null
                                : _sendMessage,
                            child: Center(
                              child: coachProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation(
                                                Colors.white),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
