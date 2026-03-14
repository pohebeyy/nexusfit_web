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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/services/stat_service.dart';
import 'dart:async';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  // 0 - Home, 1 - AI Chat
  int selectedIndex = 0;

  
  final GlobalKey _aiTabKey = GlobalKey();
  final GlobalKey<ChatScreenState> _chatKey = GlobalKey<ChatScreenState>();
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
            aiTabKey: _aiTabKey,
          ),
          ChatScreen(key: _chatKey), // AI‑коуч
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
  key: _aiTabKey,
  onTap: () async {
    setState(() {
      selectedIndex = 1;
    });

    // даём экрану отрисоваться
    await Future.delayed(const Duration(milliseconds: 200));

    // ДЛЯ ТЕСТОВ: всегда показываем тур
    _chatKey.currentState?.startChatTour(forceForTests: true);


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
  final GlobalKey aiTabKey;
  
  const HomePageContent({
    super.key,
    required this.switchToStats,
    required this.aiTabKey,
  });

  @override
  State<HomePageContent> createState() => HomePageContentState();
}

class HomePageContentState extends State<HomePageContent> {
  DateTime selectedDate = DateTime.now();
  
  // Ключи должны быть глобальными переменными класса!
  final GlobalKey calendarKey = GlobalKey();
  final GlobalKey todayWorkoutKey = GlobalKey();
  final GlobalKey metricsKey = GlobalKey();
  
  final ScrollController scrollController = ScrollController();
  TutorialCoachMark? _tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    // Вызываем runHomeTour (без нижнего подчеркивания)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      runHomeTour();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  Future<void> focusElement(GlobalKey key) async {
    try {
      final context = key.currentContext;
      if (context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 600), // Плавный долгий скролл
          curve: Curves.easeInOutCubic, // Красивая кривая ускорения-торможения
          alignment: 0.5, // По центру экрана
        );
        await Future.delayed(const Duration(milliseconds: 200)); // Ждем, чтобы глаз успел сфокусироваться
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Показывает один конкретный шаг туториала
  Future<void> showTutorialStep(int stepIndex) async {
    if (!mounted) return;

    late GlobalKey targetKey;
    late String title;
    late String text;
    late ContentAlign align;

    switch (stepIndex) {
      case 0:
        targetKey = calendarKey;
        title = 'АДАПТИВНЫЙ ГРАФИК';
        text = 'Забудь про тупой подход и жесткие рамки. Neuro-Collider™ перестраивает твои дни отдыха и тренировок на лету. Просто следуй плану.';
        align = ContentAlign.bottom;
        break;
      case 1:
        targetKey = todayWorkoutKey;
        title = 'ТРЕНИРОВКА ДНЯ';
        text = 'Интенсивность уже подобрана под твое состояние. Мало спал? Снизим веса. Ты на пике энергии? Дадим буст.';
        align = ContentAlign.bottom;
        break;
      case 2:
        targetKey = metricsKey;
        title = 'БИОМАШИНА НА ДАННЫХ';
        text = 'Свайпай и тапай карточки. Чем больше метрик ты отдаешь, тем точнее нейросеть управляет твоим прогрессом.';
        align = ContentAlign.top;
        break;
      case 3:
        targetKey = widget.aiTabKey;
        title = 'AI-НАСТАВНИК';
        text = 'Твой карманный бро. Напиши ему, если болит плечо или нет времени на зал — весь план перестроится за секунду.';
        align = ContentAlign.top;
        break;
      default:
        return;
    }

        final isLast = stepIndex == 3;

    final target = TargetFocus(
      identify: "step_$stepIndex",
      keyTarget: targetKey,
      shape: ShapeLightFocus.RRect, // Теперь ВСЕГДА прямоугольник
      radius: 20, // Скругление углов (можно сделать 20 или 24)
      contents: [

        TargetContent(
          align: align,
          builder: (context, controller) {
            return buildTourContent(
              title: title,
              text: text,
              controller: controller,
              stepIndex: stepIndex,
              isLast: isLast,
                            onNext: () async {
                // 1. Полностью убиваем текущий оверлей
                controller.skip();
                
                // 2. Ждем чуть дольше, чтобы анимация исчезновения точно завершилась
                // и Flutter удалил слой из дерева виджетов.
                await Future.delayed(const Duration(milliseconds: 400));
                
                if (!mounted) return;

                // 3. Выполняем скролл
                if (stepIndex < 3) {
                  late GlobalKey nextKey;
                  if (stepIndex == 0) nextKey = todayWorkoutKey;
                  else if (stepIndex == 1) nextKey = metricsKey;
                  else if (stepIndex == 2) nextKey = widget.aiTabKey;
                  
                  await focusElement(nextKey);
                  
                  // 4. ГЛАВНЫЙ ФИКС: Ждем дополнительно 100 мс после скролла, 
                  // чтобы Flutter успел просчитать layout (размеры) нового элемента.
                  await Future.delayed(const Duration(milliseconds: 100));
                }

                if (!mounted) return;

                // 5. Показываем следующий шаг только когда всё готово
                if (stepIndex < 3) {
                  await showTutorialStep(stepIndex + 1);
                } else {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen_hometour_v2', true);
                }
              },
              onPrev: () async {
                // 1. Полностью убиваем текущий оверлей
                controller.skip();
                
                await Future.delayed(const Duration(milliseconds: 400));
                
                if (!mounted) return;

                // 2. Выполняем скролл
                if (stepIndex > 0) {
                  late GlobalKey prevKey;
                  if (stepIndex == 1) prevKey = calendarKey;
                  else if (stepIndex == 2) prevKey = todayWorkoutKey;
                  else if (stepIndex == 3) prevKey = metricsKey;
                  
                  await focusElement(prevKey);
                  
                  // 3. ГЛАВНЫЙ ФИКС: Ждем перерисовки layout после скролла
                  await Future.delayed(const Duration(milliseconds: 100));
                }

                if (!mounted) return;

                // 4. Показываем предыдущий шаг
                if (stepIndex > 0) {
                  await showTutorialStep(stepIndex - 1);
                }
              },

            );
          },
        )
      ],
    );

        _tutorialCoachMark = TutorialCoachMark(
      targets: [target],
      colorShadow: Colors.black,
      textSkip: "ПРОПУСТИТЬ",
      paddingFocus: 5, // Строго положительное число или 0!
      opacityShadow: 0.8,
      hideSkip: true, // Скрываем стандартный skip, мы управляем им сами
      onClickTarget: (target) {
        // Запрещаем клики по самой выделенной области
      },
    )..show(context: context);
  }

    Future<void> runHomeTour() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    if (!isCurrentRoute) {
      Future.delayed(const Duration(seconds: 1), runHomeTour);
      return;
    }

    // --- НА ВРЕМЯ ТЕСТОВ ОТКЛЮЧАЕМ ПРОВЕРКУ ФЛАГА ---
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_hometour_v2') ?? false;
    if (seen) return;

    await focusElement(calendarKey);
    if (!mounted) return;
    await showTutorialStep(0);
  }


    // --- БЛОК 2: ВСТАВИТЬ ВМЕСТО СТАРОГО buildTourContent ---
  Widget buildTourContent({
    required String title,
    required String text,
    required TutorialCoachMarkController controller,
    int stepIndex = 0,
    required VoidCallback onNext,
    required VoidCallback onPrev,
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
                  Icons.auto_awesome,
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
              if (stepIndex > 0)
                GestureDetector(
                  onTap: onPrev,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'НАЗАД',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              if (stepIndex > 0) const SizedBox(width: 10),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  // --- КОНЕЦ БЛОКА 2 ---




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
        controller: scrollController,
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
                    key: calendarKey,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // 2. TodayWorkoutCard с ключом для онбординга
                  TodayWorkoutCard(
                    key: todayWorkoutKey,
                    selectedDate: selectedDate,
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 320,
                    child: PageView(
                      key: metricsKey,
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


enum FlipCardType { sleep, nutrition, activity, water }

class FlipMetricCard extends StatefulWidget {
  final FlipCardType type;

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