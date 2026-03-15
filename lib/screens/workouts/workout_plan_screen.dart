import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'package:startap/widgets/appnar.dart';
import '../../providers/workout_provider.dart';
import '../../models/activity_day.dart';
import '../ai_coach/chat_screen.dart';
import 'workout_session_screen.dart';

enum WorkoutSource { templates, ai }

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  WorkoutSource _source = WorkoutSource.templates;
  Map<DateTime, ActivityDay> _activityData = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isExercisesExpanded = false;

  List<Map<String, String>> _cachedExercises = [];
  String _cachedWorkoutName = '';

  @override
  void initState() {
    super.initState();
    _initializeActivityData();
    _loadOrFetchTodayWorkout();
  }

  // ================== РАБОТА С КЭШЕМ ТРЕНИРОВОК ==================

  Future<void> _loadOrFetchTodayWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final String todayKey = DateTime.now().toIso8601String().split('T')[0];

    // Читаем весь 30-дневный словарь, который был сохранен в TodayWorkoutCard
    final String? rawJson = prefs.getString('calendar_workouts');
    Map<String, dynamic> calendarCache = rawJson != null
        ? jsonDecode(rawJson) as Map<String, dynamic>
        : {};

    // Чистим старые записи (старше 30 дней)
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    calendarCache.removeWhere((dateStr, _) {
      final d = DateTime.tryParse(dateStr);
      return d == null || d.isBefore(cutoff);
    });

    // Если на сегодня есть тренировка в кэше — применяем её
    if (calendarCache.containsKey(todayKey)) {
      _applyCalendarEntry(calendarCache[todayKey]);
    } else {
      // Тренировки на сегодня нет (выходной или план не загружен)
      setState(() {
        _cachedWorkoutName = 'День отдыха';
        _cachedExercises = [];
      });
    }
  }

    void _applyCalendarEntry(dynamic entry) {
    if (entry == null || entry is! Map) return;
    
    setState(() {
      _cachedWorkoutName = entry['workout_name']?.toString() ?? 'Тренировка';
      
      _cachedExercises = [];
      if (entry['exercises'] != null && entry['exercises'] is List) {
        for (var ex in (entry['exercises'] as List)) {
          if (ex is Map) {
            _cachedExercises.add({
              'name': ex['name']?.toString() ?? 'Упражнение',
              'display': ex['display_string']?.toString() ?? '${ex['reps']} x ${ex['sets']}',
            });
          }
        }
      }
    });
  }


  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // ================== ИНИЦИАЛИЗАЦИЯ ДАННЫХ ДЛЯ КАЛЕНДАРЯ ==================

  Future<void> _initializeActivityData() async {
    _activityData.clear();

    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString('calendar_workouts');
    final today = _normalize(DateTime.now());

    // Если кэш абсолютно пустой (пользователь еще не дождался загрузки на главном экране)
    if (rawJson == null) {
      _generateEveryOtherDayPlan(today);
      setState(() {});
      return;
    }

    final Map<String, dynamic> calendarCache =
        jsonDecode(rawJson) as Map<String, dynamic>;

    // 1) Заполняем данные из реального плана от ИИ (из n8n)
        // 1) Заполняем данные из реального плана от ИИ (из n8n)
    for (final entry in calendarCache.entries) {
      final dateStr = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) continue;

      final n = _normalize(dt);
      final isPast = n.isBefore(today);

      // ПАРСИМ УПРАЖНЕНИЯ ДЛЯ ЭТОГО ДНЯ
       List<Map<String, String>> dayExercises = [];
      if (data['exercises'] != null && data['exercises'] is List) {
        for (var ex in (data['exercises'] as List)) {
          if (ex is Map) { // Проверяем, что элемент действительно Map
            dayExercises.add({
              'name': ex['name']?.toString() ?? 'Упражнение',
              'display': ex['display_string']?.toString() ?? '${ex['reps']} x ${ex['sets']}',
            });
          }
        }
      }

      _activityData[n] = ActivityDay(
        date: n,
        steps: isPast ? 8000 : 0,
        caloriesBurned: int.tryParse(data['calories']?.toString() ?? '400') ?? 400,
        activeMinutes: int.tryParse(data['duration_min']?.toString() ?? '45') ?? 45,
        distance: 4.0,
        isCompleted: isPast,
        skipped: false,
        workoutName: data['workout_name']?.toString() ?? 'Тренировка',
        exercises: dayExercises, // Передаем безопасно собранный список
      );
    }


    // 2) Если ИИ сгенерировал дырки (например, дни отдыха), мы их не заполняем заглушками.
    // Оставляем пустыми, чтобы сработал _buildEmptyDayCard()
    
    setState(() {});
  }

  

  void _generateEveryOtherDayPlan(DateTime today) {
    final workouts = [
      'Спина + Бицепс',
      'Ноги (квадрицепс + ягодицы)',
      'Грудь + Трицепс',
      'Плечи + Core',
    ];

    int idx = 0;
    for (int offset = -14; offset <= 14; offset += 2) {
      final d = _normalize(today.add(Duration(days: offset)));
      final isPast = d.isBefore(today);

      _activityData[d] = ActivityDay(
        date: d,
        steps: isPast ? 9000 : 0,
        caloriesBurned: 400,
        activeMinutes: 45,
        distance: 4.0,
        isCompleted: isPast,
        skipped: false,
        workoutName: workouts[idx % workouts.length],
      );
      idx++;
    }
  }

  void _fillEveryOtherDayAround(DateTime today) {
    final workouts = [
      'Спина + Бицепс',
      'Ноги (квадрицепс + ягодицы)',
      'Грудь + Трицепс',
      'Плечи + Core',
    ];

    final dates = _activityData.keys.toList()..sort();
    if (dates.isEmpty) {
      _generateEveryOtherDayPlan(today);
      return;
    }

    int baseIndex = dates.indexWhere((d) => d == today);
    if (baseIndex == -1) {
      dates.sort((a, b) => (a.difference(today).inDays).abs().compareTo(
            (b.difference(today).inDays).abs(),
          ));
      baseIndex = 0;
    }
    final baseDate = dates[baseIndex];
    final baseWorkout =
        _activityData[baseDate]?.workoutName ?? workouts[0];

    final existing = Set<DateTime>.from(_activityData.keys.map(_normalize));

    int patternIdx = workouts.indexOf(baseWorkout);
    if (patternIdx < 0) patternIdx = 0;

    for (int offset = -14; offset <= 14; offset += 2) {
      final d = _normalize(today.add(Duration(days: offset)));
      if (existing.contains(d)) continue;

      final isPast = d.isBefore(today);

      _activityData[d] = ActivityDay(
        date: d,
        steps: isPast ? 9000 : 0,
        caloriesBurned: 400,
        activeMinutes: 45,
        distance: 4.0,
        isCompleted: isPast,
        skipped: false,
        workoutName:
            workouts[(patternIdx + offset ~/ 2).abs() % workouts.length],
      );
    }
  }

  ActivityDay? _getActivityForDay(DateTime day) {
    final n = _normalize(day);
    return _activityData[n];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  // ================== BUILD ==================

  @override
  Widget build(BuildContext context) {
    final today = _normalize(DateTime.now());
    final selNorm = _normalize(_selectedDay);
    final isToday = selNorm == today;
    final activity = _getActivityForDay(selNorm);
    final hasWorkout =
        activity != null && activity.caloriesBurned > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          return CustomScrollView(
            slivers: [
              AppSectionHeader(title: 'Главная'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildCalendarCard(),
                      const SizedBox(height: 24),
                      if (hasWorkout)
                        _buildSelectedWorkoutCard(
                            activity!, isToday)
                      else
                        _buildEmptyDayCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================== UI Виджеты ==================

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
        calendarFormat: CalendarFormat.month,
        onDaySelected: _onDaySelected,
        onPageChanged: (fd) => setState(() => _focusedDay = fd),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left_rounded, color: Colors.white),
          rightChevronIcon:
              Icon(Icons.chevron_right_rounded, color: Colors.white),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              TextStyle(color: Colors.grey[400], fontSize: 11),
          weekendStyle:
              TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle:
              const TextStyle(color: Colors.white),
          weekendTextStyle:
              const TextStyle(color: Colors.white70),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFFFF4538),
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, _) {
            final a = _getActivityForDay(date);
            if (a == null || a.caloriesBurned <= 0) return null;

            final today = _normalize(DateTime.now());
            final n = _normalize(date);

            Color color;
            if (n.isBefore(today)) {
              color = a.skipped
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF51CF66);
            } else {
              color = const Color(0xFF51CF66);
            }

            return Positioned(
              top: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedWorkoutCard(ActivityDay activity, bool isToday) {
    String statusText = 'ЗАПЛАНИРОВАНО';
    Color statusColor = const Color(0xFF2C2C2E);
    IconData statusIcon = Icons.calendar_today_rounded;

    final today = _normalize(DateTime.now());
    final activityDate = _normalize(activity.date);

    if (activityDate.isBefore(today)) {
      if (activity.skipped) {
        statusText = 'ПРОПУЩЕНО';
        statusColor = const Color(0xFFFF6B6B);
        statusIcon = Icons.cancel_rounded;
      } else if (activity.isCompleted) {
        statusText = 'ВЫПОЛНЕНО';
        statusColor = const Color(0xFF51CF66);
        statusIcon = Icons.check_circle_rounded;
      }
    } else if (isToday) {
      statusText = 'СЕГОДНЯ';
      statusColor = const Color(0xFFFF4538); // Сделаем карточку "Сегодня" яркой
      statusIcon = Icons.local_fire_department_rounded;
    }

    // БЕРЕМ УПРАЖНЕНИЯ ИЗ ВЫБРАННОГО ДНЯ (activity), А НЕ ИЗ КЭША СЕГОДНЯ
    final exercisesList = activity.exercises.isNotEmpty
        ? activity.exercises.map((e) => '${e['name']} - ${e['display']}').toList()
        : <String>['Упражнения отсутствуют'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C2C2E),
            statusColor.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Хедер
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Icon(statusIcon,
                      color: statusColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.workoutName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Метрики
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactMetric(
                  Icons.access_time,
                  '${activity.activeMinutes} мин',
                ),
                _buildCompactMetric(
                  Icons.local_fire_department_rounded,
                  '${activity.caloriesBurned} ккал',
                ),
                Row(
                  children: [
                    ...List.generate(
                      3,
                      (i) => const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Средняя',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Список упражнений
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExercisesExpanded =
                      !_isExercisesExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.05),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'Список упражнений',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        Icon(
                          _isExercisesExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                     if (_isExercisesExpanded) ...[
                      const SizedBox(height: 12),
                      ...exercisesList.asMap().entries.map( // ИСПОЛЬЗУЕМ НОВУЮ ПЕРЕМЕННУЮ exercisesList
                        (e) {
                          final idx = e.key;
                          final ex = e.value;
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                                    bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration:
                                      BoxDecoration(
                                    color: statusColor
                                        .withOpacity(
                                            0.2),
                                    shape:
                                        BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        color:
                                            statusColor,
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: 10),
                                Expanded(
                                  child: Text(
                                    ex,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопки
            if (isToday) ...[
              ElevatedButton(
                 onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutSessionScreen(
                          title: activity.workoutName,
                          exercises: activity.exercises, // ПЕРЕДАЕМ УПРАЖНЕНИЯ ВЫБРАННОГО ДНЯ
                        ),
                      ),
                    );
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF4538),
                  foregroundColor:
                      const Color(0xFF0A0E21),
                  padding:
                      const EdgeInsets.symmetric(
                          vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  minimumSize:
                      const Size(double.infinity, 0),
                  elevation: 0,
                ),
                child: const Text(
                  'НАЧАТЬ ТРЕНИРОВКУ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChatScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Изменить план (AI)',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white
                        .withOpacity(0.3),
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                          vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  minimumSize:
                      const Size(double.infinity, 0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMetric(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDayCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.info_outline_rounded,
                color: Colors.orangeAccent, size: 32),
            SizedBox(height: 12),
            Text(
              'В этот день тренировка не запланирована',
              style:
                  TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Выбери другой день или создай тренировку',
              style: TextStyle(
                  color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
