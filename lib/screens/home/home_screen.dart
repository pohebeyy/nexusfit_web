import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:startap/screens/home/TodayWorkoutCardState.dart';
import 'package:startap/widgets/HomeCalendarWidget.dart';
import 'package:startap/widgets/appnar.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/health_provider.dart';
import '../ai_coach/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/services/stat_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  // 0 - Home, 1 - AI Chat
  int selectedIndex = 0;

  // если у тебя был callback switchToStats - не трогаем
  void switchToStats() {
    // твоя логика, если была
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
    });
  }

 


  


  


  Future<void> _showAICoachDialog() async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верх: бейдж + аватар AI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.psychology_rounded,
                            size: 14, color: Color(0xFFFF3B30)),
                        SizedBox(width: 6),
                        Text(
                          'AI COACH',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[700]!,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'Как использовать AI‑коуча',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Пункты
              _AiCoachBullet(
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF5AC8FA),
                title: 'Сон',
                text:
                    'Напиши, сколько часов ты спал. Коуч учтёт это и подправит рекомендованную нагрузку на тренировке.',
              ),
              const SizedBox(height: 10),
              _AiCoachBullet(
                icon: Icons.autorenew_rounded,
                iconColor: const Color(0xFFFF9500),
                title: 'Замена упражнений',
                text:
                    'Если какое‑то упражнение не заходит или есть ограничения — напиши, и я предложу безопасную замену.',
              ),
              const SizedBox(height: 10),
              _AiCoachBullet(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFFFF3B30),
                title: 'Свободный формат',
                text:
                    'Задавай вопросы про технику, прогресс, восстановление и питание обычным языком — без шаблонов.',
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Окей, погнали чатиться',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomePageContent(
            switchToStats: switchToStats,
          ),
          const ChatScreen(), // AI‑коуч
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    const activeColor = Color(0xFFFF6B35);
    const inactiveColor = Colors.white;

    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // HOME
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/container.svg',
                        width: 26,
                        height: 26,
                        colorFilter: selectedIndex == 0
                            ? null
                            : const ColorFilter.mode(
                                inactiveColor,
                                BlendMode.srcIn,
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HOME',
                        style: TextStyle(
                          color: selectedIndex == 0
                              ? activeColor
                              : inactiveColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // AI
              // AI
GestureDetector(
  onTap: () async {
    setState(() {
      selectedIndex = 1;
    });

    // Туториал по AI только при первом заходе
    final prefs = await SharedPreferences.getInstance();
    final seenAI = prefs.getBool('seen_ai_tutorial_v1') ?? false;
    if (!seenAI && mounted) {
      await _showAICoachDialog();
      await prefs.setBool('seen_ai_tutorial_v1', true);
    }
  },
  child: Container(
    color: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.psychology_rounded,
          size: 26,
          color: selectedIndex == 1 ? activeColor : inactiveColor,
        ),
        const SizedBox(height: 4),
        Text(
          'AI',
          style: TextStyle(
            color: selectedIndex == 1 ? activeColor : inactiveColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}



class HomePageContent extends StatefulWidget {
  final VoidCallback switchToStats;
  const HomePageContent({super.key, required this.switchToStats});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  DateTime _selectedDate = DateTime.now();

  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _todayWorkoutKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runHomeTour();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _runHomeTour() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_home_tour_v1') ?? false;
    if (seen) return;

    await _showHighlightOver(calendar: true);
    await _showHighlightOver(calendar: false);

    await prefs.setBool('seen_home_tour_v1', true);
  }

  Future<void> _showHighlightOver({required bool calendar}) async {
    final key = calendar ? _calendarKey : _todayWorkoutKey;
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final box = renderObject;
    final offset = box.localToGlobal(Offset.zero);
    final rect = offset & box.size;

    final completer = Completer<void>();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // затемнённый фон
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _removeOverlay();
                  if (!completer.isCompleted) completer.complete();
                },
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            ),

            // подсвеченная область вокруг виджета
            Positioned(
              left: rect.left - 8,
              top: rect.top - 8,
              width: rect.width + 16,
              height: rect.height + 16,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6B35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.45),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // карточка-подсказка под элементом
            Positioned(
              left: 20,
              right: 20,
              top: rect.bottom + 12,
              child: _HomeTourTooltip(
                title: calendar ? 'Календарь' : 'План на сегодня',
                text: calendar
                    ? 'Тапни по дате, чтобы посмотреть будущие тренировки и заранее понимать нагрузку.'
                    : 'Тапни по карточке, чтобы открыть тренировки на сегодня и детали по каждому упражнению.',
                onClose: () {
                  _removeOverlay();
                  if (!completer.isCompleted) completer.complete();
                },
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HealthProvider>().initHealthData();
        await context.read<WorkoutProvider>().initWorkouts();
        await context.read<NutritionProvider>().init();
      },
      backgroundColor: const Color(0xFF2C2C2E),
      color: const Color(0xFFFF4538),
      child: CustomScrollView(
        slivers: [
          Appnar.buildModernAppBar(context, 'Главная'),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // 1. Календарь с ключом для онбординга
                  HomeCalendarWidget(
                    key: _calendarKey,
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // 2. TodayWorkoutCard с ключом для онбординга
                  TodayWorkoutCard(
                    key: _todayWorkoutKey,
                    selectedDate: _selectedDate,
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 320,
                    child: PageView(
                      padEnds: false,
                      controller: PageController(viewportFraction: 0.9),
                      children: const [
                        FlipMetricCard.sleep(),
                        FlipMetricCard.activity(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// тултип для тура по главному экрану
class _HomeTourTooltip extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback onClose;

  const _HomeTourTooltip({
    required this.title,
    required this.text,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.45),
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onClose,
                child: const Text(
                  'ДАЛЬШЕ',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





enum FlipCardType { sleep, nutrition, activity, water }

class FlipMetricCard extends StatefulWidget {
  final FlipCardType type;

  const FlipMetricCard._(this.type, {super.key});

  const FlipMetricCard.sleep({super.key}) : type = FlipCardType.sleep;
  const FlipMetricCard.nutrition({super.key}) : type = FlipCardType.nutrition;
  const FlipMetricCard.activity({super.key}) : type = FlipCardType.activity;
  const FlipMetricCard.water({super.key}) : type = FlipCardType.water;

  @override
  State<FlipMetricCard> createState() => _FlipMetricCardState();
}

class _FlipMetricCardState extends State<FlipMetricCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159;
          final isFrontVisible = angle <= 3.14159 / 2;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: isFrontVisible
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

    Widget _buildFront() {
    switch (widget.type) {
      case FlipCardType.sleep:
        return const SleepFrontCard();
      case FlipCardType.activity:
        return const ActivityFrontCard();
      default:
        return const SizedBox.shrink(); 
    }
  }

  Widget _buildBack() {
    switch (widget.type) {
      case FlipCardType.sleep:
        return const SleepBackCard();
      case FlipCardType.activity:
        return const ActivityBackCard();
      default:
        return const SizedBox.shrink(); 
    }
  }

}

class _BaseFlipCardContainer extends StatelessWidget {
  final Widget child;

  const _BaseFlipCardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SleepFrontCard extends StatefulWidget {
  const SleepFrontCard({super.key});

  @override
  State<SleepFrontCard> createState() => _SleepFrontCardState();
}

class _SleepFrontCardState extends State<SleepFrontCard> {
  double _sleepHours = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Достаем сохраненное количество часов (если вы его сохраняете в провайдере)
      // Если вы еще не сохраняете саму цифру в AICoachProvider, добавьте туда: 
      // await prefs.setDouble('last_sleep_hours', hours); 
      // во время вызова _handleSleepLogInput
      final hours = prefs.getDouble('last_sleep_hours') ?? 8.0; 

      if (mounted) {
        setState(() {
          _sleepHours = hours;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Высчитываем процент качества сна (идеал = 8 часов)
    double targetSleep = 8.0;
    double sleepScoreRaw = (_sleepHours / targetSleep).clamp(0.0, 1.0);
    int sleepScorePercent = (sleepScoreRaw * 100).toInt();

    // 2. Определяем цвета и статус в зависимости от сна
    Color mainColor;
    String statusText;

    if (_sleepHours >= 7.0) {
      mainColor = const Color(0xFF5AC8FA); // Голубой - отлично
      statusText = 'ЦНС ВОССТАНОВЛЕНА: НАГРУЗКА 100%';
    } else if (_sleepHours >= 5.5) {
      mainColor = const Color(0xFFFF9500); // Оранжевый - средне
      statusText = 'НЕЙРОКОЛЛАЙДЕР: НАГРУЗКА СНИЖЕНА';
    } else {
      mainColor = const Color(0xFFFF3B30); // Красный - плохо
      statusText = 'КРИТИЧЕСКИЙ НЕДОСЫП: РЕЖИМ ЛАЙТ';
    }

    return _BaseFlipCardContainer(
      child: _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF5AC8FA)))
      : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDotIndicator(),
              Row(
                children: [
                  const Text(
                    'СОН',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mainColor, // Динамический цвет
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.nightlight_round, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Сегментированный круг с помощью стандартного индикатора
          SizedBox(
            width: 140, // Увеличили ширину (было 130)
            height: 140, // Увеличили высоту (было 130)
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140, // Указываем размеры явно для CircularProgressIndicator
                  height: 140,
                  child: CircularProgressIndicator(
                    value: sleepScoreRaw, // Динамическое заполнение круга
                    strokeWidth: 12, // Сделали линию чуть толще (было 10)
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor), // Динамический цвет
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$sleepScorePercent%', // Динамический процент
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 42, // Увеличили размер шрифта (было 36)
                        fontWeight: FontWeight.w800, 
                        height: 1.0
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ОЦЕНКА',
                      style: TextStyle(
                        color: Colors.white54, 
                        fontSize: 11, // Чуть увеличили подпись (было 10)
                        fontWeight: FontWeight.w700, 
                        letterSpacing: 1.0
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1), // Слегка подкрашиваем фон плашки
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mainColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText, // Динамический текст
                  style: TextStyle(color: mainColor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                const SizedBox(width: 6),
                Icon(Icons.bolt_rounded, color: mainColor, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTapToExpand(),
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildTapToExpand() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'НАЖМИ, ЧТОБЫ РАЗВЕРНУТЬ',
            style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          SizedBox(width: 4),
          Icon(Icons.adjust_rounded, color: Colors.white54, size: 12),
        ],
      ),
    );
  }
}

class SleepBackCard extends StatelessWidget {
  const SleepBackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.nightlight_round, color: Colors.white54, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI ИНСАЙТ',
                style: TextStyle(color: Color(0xFFFF3B30), fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFFFF3B30), size: 16),
              SizedBox(width: 6),
              Text(
                'ГОТОВНОСТЬ ЦНС',
                style: TextStyle(color: Color(0xFFFF3B30), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Градиентный график готовности ЦНС
          _buildRedBarChart(),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Сон поверхностный. Фокус снижен. ИИ убрал 2 подхода из становой тяги, чтобы не перегрузить ЦНС.',
                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'НАЖМИ, ЧТОБЫ ВЕРНУТЬСЯ',
              style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedBarChart() {
    final heights = [15.0, 25.0, 15.0, 30.0, 45.0, 25.0, 25.0, 40.0, 20.0, 10.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(heights.length, (index) {
        return Container(
          width: 14,
          height: heights[index],
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF8B1A2B), // Темно-красный внизу
                Color(0xFFFF3B30), // Ярко-красный вверху
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}



class ActivityFrontCard extends StatefulWidget {
  const ActivityFrontCard({super.key});

  @override
  State<ActivityFrontCard> createState() => _ActivityFrontCardState();
}

class _ActivityFrontCardState extends State<ActivityFrontCard> {
  int _activeCalories = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivityData();
  }

  Future<void> _fetchActivityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
      final today = DateTime.now();

      // Запрашиваем данные за сегодня
      final activityData = await StatService.fetchDailyActivity(userEmail, today);

      if (mounted) {
        setState(() {
          if (activityData != null) {
            _activeCalories = activityData['active_calories'] ?? 0;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки калорий в ActivityFrontCard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Верхняя строка с точкой и заголовком
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDotIndicator(),
              Row(
                children: [
                  const Text(
                    'АКТИВНОСТЬ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          
          // Основные данные (Центр)
          _isLoading 
            ? const SizedBox(
                height: 40, 
                child: Center(
                  child: SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF3B30), 
                      strokeWidth: 2
                    )
                  )
                )
              )
            : Text(
                '$_activeCalories', // <--- ЗДЕСЬ ПОДСТАВЛЯЮТСЯ РЕАЛЬНЫЕ ДАННЫЕ
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              
          const SizedBox(height: 4),
          const Text(
            'АКТИВНЫЕ ККАЛ',
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          
          // График гистограммы
          _buildBarChart(),
          const Spacer(),
          
          // Нижние плашки
          _buildTapToExpand(),
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Высоты столбцов для имитации графика
    final heights = [10.0, 15.0, 12.0, 25.0, 45.0, 65.0, 40.0, 90.0, 70.0, 35.0, 25.0, 20.0, 15.0, 25.0, 20.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(heights.length, (index) {
        final isMax = index == 7; // Выделяем самый высокий столбец красным
        return Container(
          width: 8,
          height: heights[index],
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isMax ? const Color(0xFFFF3B30) : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildTapToExpand() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'НАЖМИ, ЧТОБЫ РАЗВЕРНУТЬ',
            style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          SizedBox(width: 4),
          Icon(Icons.adjust_rounded, color: Colors.white54, size: 12),
        ],
      ),
    );
  }
}
class _AiCoachBullet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;

  const _AiCoachBullet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class ActivityBackCard extends StatelessWidget {
  const ActivityBackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white54, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI ИНСАЙТ',
                style: TextStyle(color: Color(0xFFFF3B30), fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFFFF3B30), size: 16),
              SizedBox(width: 6),
              Text(
                'АНАЛИЗ ЭНЕРГИИ',
                style: TextStyle(color: Color(0xFFFF3B30), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Высокая бытовая активность. Лактат утилизирован. Выполни 5 минут МФР на икры, чтобы снять спазм перед сном.',
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'НАЖМИ, ЧТОБЫ ВЕРНУТЬСЯ',
              style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}