import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:startap/widgets/appnar.dart';
import 'package:table_calendar/table_calendar.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({Key? key}) : super(key: key);

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  DayAnalytics _getDayAnalytics(DateTime day) {
    final random = Random(day.day + day.month * 100);
    final isPast = day.isBefore(_normalize(DateTime.now()));

    if (!isPast) {
      return DayAnalytics(
        date: day,
        progressToGoal: 0,
        message: 'Анализ будет доступен после завершения дня',
        isAvailable: false,
        workoutStatus: 'Запланирована',
        workoutName: 'Ноги (квадрицепс + ягодицы)',
        workoutDuration: 50,
        workoutCalories: 420,
        workoutInsight: 'Эта сессия сожжет 420 ккал и приблизит к цели на 1.1%',
        sleepHours: 0,
        sleepGoal: 8,
        sleepInsight: 'Анализ будет доступен после завершения дня',
        caloriesIntake: 0,
        caloriesGoal: 2500,
        caloriesInsight: 'Анализ будет доступен после завершения дня',
        muscleGroupsWorked: [],
      );
    }

    final isGoodDay = random.nextBool();
    final progressToGoal = (0.5 + random.nextDouble() * 2).toStringAsFixed(1);

    return DayAnalytics(
      date: day,
      progressToGoal: double.parse(progressToGoal),
      message: isGoodDay
          ? 'Отличный день! Ты хорошо выспался, выложился на тренировке и выполнил план по питанию. Это дало мощный импульс к твоей цели. Так держать!'
          : 'Не лучший день, но это не страшно. Вижу, ты пропустил тренировку из-за плохого сна. Я уже адаптировал план на следующие дни, чтобы мы быстро наверстали упущенное!',
      isAvailable: true,
      workoutStatus: random.nextBool() ? 'Выполнена' : 'Пропущена',
      workoutName: 'Ноги (квадрицепс + ягодицы)',
      workoutDuration: 45 + random.nextInt(15),
      workoutCalories: 380 + random.nextInt(100),
      workoutInsight: 'Отличная техника выполнения. Не забудь растяжку после тренировки.',
      sleepHours: 5 + random.nextInt(4),
      sleepGoal: 8,
      sleepInsight: random.nextBool()
          ? 'Хороший сон! Твоё восстановление в норме.'
          : 'Критически мало сна! Тренировка будет облегчена, чтобы избежать травмы.',
      caloriesIntake: 2000 + random.nextInt(1000),
      caloriesGoal: 2500,
      caloriesInsight: random.nextBool()
          ? 'Отличный профицит для набора массы. Баланс БЖУ в норме.'
          : 'Лёгкий дефицит. Это хорошо для сушки, но следи за белком.',
      muscleGroupsWorked: ['Квадрицепс', 'Ягодицы', 'Икры'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: CustomScrollView(
        slivers: [
          Appnar.buildModernAppBar(context, "Статистика"),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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
                      Text(
                        'Отслеживай прогресс каждый день',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
    );
  }

  Widget _buildCalendar() {
    final today = _normalize(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (d) => _selectedDay != null && isSameDay(_selectedDay, d),
        calendarFormat: CalendarFormat.month,
        onDaySelected: (selectedDay, focusedDay) {
          final selNorm = _normalize(selectedDay);
          final isPassedOrToday = !selNorm.isAfter(today);

          if (isPassedOrToday) {
            setState(() {
              if (_selectedDay != null && isSameDay(_selectedDay, selectedDay)) {
                _selectedDay = null;
              } else {
                _selectedDay = selectedDay;
              }
              _focusedDay = focusedDay;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Анализ будет доступен после завершения дня'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF6C5CE7),
              ),
            );
          }
        },
        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
        headerStyle: HeaderStyle(
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF5A4CD6)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 12,
              ),
            ],
          ),
          selectedDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withOpacity(0.4),
                blurRadius: 16,
              ),
            ],
          ),
          defaultTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 15,
          ),
          disabledTextStyle: TextStyle(color: Colors.grey[700]),
          outsideTextStyle: TextStyle(color: Colors.grey[800]),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          weekdayStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final isPast = day.isBefore(today);
            return _buildDayCell(day, isPast);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, false, isToday: true);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, false, isOutside: true);
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isPast, {bool isToday = false, bool isOutside = false}) {
    final random = Random(day.day + day.month * 100);

    if (isOutside) {
      return const SizedBox();
    }

    if (!isPast) {
      return Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isToday ? Colors.white : Colors.grey[600],
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(44, 44),
          painter: TripleRingsPainter(
            caloriesProgress: 0.5 + random.nextDouble() * 0.5,
            sleepProgress: 0.4 + random.nextDouble() * 0.6,
            workoutProgress: random.nextDouble(),
          ),
        ),
        Text(
          '${day.day}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
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
      builder: (_, val, child) {
        return Opacity(opacity: val, child: child);
      },
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [const Color(0xFF51CF66), const Color(0xFF37B24D)]
              : [const Color(0xFFFF922B), const Color(0xFFF59F00)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? const Color(0xFF51CF66) : const Color(0xFFFF922B))
                .withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ПРОГРЕСС К ЦЕЛИ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${isPositive ? '↑' : '↓'} ${analytics.progressToGoal.abs()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              analytics.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isCompleted ? Colors.purpleAccent : Colors.orangeAccent)
              .withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                  gradient: LinearGradient(
                    colors: [
                      (isCompleted ? Colors.purpleAccent : Colors.orangeAccent)
                          .withOpacity(0.2),
                      (isCompleted ? Colors.purpleAccent : Colors.orangeAccent)
                          .withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isCompleted ? Colors.purpleAccent : Colors.orangeAccent)
                        .withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: isCompleted ? Colors.purpleAccent : Colors.orangeAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🏋️ ТРЕНИРОВКА',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${analytics.workoutName} • ${analytics.workoutDuration} мин',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: Colors.deepOrange, size: 16),
              const SizedBox(width: 6),
              Text(
                '${analytics.workoutCalories} ккал',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              const Text(
                'AI-Инсайт:',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analytics.workoutInsight,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.2),
          width: 1.5,
        ),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.2),
                      Colors.purpleAccent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.nightlight_rounded,
                  color: Colors.purpleAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  '🌙 СОН',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
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
                    fontWeight: FontWeight.w700,
                  ),
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
                    '${analytics.sleepHours}ч / ${analytics.sleepGoal}ч',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$percent% от нормы',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              const Text(
                'AI-Предупреждение:',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analytics.sleepInsight,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(DayAnalytics analytics) {
    final percent = (analytics.caloriesIntake / analytics.caloriesGoal * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.2),
          width: 1.5,
        ),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.orangeAccent.withOpacity(0.2),
                      Colors.orangeAccent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orangeAccent.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.orangeAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  '🍽️ ПИТАНИЕ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
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
                    fontWeight: FontWeight.w700,
                  ),
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
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ккал',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              const Text(
                'AI-Совет:',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analytics.caloriesInsight,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.2),
          width: 1.5,
        ),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.2),
                      Colors.greenAccent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.greenAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '💪 ГРУППЫ МЫШЦ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
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
                  gradient: isWorked
                      ? LinearGradient(
                          colors: [
                            Colors.greenAccent.withOpacity(0.2),
                            Colors.greenAccent.withOpacity(0.08),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.06),
                            Colors.white.withOpacity(0.02),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWorked ? Colors.greenAccent.withOpacity(0.4) : Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                  boxShadow: isWorked
                      ? [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.15),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  group,
                  style: TextStyle(
                    color: isWorked ? Colors.greenAccent : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: isWorked ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
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

    _drawRing(canvas, center, 18, caloriesProgress, const Color(0xFFFF6B6B));
    _drawRing(canvas, center, 13, sleepProgress, const Color(0xFF6C5CE7));
    _drawRing(canvas, center, 8, workoutProgress, const Color(0xFF51CF66));
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double progress, Color color) {
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(TripleRingsPainter oldDelegate) {
    return oldDelegate.caloriesProgress != caloriesProgress ||
        oldDelegate.sleepProgress != sleepProgress ||
        oldDelegate.workoutProgress != workoutProgress;
  }
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
