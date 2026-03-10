import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:startap/models/stat_response.dart';
import 'package:startap/services/stat_service.dart';
import 'package:startap/widgets/appnar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({Key? key}) : super(key: key);

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  late String _userEmail;
  StatResponse? _stats;
  bool _statsLoading = true;
  final Map<String, StatResponse> _dayStatsCache = {};
  final Map<String, Map<String, int>> _dailyActivityCache = {}; 
  @override
  void initState() {
    super.initState();
    final today = _normalize(DateTime.now());
    _selectedDay = today;
    
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
    
    await _loadStats();
    await _loadDayStats(_selectedDay!); 
    await _loadDailyActivity(_selectedDay!); // ДОБАВЛЕНО
  }

  Future<void> _loadStats() async {
    // ВАЖНО: Тут мы вызываем запрос за МЕСЯЦ.
    // Если ваш сервис теперь не принимает email, уберите _userEmail из скобок.
    // Я оставлю так, как было изначально.
    final stats = await StatService.fetchMonthStats(_userEmail);
    if (mounted) {
      setState(() {
        _stats = stats;
        _statsLoading = false;
      });
    }
  }
    Future<void> _loadDailyActivity(DateTime day) async {
    final key = day.toIso8601String().split('T')[0];
    final isToday = isSameDay(day, DateTime.now());

    if (!isToday && _dailyActivityCache.containsKey(key)) return;

    try {
      final url = Uri.parse('https://n8n.nexusfit.ru/webhook/day-stats?email=$_userEmail&date=$key');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            setState(() {
              _dailyActivityCache[key] = {
                'active_minutes': data['active_minutes'] ?? 0,
                'active_calories': data['active_calories'] ?? 0,
                'workouts_completed': data['workouts']?['completed'] ?? 0,
                'workouts_total': data['workouts']?['total'] ?? 0,
              };
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки активности: $e');
    }
  }

  Future<void> _loadDayStats(DateTime day) async {
    final key = day.toIso8601String().split('T')[0];
    
    // Проверяем, является ли выбранный день сегодняшним
    final isToday = isSameDay(day, DateTime.now());
    
    // Если это не сегодняшний день и он уже есть в кэше — используем кэш
    if (!isToday && _dayStatsCache.containsKey(key)) {
      return;
    }
    
    // Для сегодняшнего дня (или новых дней) всегда скачиваем свежие данные
    final stats = await StatService.fetchDayStats(_userEmail, day);
    if (stats != null && mounted) {
      setState(() => _dayStatsCache[key] = stats);
    }
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  DayAnalytics _getDayAnalytics(DateTime day) {
    final isPast = day.isBefore(_normalize(DateTime.now()));
    final isToday = isSameDay(day, _normalize(DateTime.now()));
    final key = day.toIso8601String().split('T')[0];
    final dayStats = _dayStatsCache[key];

    if (!isPast && !isToday) {
      return DayAnalytics(
        date: day,
        progressToGoal: 0,
        message: 'Анализ будет доступен после завершения дня',
        isAvailable: false,
        workoutStatus: 'Запланирована',
        workoutName: 'Тренировка запланирована',
        workoutDuration: 0,
        workoutCalories: 0,
        workoutInsight: 'Анализ будет доступен после завершения дня',
        sleepHours: 0,
        sleepGoal: 8,
        sleepInsight: 'Анализ будет доступен после завершения дня',
        caloriesIntake: 0,
        caloriesGoal: 2500,
        caloriesInsight: 'Анализ будет доступен после завершения дня',
        muscleGroupsWorked: [],
      );
    }

    if (dayStats == null) {
      return DayAnalytics(
        date: day,
        progressToGoal: 0,
        message: 'Загрузка данных...',
        isAvailable: false,
        workoutStatus: 'Нет данных',
        workoutName: 'Нет данных',
        workoutDuration: 0,
        workoutCalories: 0,
        workoutInsight: 'Данные загружаются',
        sleepHours: 0,
        sleepGoal: 8,
        sleepInsight: 'Данные загружаются',
        caloriesIntake: 0,
        caloriesGoal: 2500,
        caloriesInsight: 'Данные загружаются',
        muscleGroupsWorked: [],
      );
    }

        final activityStats = _dailyActivityCache[key];

    final sleepHours = dayStats.sleepAvgHours.toInt();
    final calories = dayStats.totalCalories;
    
    // БЕРЕМ ДАННЫЕ ИЗ НОВОГО КЭША АКТИВНОСТИ (или ставим нули, если еще не загрузилось)
    final workoutsCompleted = activityStats?['workouts_completed'] ?? dayStats.workoutsCompleted;
    final workoutsTotal = activityStats?['workouts_total'] ?? dayStats.workoutsTotal;
    final workoutDuration = activityStats?['active_minutes'] ?? dayStats.workoutsAvgDuration.toInt();
    final workoutCalories = activityStats?['active_calories'] ?? (dayStats.workoutsTotalMinutes * 7);


    return DayAnalytics(
      date: day,
      progressToGoal: 1.2,
      message: sleepHours >= 7 && calories > 0
          ? 'Отличный день! Показатели в норме.'
          : 'Вижу дефицит по показателям. Адаптирую план.',
      isAvailable: true,
      workoutStatus: workoutsCompleted > 0 ? 'Выполнена' : 'Пропущена',
      workoutName: 'Тренировка',
      workoutDuration: workoutDuration,
      workoutCalories: workoutCalories,
      workoutInsight: 'Выполнено: $workoutsCompleted из $workoutsTotal тренировок.',
      sleepHours: sleepHours,
      sleepGoal: 8,
      sleepInsight: sleepHours >= 7
          ? 'Хороший сон! ${sleepHours}ч — норма.'
          : 'Мало сна. ${sleepHours}ч — ниже нормы.',
      caloriesIntake: calories,
      caloriesGoal: 2500,
      caloriesInsight: 'За день: $calories ккал. Приёмов пищи: ${dayStats.totalMeals}.',
      muscleGroupsWorked: workoutsCompleted > 0
          ? ['Квадрицепс', 'Ягодицы', 'Икры']
          : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: ScrollConfiguration(
        behavior: _WebTouchScrollBehavior(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          Appnar.buildModernAppBar(context, "Статистика"),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Календарь активности',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Отслеживай прогресс каждый день',
                    style: TextStyle(color: Color(0xFFAEAEB2), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  if (_statsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(color: Color(0xFFFF4538)),
                      ),
                    )
                  else if (_stats != null)
                    _buildStatsOverview(_stats!),
                  const SizedBox(height: 20),
                  _buildCalendar(),
                  const SizedBox(height: 32),
                  if (_selectedDay != null) _buildDailyRewind(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatsOverview(StatResponse stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика за месяц',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statTile(Icons.local_fire_department_rounded,
                  '${stats.totalCalories}', 'ккал', const Color(0xFFFF4538)),
              _statTile(Icons.water_drop_rounded,
                  '${stats.totalWaterLiters.toStringAsFixed(1)}л', 'вода',
                  Colors.blueAccent),
              _statTile(Icons.nightlight_rounded,
                  '${stats.sleepAvgHours.toStringAsFixed(1)}ч', 'сон avg',
                  Colors.purpleAccent),
              _statTile(Icons.fitness_center_rounded,
                  '${stats.workoutsCompleted}', 'трен.',
                  Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFAEAEB2), fontSize: 11)),
        ],
      ),
    );
  }

    Widget _buildCalendar() {
    final today = _normalize(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        children: [
          TableCalendar(
            // ДОБАВЬТЕ ЭТУ СТРОКУ СЮДА:
            availableGestures: AvailableGestures.horizontalSwipe, 
            
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) =>
                _selectedDay != null && isSameDay(_selectedDay, d),
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Неделя',
              CalendarFormat.month: 'Месяц',
            },
            onDaySelected: (selectedDay, focusedDay) async {
// ... остальной код без изменений

              final selNorm = _normalize(selectedDay);
              final isPassedOrToday = !selNorm.isAfter(today);
              
              if (isPassedOrToday) {
                if (_selectedDay != null && isSameDay(_selectedDay, selectedDay)) {
                  if (mounted) {
                    setState(() {
                      _selectedDay = null;
                      _focusedDay = focusedDay;
                    });
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                  // Грузим всё параллельно
                  await Future.wait([
                    _loadDayStats(selectedDay),
                    _loadDailyActivity(selectedDay), // ДОБАВЛЕНО
                  ]);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Анализ будет доступен после завершения дня'),
    duration: Duration(seconds: 2),
    backgroundColor: Color(0xFFFF4538),
  ),
);

              }
            },

            onPageChanged: (fd) => mounted ? setState(() => _focusedDay = fd) : null,
            headerStyle: HeaderStyle(
              titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left_rounded,
                  color: Colors.white.withOpacity(0.7), size: 24),
              rightChevronIcon: Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.7), size: 24),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFFFF4538).withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFFF4538),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              weekendTextStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 15),
              disabledTextStyle: TextStyle(color: Colors.grey[700]),
              outsideTextStyle: TextStyle(color: Colors.grey[800]),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
              weekdayStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final isPast = day.isBefore(today);
                return _buildDayCell(day, isPast);
              },
              todayBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, false, isToday: true),
              outsideBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, false, isOutside: true),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => mounted ? setState(() {
              _calendarFormat = _calendarFormat == CalendarFormat.week
                  ? CalendarFormat.month
                  : CalendarFormat.week;
            }) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _calendarFormat == CalendarFormat.week
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isPast,
      {bool isToday = false, bool isOutside = false}) {
    if (isOutside) return const SizedBox();

    if (!isPast && !isToday) {
      return Center(
        child: Text('${day.day}',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      );
    }

    final key = day.toIso8601String().split('T')[0];
    final dayStats = _dayStatsCache[key];

    final caloriesGoal = 2500.0;
    final sleepGoal = 8.0;

    final caloriesProgress = dayStats != null
        ? (dayStats.totalCalories / caloriesGoal).clamp(0.0, 1.0)
        : (_stats != null
            ? ((_stats!.totalCalories / 30) / caloriesGoal).clamp(0.0, 1.0)
            : 0.0);
    final sleepProgress = dayStats != null
        ? (dayStats.sleepAvgHours / sleepGoal).clamp(0.0, 1.0)
        : (_stats != null
            ? (_stats!.sleepAvgHours / sleepGoal).clamp(0.0, 1.0)
            : 0.0);
    final workoutProgress = dayStats != null
        ? (dayStats.workoutsCompleted > 0 ? 1.0 : 0.0)
        : (_stats != null && _stats!.workoutsTotal > 0
            ? (_stats!.workoutsCompleted / _stats!.workoutsTotal)
                .clamp(0.0, 1.0)
            : 0.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(44, 44),
          painter: TripleRingsPainter(
            caloriesProgress: caloriesProgress,
            sleepProgress: sleepProgress,
            workoutProgress: workoutProgress,
          ),
        ),
        Text('${day.day}',
            style: TextStyle(
                color: isToday ? const Color(0xFFFF4538) : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildDailyRewind() {
    if (_selectedDay == null) return const SizedBox.shrink();
    final analytics = _getDayAnalytics(_selectedDay!);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Opacity(opacity: val, child: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalImpactCard(analytics),
          const SizedBox(height: 18),
          _buildWorkoutCard(analytics),
          const SizedBox(height: 18),
          _buildSleepCard(analytics),
          const SizedBox(height: 18),
          _buildNutritionCard(analytics),
          const SizedBox(height: 18),
          if (analytics.muscleGroupsWorked.isNotEmpty) ...[
            _buildMuscleHeatmap(analytics),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalImpactCard(DayAnalytics analytics) {
    final monthNames = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    final dateStr =
        '${analytics.date.day.toString().padLeft(2, '0')} ${monthNames[analytics.date.month - 1].toUpperCase()}';
    final isPositive = analytics.progressToGoal > 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr,
              style: const TextStyle(
                  color: Color(0xFFAEAEB2),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4538).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: const Color(0xFFFF4538),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ПРОГРЕСС К ЦЕЛИ',
                        style: TextStyle(
                            color: Color(0xFFAEAEB2),
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      analytics.isAvailable
                          ? '${isPositive ? '↑' : '↓'} ${analytics.progressToGoal.abs()}%'
                          : '—',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFF4538).withOpacity(0.2)),
            ),
            child: Text(analytics.message,
                style: const TextStyle(
                    color: Color(0xFFAEAEB2), fontSize: 13, height: 1.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(DayAnalytics analytics) {
    final isCompleted = analytics.workoutStatus == 'Выполнена';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4538).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF4538).withOpacity(0.3)),
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    color: Color(0xFFFF4538), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('ТРЕНИРОВКА',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isCompleted ? Colors.greenAccent : Colors.orangeAccent)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  analytics.workoutStatus,
                  style: TextStyle(
                      color: isCompleted ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('${analytics.workoutName} • ${analytics.workoutDuration} мин',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: Color(0xFFFF4538), size: 16),
              const SizedBox(width: 6),
              Text('${analytics.workoutCalories} ккал',
                  style: const TextStyle(
                      color: Color(0xFFFF4538),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.psychology_rounded,
                  color: Color(0xFFFF4538), size: 16),
              SizedBox(width: 8),
              Text('AI-Инсайт:',
                  style: TextStyle(
                      color: Color(0xFFFF4538),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(analytics.workoutInsight,
              style: const TextStyle(
                  color: Color(0xFFAEAEB2), fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSleepCard(DayAnalytics analytics) {
    final percent = (analytics.sleepHours / analytics.sleepGoal * 100).toInt();
    final isSufficient = percent >= 75;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.nightlight_rounded,
                    color: Colors.purpleAccent, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('СОН',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isSufficient ? Colors.greenAccent : Colors.orangeAccent)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isSufficient ? 'Норма' : 'Дефицит',
                  style: TextStyle(
                      color: isSufficient ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${analytics.sleepHours}ч / ${analytics.sleepGoal}ч',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('$percent% от нормы',
                      style: const TextStyle(
                          color: Color(0xFFAEAEB2), fontSize: 11)),
                ],
              ),
              Text('$percent%',
                  style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (analytics.sleepHours / analytics.sleepGoal).clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.psychology_rounded,
                  color: Color(0xFFFF4538), size: 16),
              SizedBox(width: 8),
              Text('AI-Предупреждение:',
                  style: TextStyle(
                      color: Color(0xFFFF4538),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(analytics.sleepInsight,
              style: const TextStyle(
                  color: Color(0xFFAEAEB2), fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(DayAnalytics analytics) {
    final percent = analytics.caloriesGoal > 0
        ? (analytics.caloriesIntake / analytics.caloriesGoal * 100).toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.restaurant_rounded,
                    color: Colors.orangeAccent, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('ПИТАНИЕ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  percent > 110 ? 'Профицит' : percent < 90 ? 'Дефицит' : 'Норма',
                  style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${analytics.caloriesIntake} / ${analytics.caloriesGoal}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  const Text('ккал',
                      style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Text('$percent%',
                  style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (analytics.caloriesIntake / analytics.caloriesGoal).clamp(0, 1.5),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.psychology_rounded,
                  color: Color(0xFFFF4538), size: 16),
              SizedBox(width: 8),
              Text('AI-Совет:',
                  style: TextStyle(
                      color: Color(0xFFFF4538),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(analytics.caloriesInsight,
              style: const TextStyle(
                  color: Color(0xFFAEAEB2), fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildMuscleHeatmap(DayAnalytics analytics) {
    const muscleGroups = [
      'Грудь', 'Спина', 'Плечи', 'Бицепс', 'Трицепс', 'Предплечья',
      'Пресс', 'Квадрицепс', 'Бицепс бедра', 'Ягодицы', 'Икры', 'Трапеции'
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.health_and_safety_rounded,
                    color: Colors.greenAccent, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('💪 ГРУППЫ МЫШЦ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: muscleGroups.map((group) {
              final isWorked = analytics.muscleGroupsWorked.contains(group);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isWorked
                      ? Colors.greenAccent.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWorked
                        ? Colors.greenAccent.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
                child: Text(group,
                    style: TextStyle(
                        color: isWorked ? Colors.greenAccent : const Color(0xFFAEAEB2),
                        fontSize: 12,
                        fontWeight: isWorked ? FontWeight.w700 : FontWeight.w500)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============ PAINTER ============
class TripleRingsPainter extends CustomPainter {
  final double caloriesProgress;
  final double sleepProgress;
  final double workoutProgress;

  TripleRingsPainter({
    required this.caloriesProgress,
    required this.sleepProgress,
    required this.workoutProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _drawRing(canvas, center, 18, caloriesProgress, const Color(0xFFFF4538));
    _drawRing(canvas, center, 13, sleepProgress, Colors.purpleAccent);
    _drawRing(canvas, center, 8, workoutProgress, const Color(0xFF51CF66));
  }

  void _drawRing(Canvas canvas, Offset center, double radius,
      double progress, Color color) {
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(TripleRingsPainter old) =>
      old.caloriesProgress != caloriesProgress ||
      old.sleepProgress != sleepProgress ||
      old.workoutProgress != workoutProgress;
}

// ============ MODEL ============
class DayAnalytics {
  final DateTime date;
  final double progressToGoal;
  final String message;
  final bool isAvailable;
  final String workoutStatus;
  final String workoutName;
  final int workoutDuration;
  final int workoutCalories;
  final String workoutInsight;
  final int sleepHours;
  final int sleepGoal;
  final String sleepInsight;
  final int caloriesIntake;
  final int caloriesGoal;
  final String caloriesInsight;
  final List<String> muscleGroupsWorked;

  DayAnalytics({
    required this.date,
    required this.progressToGoal,
    required this.message,
    required this.isAvailable,
    required this.workoutStatus,
    required this.workoutName,
    required this.workoutDuration,
    required this.workoutCalories,
    required this.workoutInsight,
    required this.sleepHours,
    required this.sleepGoal,
    required this.sleepInsight,
    required this.caloriesIntake,
    required this.caloriesGoal,
    required this.caloriesInsight,
    required this.muscleGroupsWorked,
  });
}
