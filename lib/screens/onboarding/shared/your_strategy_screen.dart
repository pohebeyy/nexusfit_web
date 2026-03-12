import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startap/providers/onboarding_provider.dart';
import 'dart:math' as math;

import 'package:startap/screens/home/home_screen.dart';

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

  bool _isLoading = true; // Пока true — показываем лоадер

  // Данные пользователя (будем заполнять из провайдера/AI)
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

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _graphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

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

    // Запускаем сбор данных/запрос к AI при старте экрана
    _fetchStrategyFromAI();
  }

  Future<void> _fetchStrategyFromAI() async {
  final provider = context.read<OnboardingProvider>();

  // 1. Берем базовые данные для расчетов графиков
  // currentWeight берем через геттер провайдера
  final currentWeight = provider.currentWeight ?? 80.0;
  
  // targetWeight берем через геттер провайдера (а не через provider.data)
  final targetWeight = provider.targetWeight ?? 75.0; 
  
  final heightCm = provider.data.height ?? 175.0;
  final h = heightCm / 100;
  final bmi = h > 0 ? currentWeight / (h * h) : 24.5;

  // 2. Достаем email и пароль пользователя
  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('user_email') ?? 'test@example.com';
  final userPassword = prefs.getString('user_password') ?? '123456';

  // 3. Формируем полную "посылку"
  final requestData = {
    'email': userEmail,
    'password': userPassword,
    // В OnboardingData нет поля name, поэтому пока ставим заглушку
    'name': 'Пользователь', 
    'goalText': provider.data.goal ?? 'general_fitness',
    // В OnboardingData нет bodyType (мы его определяли только по фото). Заглушка:
    'body_type': 'mesomorph', 
    'experience': provider.experienceLevel ?? 'beginner', // Через геттер
    'equipment': provider.equipment ?? ['собственный вес'], // Через геттер
    'training_location': provider.trainingLocation ?? 'gym', // Через геттер
    
    // sleepData у нас это Map<String, dynamic>, достаем часы (если есть) или дефолт 8
    'sleep_target_hours': provider.sleepData?['duration'] != null 
        ? int.tryParse(provider.sleepData!['duration'].toString().split('-').first) ?? 8 
        : 8, 
        
    'diet_restrictions': provider.dietRestrictions ?? [], // Через геттер
    'injuries': provider.data.healthIssues ?? [],
    'priority_zones': provider.targetZones ?? [], // Через геттер
    
    // Доп данные для математики на сервере
    'weightKg': currentWeight,
    'targetWeightKg': targetWeight,
    'heightCm': heightCm,
    'gender': provider.data.gender ?? 'male',
    // age в провайдере у тебя сделан отдельной переменной, но геттера для него нет. 
    // Давай добавим его или временно поставим 25. Пока ставим 25.
    'age': 25, 
  };

  // ... дальше твой try-catch с http.post


  try {
    // 4. Отправляем запрос в наш боевой n8n (Путь Б)
    // ВНИМАНИЕ: Замени URL на свой реальный Production-вебхук n8n!
    final url = Uri.parse('https://n8n.nexusfit.ru/webhook/reguserstrategy'); 
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      // 5. Парсим успешный ответ от n8n
      final responseData = jsonDecode(response.body);
      final strategy = responseData['strategy'];

      setState(() {
        _userStrategy['currentWeight'] = currentWeight;
        _userStrategy['targetWeight'] = targetWeight;
        _userStrategy['bmi'] = bmi;
        _userStrategy['experience'] = provider.data.experience ?? 'Новичок';
        
        // Подставляем данные, которые прислал n8n
        _userStrategy['metabolism'] = strategy['metabolism'] ?? 'Средний';
        _userStrategy['bodyType'] = strategy['bodyType'] ?? 'Мезоморф';
        _userStrategy['weeks'] = strategy['weeks'] ?? 12;

        _isLoading = false;
      });
    } else {
      // Если сервер вернул ошибку, ставим fallback (запасные) значения
      _setFallbackStrategy(currentWeight, targetWeight, bmi, provider);
    }
  } catch (e) {
    // Если вообще нет интернета или сервер упал
    if (mounted) {
      _setFallbackStrategy(currentWeight, targetWeight, bmi, provider);
    }
  }

  // Запускаем красивые анимации!
  _playAnimationSequence();
}



// Вспомогательный метод на случай сбоя сети
// Вспомогательный метод на случай сбоя сети
void _setFallbackStrategy(double currentWeight, double targetWeight, double bmi, OnboardingProvider provider) {
  setState(() {
    _userStrategy['currentWeight'] = currentWeight;
    _userStrategy['targetWeight'] = targetWeight;
    _userStrategy['bmi'] = bmi;
    
    // Используем маппер для опыта
    _userStrategy['experience'] = _mapExperience(provider.data.experience);
    
    _userStrategy['metabolism'] = 'Средний';
    _userStrategy['bodyType'] = 'Мезоморф';
    
    // Считаем недели грубо на телефоне
    int weeks = (currentWeight - targetWeight).abs() * 1.5 ~/ 1;
    _userStrategy['weeks'] = weeks < 4 ? 4 : (weeks > 24 ? 24 : weeks);
    
    _isLoading = false;
  });
}









    String _mapMetabolism(String? rawValue) {
    switch (rawValue?.toLowerCase()) {
      case 'slow': return 'Медленный';
      case 'average': 
      case 'normal': return 'Средний';
      case 'fast': return 'Быстрый';
      default: return 'Средний'; // Значение по умолчанию
    }
  }

  String _mapExperience(String? rawValue) {
    switch (rawValue?.toLowerCase()) {
      case 'complete_beginner': return 'Новичок';
      case 'beginner': return 'Начинающий';
      case 'intermediate': return 'Средний уровень';
      case 'advanced': return 'Продвинутый';
      case 'pro': return 'Опытный';
      default: return 'Новичок';
    }
  }

  String _mapBodyType(String? rawValue) {
    switch (rawValue?.toLowerCase()) {
      case 'ectomorph': return 'Эктоморф';
      case 'mesomorph': return 'Мезоморф';
      case 'endomorph': return 'Эндоморф';
      default: return 'Мезоморф';
    }
  }




  Future<void> _playAnimationSequence() async {
    await _mainController.forward();
    _graphController.forward();
    _counterController.forward();
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
    // Экран загрузки, пока ждем AI/n8n
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFF4538)),
              const SizedBox(height: 24),
              Text(
                'ИИ анализирует твои данные...',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Формируем персональную стратегию',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Основной контент
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(
        children: [
          // Основной контент
          ScrollConfiguration(
            behavior: _WebTouchScrollBehavior(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
            color: Color(0xFFFF4538),
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
              color: Color(0xFFFF4538),
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
                  controller: _counterController,
                ),
                color: const Color(0xFF00FF88),
              ),
              _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'МЕТАБОЛИЗМ',
                content: Text(
                  _userStrategy['metabolism'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: const Color(0xFFFF5252),
              ),
              _buildStatCard(
                icon: Icons.bar_chart,
                title: 'ОПЫТ',
                content: Text(
                  _userStrategy['experience'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: const Color(0xFF00D9FF),
              ),
              _buildStatCard(
                icon: Icons.flag,
                title: 'ДО ЦЕЛИ',
                content: Text(
                  '~${_userStrategy['weeks']} недель',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              const Color(0xFFFF4538).withOpacity(0.05),
              const Color(0xFFFF4538).withOpacity(0.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF4538).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFF4538),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
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
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF00FF88),
              size: 16,
            ),
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
      
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.03),
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
                  // Используем pushAndRemoveUntil, чтобы полностью очистить 
                  // историю переходов. Тогда HomeScreen станет корневым экраном, 
                  // и стрелка "Назад" автоматически исчезнет!
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false, 
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4538),
                  shadowColor: Color(0xFFFF4538),
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
      ..color = const Color(0xFFFF4538)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Координаты
    final startY = size.height * 0.8;
    final endY = size.height * 0.2;
    final width = size.width;

    final currentX = width * progress;
    final currentY = startY + (endY - startY) * progress;

    // Градиент под линией
    final fillPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, startY)
      ..quadraticBezierTo(
        currentX * 0.5,
        startY + (currentY - startY) * 0.5,
        currentX,
        currentY,
      )
      ..lineTo(currentX, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF4538).withOpacity(0.2),
          const Color(0xFFFF4538).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Линия
    canvas.drawLine(
      Offset(0, startY),
      Offset(currentX, currentY),
      paint,
    );

    // Точка старта
    if (progress > 0.0) {
      canvas.drawCircle(
        Offset(0, startY),
        4,
        Paint()..color = Colors.white,
      );
    }

    // Точка финиша
    if (progress >= 0.95) {
      final glowPaint = Paint()
        ..color = const Color(0xFF00FF88).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(width, endY), 12, glowPaint);

      canvas.drawCircle(
        Offset(width, endY),
        6,
        Paint()..color = const Color(0xFF00FF88),
      );

      final textSpan = TextSpan(
        text: '${endVal.toInt()} кг',
        style: const TextStyle(
          color: Color(0xFF00FF88),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(width - textPainter.width, endY - 25),
      );
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
