import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:startap/screens/home/TodayWorkoutCardState.dart';
import 'package:startap/widgets/HomeCalendarWidget.dart';
import 'package:startap/widgets/appnar.dart';
import 'package:startap/widgets/workout_calendar.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/health_provider.dart';
import '../nutrition/nutrition_dashboard.dart';
import '../ai_coach/chat_screen.dart';
import '../workouts/workout_plan_screen.dart';
import '../analytics/health_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Индекс 0 - это Главная (Home)
  // Индекс 1 - это AI Коуч (Chat)
  int _selectedIndex = 0;

  // Пустая функция для совместимости с HomePageContent,
  // так как экрана статистики больше нет
  void switchToStats() {
    // Ничего не делаем
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      // Используем IndexedStack, чтобы нельзя было свайпать экраны
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Индекс 0: Главный экран
          HomePageContent(switchToStats: switchToStats),
          // Индекс 1: AI Коуч
          const ChatScreen(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

     Widget _buildModernBottomNav() {
    // Вы можете поменять этот цвет, чтобы он точнее совпадал с оттенком вашей SVG-иконки
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
              // Кнопка 0: ГЛАВНАЯ
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 0),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/Container.svg',
                        width: 26,
                        height: 26,
                        // Если выбрана (0) -> фильтра нет (родной оранжевый цвет)
                        // Если не выбрана -> накладываем белый фильтр
                        colorFilter: _selectedIndex == 0
                            ? null
                            : const ColorFilter.mode(inactiveColor, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ГЛАВНАЯ',
                        style: TextStyle(
                          color: _selectedIndex == 0 ? activeColor : inactiveColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Кнопка 1: AI КОУЧ
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        size: 26,
                        // Если выбрана (1) -> красим в оранжевый, иначе в белый
                        color: _selectedIndex == 1 ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI КОУЧ',
                        style: TextStyle(
                          color: _selectedIndex == 1 ? activeColor : inactiveColor,
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HealthProvider>().initHealthData();
        await context.read<WorkoutProvider>().initWorkouts();
        await context.read<NutritionProvider>().init();
      },
      backgroundColor: const Color(0xFF1D1E33),
      color: const Color(0xFF6C5CE7),
      child: CustomScrollView(
        slivers: [
          Appnar.buildModernAppBar(context, 'Главная'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // 1. Используем новый умный календарь
                  HomeCalendarWidget(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Передаем выбранную дату в карточку тренировки
                  TodayWorkoutCard(selectedDate: _selectedDate),
                  
                  const SizedBox(height: 24),
                const SizedBox(height: 24),

                const SizedBox(height: 16),

                SizedBox(
                  height: 320, // Увеличьте это значение (было 250)
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

class SleepFrontCard extends StatelessWidget {
  const SleepFrontCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseFlipCardContainer(
      child: Column(
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
                      color: const Color(0xFF5AC8FA), // Голубой цвет
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
                    value: 0.81,
                    strokeWidth: 12, // Сделали линию чуть толще (было 10)
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5AC8FA)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '81%',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 42, // Увеличили размер шрифта (было 36)
                        fontWeight: FontWeight.w800, 
                        height: 1.0
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'НЕЙРОКОЛЛАЙДЕР: НАГРУЗКА СНИЖЕНА',
                  style: TextStyle(color: Color(0xFF5AC8FA), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                SizedBox(width: 6),
                Icon(Icons.bolt_rounded, color: Color(0xFF5AC8FA), size: 14),
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



class ActivityFrontCard extends StatelessWidget {
  const ActivityFrontCard({super.key});

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
          const Text(
            '840',
            style: TextStyle(
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


