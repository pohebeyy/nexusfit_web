import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/screens/home/TodayWorkoutCardState.dart';
import 'package:startap/widgets/appnar.dart';
import 'package:startap/widgets/workout_calendar.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/health_provider.dart';
import '../nutrition/nutrition_dashboard.dart';
import '../ai_coach/chat_screen.dart';
import '../workouts/workout_plan_screen.dart';
import '../analytics/health_dashboard.dart';

// custom scroll behavior allowing both touch and mouse input; useful on web/mobile
class _WebTouchScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  final PageController _pageController = PageController(initialPage: 2);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void switchToStats() {
    const statsIndex = 3;
    setState(() => _selectedIndex = statsIndex);
    _pageController.animateToPage(
      statsIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF1C1C1E),
    body: LayoutBuilder(
      builder: (context, constraints) {
        // on web/mobile we disable horizontal swiping to avoid
        // interference with vertical scrolls. users can still tap nav.
        final disableSwipe = kIsWeb || constraints.maxWidth < 600;
        return PageView(
          controller: _pageController,
          physics: disableSwipe ? const NeverScrollableScrollPhysics() : null,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: [
            const NutritionDashboard(),
            const WorkoutPlanScreen(),
            _HomePageContent(switchToStats: switchToStats),
            const HealthDashboard(),
            const ChatScreen(),
          ],
        );
      },
    ),
    bottomNavigationBar: _buildModernBottomNav(),
  );
}

Widget _buildModernBottomNav() {
  return SafeArea(
    top: false,
    child: Material(
      color: const Color(0xFF1C1C1E),
      elevation: 4,
      child: SizedBox(
        height: kBottomNavigationBarHeight + 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.restaurant_rounded, 'ПИТАНИЕ'),
            _buildNavItem(1, Icons.fitness_center_rounded, 'ТРЕНИРОВКИ'),
            _buildNavItem(2, Icons.home_rounded, ''),
            _buildNavItem(3, Icons.analytics_rounded, 'СТАТИСТИКА'),
            _buildNavItem(4, Icons.psychology_rounded, 'AI КОУЧ'),
          ],
        ),
      ),
    ),
  );
}

Widget _buildNavItem(int index, IconData icon, String label) {
  final isSelected = _selectedIndex == index;
  final isHome = index == 2;

  return Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHome)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF3B30),
                      Color(0xFFFF6B6B),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B30).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              )
            else ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

}

class _HomePageContent extends StatelessWidget {
  final VoidCallback switchToStats;

  const _HomePageContent({required this.switchToStats});

  @override
Widget build(BuildContext context) {
  return RefreshIndicator(
    onRefresh: () async {
      context.read<HealthProvider>().initHealthData();
      context.read<WorkoutProvider>().initWorkouts();
      context.read<NutritionProvider>().init();
    },
    backgroundColor: const Color(0xFF1D1E33),
    color: const Color(0xFF6C5CE7),
    child: ScrollConfiguration(
      behavior: _WebTouchScrollBehavior(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        Appnar.buildModernAppBar(context, "Главная"),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                WeeklyOverviewCalendar(
                  onOpenStats: switchToStats,
                ),
                const SizedBox(height: 24),

                const TodayWorkoutCard(),
                const SizedBox(height: 24),

                const SizedBox(height: 16),

                SizedBox(
                  height: 320, // Увеличьте это значение (было 250)
                  child: PageView(
                    padEnds: false,
                    physics: const BouncingScrollPhysics(),
                    controller: PageController(viewportFraction: 0.9),
                    children: const [
                      FlipMetricCard.sleep(),
                      FlipMetricCard.nutrition(),
                      FlipMetricCard.activity(),
                      FlipMetricCard.water(),
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
    )
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
      case FlipCardType.nutrition:
        return const NutritionFrontCard();
      case FlipCardType.activity:
        return const ActivityFrontCard();
      case FlipCardType.water:
        return const WaterFrontCard();
    }
  }

  Widget _buildBack() {
    switch (widget.type) {
      case FlipCardType.sleep:
        return const SleepBackCard();
      case FlipCardType.nutrition:
        return const NutritionBackCard();
      case FlipCardType.activity:
        return const ActivityBackCard();
      case FlipCardType.water:
        return const WaterBackCard();
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

class SleepFrontCard extends StatelessWidget {
  const SleepFrontCard({super.key});

  @override
  Widget build(BuildContext context) {
    
    
    return _BaseFlipCardContainer(
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ИНСАЙТ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ГОТОВНОСТЬ ЦНС: СРЕДНЯЯ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaveBar(0.3),
              _buildWaveBar(0.5),
              _buildWaveBar(0.7),
              _buildWaveBar(0.9),
              _buildWaveBar(0.7),
              _buildWaveBar(0.5),
              _buildWaveBar(0.3),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ты не доспал 1.5 часа. Снижаю интенсивность тренировки на 10%, чтобы избежать перегрузки.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ, ЧТОБЫ ВЕРНУТЬСЯ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 6,
      height: 40 * height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF5E5CE6),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class SleepBackCard extends StatelessWidget {
  const SleepBackCard({super.key});

  @override
  Widget build(BuildContext context) {
    const sleepScore = 81;

    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: Color(0xFF5E5CE6), size: 20),
              const SizedBox(width: 8),
              Text(
                'СОН',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: sleepScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5E5CE6)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '$sleepScore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'баллов',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Вчера: 6 ч 30 мин / 8 ч',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Дефицит: 1 ч 30 мин',
            style: TextStyle(
              color: Color(0xFFFF9500),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ ДЛЯ AI-СОВЕТА',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionFrontCard extends StatelessWidget {
  const NutritionFrontCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ИНСАЙТ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'БАЛАНС МАКРОСОВ: ХОРОШИЙ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaveBar(0.4, const Color(0xFF32D74B)),
              _buildWaveBar(0.6, const Color(0xFF32D74B)),
              _buildWaveBar(0.8, const Color(0xFF32D74B)),
              _buildWaveBar(1.0, const Color(0xFF32D74B)),
              _buildWaveBar(0.8, const Color(0xFF32D74B)),
              _buildWaveBar(0.6, const Color(0xFF32D74B)),
              _buildWaveBar(0.4, const Color(0xFF32D74B)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Калории: 1850 / 2200 ккал. Добавь 30г белка на полдник для оптимального восстановления мышц.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ, ЧТОБЫ ВЕРНУТЬСЯ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height, Color color) {
    return Container(
      width: 6,
      height: 40 * height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class NutritionBackCard extends StatelessWidget {
  const NutritionBackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_rounded, color: Color(0xFFFF9500), size: 20),
              const SizedBox(width: 8),
              Text(
                'ПИТАНИЕ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Калории: 1850 / 2200 ккал',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 1850 / 2200,
            minHeight: 6,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9500)),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          const Text(
            'БЖУ: 145г / 78г / 210г',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMacroBar('Б', 145 / 180, const Color(0xFF32D74B)),
              const SizedBox(width: 8),
              _buildMacroBar('Ж', 78 / 90, const Color(0xFFFF9500)),
              const SizedBox(width: 8),
              _buildMacroBar('У', 210 / 250, const Color(0xFF5E5CE6)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ ДЛЯ AI-СОВЕТА',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, double progress, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}


class ActivityFrontCard extends StatelessWidget {
  const ActivityFrontCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ИНСАЙТ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_run_rounded,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'УРОВЕНЬ АКТИВНОСТИ: УМЕРЕННЫЙ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaveBar(0.5, const Color(0xFF00D9FF)),
              _buildWaveBar(0.7, const Color(0xFF00D9FF)),
              _buildWaveBar(0.9, const Color(0xFF00D9FF)),
              _buildWaveBar(0.7, const Color(0xFF00D9FF)),
              _buildWaveBar(0.5, const Color(0xFF00D9FF)),
              _buildWaveBar(0.6, const Color(0xFF00D9FF)),
              _buildWaveBar(0.8, const Color(0xFF00D9FF)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Шаги: 8,230 / 10,000. Хорошая активность во второй половине дня. Добавь лёгкую утреннюю прогулку.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ, ЧТОБЫ ВЕРНУТЬСЯ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height, Color color) {
    return Container(
      width: 6,
      height: 40 * height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
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
              const Icon(Icons.directions_run_rounded, color: Color(0xFF00D9FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'АКТИВНОСТЬ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Активные ккал: 450 / 600',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 450 / 600,
            minHeight: 6,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Шаги: 8,230 • Время: 68 мин',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Статус: Умеренно активный',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ ДЛЯ AI-СОВЕТА',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaterFrontCard extends StatelessWidget {
  const WaterFrontCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ИНСАЙТ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ГИДРАТАЦИЯ: ОПТИМАЛЬНАЯ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaveBar(0.6, const Color(0xFF5AC8FA)),
              _buildWaveBar(0.8, const Color(0xFF5AC8FA)),
              _buildWaveBar(1.0, const Color(0xFF5AC8FA)),
              _buildWaveBar(0.9, const Color(0xFF5AC8FA)),
              _buildWaveBar(0.7, const Color(0xFF5AC8FA)),
              _buildWaveBar(0.8, const Color(0xFF5AC8FA)),
              _buildWaveBar(0.6, const Color(0xFF5AC8FA)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Выпито: 1800 / 2000 мл. Выпей 300 мл за 30 мин до тренировки для максимальной производительности.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ, ЧТОБЫ ВЕРНУТЬСЯ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height, Color color) {
    return Container(
      width: 6,
      height: 40 * height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class WaterBackCard extends StatelessWidget {
  const WaterBackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: Color(0xFF5AC8FA), size: 20),
              const SizedBox(width: 8),
              Text(
                'ВОДА',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Выпито: 1800 / 2000 мл',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 1800 / 2000,
            minHeight: 6,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5AC8FA)),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Гидратация: 90%',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Статус: Норма',
            style: TextStyle(
              color: Color(0xFF5AC8FA),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'НАЖМИ ДЛЯ AI-СОВЕТА',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}