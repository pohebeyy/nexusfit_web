import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:startap/screens/home/home_screen.dart';

/// Экран финальной стратегии с симуляцией прогресса
class YourStrategyScreen extends StatefulWidget {
  const YourStrategyScreen({super.key});

  @override
  State<YourStrategyScreen> createState() => _YourStrategyScreenState();
}

class _YourStrategyScreenState extends State<YourStrategyScreen>
    with TickerProviderStateMixin {
  // Анимационные контроллеры
  late AnimationController _mainController;
  late AnimationController _graphController;
  late AnimationController _pulseController;
  late AnimationController _counterController;

  // Анимации
  late Animation<double> _headerFade;
  late Animation<double> _graphProgress;
  late Animation<double> _cardsScale;
  late Animation<double> _listFade;

  // Данные пользователя (Mock)
  final Map<String, dynamic> _userStrategy = {
    'currentWeight': 80.0,
    'targetWeight': 90.0,
    'bmi': 24.5,
    'metabolism': 'Быстрый',
    'bodyType': 'Эктоморф',
    'experience': 'Новичок',
    'weeks': 12,
  };

  @override
  void initState() {
    super.initState();

    // 1. Основной контроллер появления элементов
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 2. Контроллер отрисовки графика
    _graphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 3. Контроллер пульсации кнопки
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // 4. Контроллер для счетчиков чисел
    _counterController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
    );

    // Настройка анимаций
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _graphProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _graphController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _cardsScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _listFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    // Запуск последовательности
    _playAnimationSequence();
  }

  Future<void> _playAnimationSequence() async {
    await _mainController.forward(); // Появляется заголовок
    _graphController.forward();      // Рисуется график
    _counterController.forward();    // Крутятся цифры
  }

  @override
  void dispose() {
    _mainController.dispose();
    _graphController.dispose();
    _pulseController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(
        children: [
          // Основной контент
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      _buildAnimatedHeader(),
                      const SizedBox(height: 32),
                      _buildGraphSimulation(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 32),
                      _buildStrategySummary(),
                      const SizedBox(height: 100), // Отступ под кнопку
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Закрепленная кнопка снизу
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyButton(),
          ),
        ],
      ),
    );
  }

  // --- Header ---
  Widget _buildAnimatedHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypingText('Твой план готов!'),
          const SizedBox(height: 8),
          Text(
            'AI проанализировал твои данные и создал персональную стратегию трансформации.',
            style: TextStyle(
              color: const Color(0xFFB0B5C0).withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingText(String text) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Text(
          text.substring(0, value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }

  // --- Graph Simulation ---
  Widget _buildGraphSimulation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ПРОГНОЗ ТРАНСФОРМАЦИИ',
          style: TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: AnimatedBuilder(
            animation: _graphProgress,
            builder: (context, child) {
              return CustomPaint(
                painter: StrategyGraphPainter(
                  progress: _graphProgress.value,
                  startVal: _userStrategy['currentWeight'],
                  endVal: _userStrategy['targetWeight'],
                ),
                child: Container(),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Stats Grid (2x2) ---
  Widget _buildStatsGrid() {
    return ScaleTransition(
      scale: _cardsScale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ТВОИ ПОКАЗАТЕЛИ',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                icon: Icons.speed,
                title: 'BMI',
                content: AnimatedCounter(
                    value: _userStrategy['bmi'], 
                    suffix: '', 
                    controller: _counterController
                ),
                color: const Color(0xFF00FF88),
              ),
              _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'МЕТАБОЛИЗМ',
                content: Text(_userStrategy['metabolism'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                color: const Color(0xFFFF5252),
              ),
              _buildStatCard(
                icon: Icons.bar_chart,
                title: 'ОПЫТ',
                content: Text(_userStrategy['experience'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                color: const Color(0xFF00D9FF),
              ),
              _buildStatCard(
                icon: Icons.flag,
                title: 'ДО ЦЕЛИ',
                content: Text('~${_userStrategy['weeks']} недель', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                color: const Color(0xFFE040FB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required Widget content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                child: content,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Strategy Summary ---
  Widget _buildStrategySummary() {
    return FadeTransition(
      opacity: _listFade,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00D9FF).withOpacity(0.05),
              const Color(0xFF00D9FF).withOpacity(0.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF00D9FF), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'КЛЮЧЕВЫЕ ФАКТОРЫ УСПЕХА',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSummaryItem(
              'Силовые 3 раза в неделю',
              'Акцент: Грудь, Спина',
              Icons.fitness_center,
            ),
            _buildSummaryItem(
              'Профицит +300 ккал',
              'Высокое содержание белка',
              Icons.restaurant,
            ),
            _buildSummaryItem(
              'Сон 8 часов',
              'Восстановление ЦНС',
              Icons.bedtime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, color: const Color(0xFF00FF88), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Sticky Button ---
  Widget _buildStickyButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A0E27).withOpacity(0.0),
            const Color(0xFF0A0E27),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.03), // Легкая пульсация
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4538), Color(0xFFFF4538)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                
              ),
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '🚀  ЗАПУСТИТЬ ТРАНСФОРМАЦИЮ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Custom Painters & Widgets ---

/// Отрисовщик анимированного графика
class StrategyGraphPainter extends CustomPainter {
  final double progress; // от 0.0 до 1.0
  final double startVal;
  final double endVal;

  StrategyGraphPainter({
    required this.progress,
    required this.startVal,
    required this.endVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Координаты
    final startY = size.height * 0.8;
    final endY = size.height * 0.2;
    final width = size.width;

    // Кривая Безье для плавности
    path.moveTo(0, startY);
    
    // Рисуем часть пути в зависимости от прогресса
    // Для простоты используем квадратичную кривую
    final controlX = width * 0.5;
    final controlY = startY; // Прогиб вниз для эффекта "разгона"

    // В реальном проекте здесь нужна сложная математика для частичного рисования кривой
    // Здесь мы упростим: рисуем линию до текущего X
    
    final currentX = width * progress;
    // Интерполяция Y (линейная для простоты примера, можно заменить на кривую)
    final currentY = startY + (endY - startY) * progress;

    // Рисуем градиент под графиком
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, startY);
    fillPath.quadraticBezierTo(
        currentX * 0.5, 
        startY + (currentY - startY) * 0.5, // Простая интерполяция
        currentX, 
        currentY
    );
    fillPath.lineTo(currentX, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00D9FF).withOpacity(0.2),
          const Color(0xFF00D9FF).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, size.height));
      
    canvas.drawPath(fillPath, fillPaint);

    // Рисуем саму линию
    // Для анимации рисования линии используем простой lineTo до текущей точки
    // (для полноценной кривой нужно использовать PathMetrics)
    canvas.drawLine(const Offset(0, 0.0) + Offset(0, startY), Offset(currentX, currentY), paint);

    // Точка старта
    if (progress > 0.0) {
      canvas.drawCircle(Offset(0, startY), 4, Paint()..color = Colors.white);
    }

    // Точка финиша (появляется в конце)
    if (progress >= 0.95) {
      // Светящийся эффект
      final glowPaint = Paint()
        ..color = const Color(0xFF00FF88).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(width, endY), 12, glowPaint);
      
      canvas.drawCircle(Offset(width, endY), 6, Paint()..color = const Color(0xFF00FF88));
      
      // Текст финиша
      final textSpan = TextSpan(
        text: '${endVal.toInt()} кг',
        style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(width - textPainter.width, endY - 25));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Виджет для "накручивания" чисел
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String suffix;
  final AnimationController controller;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.suffix,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final currentVal = (value * controller.value).toStringAsFixed(1);
        return Text(
          '$currentVal$suffix',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
