import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/screens/workouts/WorkoutPlayerScreen.dart';
import 'package:startap/widgets/appnar.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/workout_provider.dart';
import '../../models/activity_day.dart';
import '../ai_coach/chat_screen.dart';

import 'package:startap/screens/workouts/workout_session_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeActivityData();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  void _initializeActivityData() {
    _activityData.clear();
    final today = _normalize(DateTime.now());

    // Вчера (выполнено)
    final yesterday = today.subtract(const Duration(days: 1));
    _activityData[yesterday] = ActivityDay(
      date: yesterday,
      steps: 11000,
      caloriesBurned: 500,
      activeMinutes: 50,
      distance: 6.2,
      isCompleted: true,
      workoutName: 'Ноги (квадрицепс + ягодицы)',
    );

    // Позавчера (пропущено)
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    _activityData[twoDaysAgo] = ActivityDay(
      date: twoDaysAgo,
      steps: 0,
      caloriesBurned: 0,
      activeMinutes: 0,
      distance: 0,
      isCompleted: false,
      workoutName: 'Спина + Бицепс',
      skipped: true,
    );

    // Сегодня
    _activityData[today] = ActivityDay(
      date: today,
      steps: 8500,
      caloriesBurned: 420,
      activeMinutes: 50,
      distance: 4.8,
      isCompleted: false,
      workoutName: 'Спина + Бицепс',
    );

    // Завтра
    final tomorrow = today.add(const Duration(days: 1));
    _activityData[tomorrow] = ActivityDay(
      date: tomorrow,
      steps: 8500,
      caloriesBurned: 420,
      activeMinutes: 50,
      distance: 4.8,
      isCompleted: false,
      workoutName: 'Ноги (квадрицепс + ягодицы)',
    );

    // Через 3 дня
    final inThreeDays = today.add(const Duration(days: 3));
    _activityData[inThreeDays] = ActivityDay(
      date: inThreeDays,
      steps: 0,
      caloriesBurned: 350,
      activeMinutes: 45,
      distance: 0,
      isCompleted: false,
      workoutName: 'Грудь + Трицепс',
    );
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
  

  @override
  Widget build(BuildContext context) {
    final today = _normalize(DateTime.now());
    final selNorm = _normalize(_selectedDay);
    final isToday = selNorm == today;
    final activity = _getActivityForDay(selNorm);
    final hasWorkout = activity != null && activity.caloriesBurned > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          return CustomScrollView(
            slivers: [
              Appnar.buildModernAppBar(context, 'Тренировки'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ИСТОЧНИК
                      _buildSourceToggle(),
                      const SizedBox(height: 24),

                      // КАЛЕНДАРЬ
                      _buildCalendarCard(),
                      const SizedBox(height: 24),

                      // КАРТОЧКА ВЫБРАННОГО ДНЯ
                      if (hasWorkout)
                        _buildSelectedWorkoutCard(activity!, isToday)
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

  Widget _buildSourceToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sourceChip(
              label: 'Шаблоны',
              value: WorkoutSource.templates,
              icon: Icons.view_module_rounded,
            ),
            const SizedBox(width: 6),
            _sourceChip(
              label: 'Тренировки ИИ',
              value: WorkoutSource.ai,
              icon: Icons.psychology_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceChip({
    required String label,
    required WorkoutSource value,
    required IconData icon,
  }) {
    final isSelected = _source == value;
    return GestureDetector(
      onTap: () => setState(() => _source = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)])
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Календарь тренировок',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E21),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TableCalendar(
              // Начало календаря (например, с прошлого года)
              firstDay: DateTime.utc(2024, 1, 1),
              
              // ИСПРАВЛЕНИЕ: Ставим дату далеко в будущем (2030 год)
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
                leftChevronIcon: Icon(Icons.chevron_left_rounded,
                    color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right_rounded,
                    color: Colors.white),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 11),
                weekendStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(color: Colors.white),
                weekendTextStyle: const TextStyle(color: Colors.white70),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF6C5CE7),
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
          ),
        ],
      ),
    );
  }


      Widget _buildSelectedWorkoutCard(ActivityDay activity, bool isToday) {
    // Определяем статус
    String statusText = 'ЗАПЛАНИРОВАНО';
    Color statusColor = const Color(0xFF00E5FF);
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
    }

    // Список упражнений (захардкожено, потом можно в ActivityDay добавить)
    final exercises = [
      'Приседание со штангой - 4x10',
      'Жим ногами - 3x12',
      'Разгибание ног - 3x15',
      'Выпады с гантелями - 3x12',
      'Подъем на икры - 4x15',
      'Пресс: скручивания - 3x20',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF101322), 
            statusColor.withOpacity(0.12)
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Хедер
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactMetric(Icons.access_time, '${activity.activeMinutes} мин'),
                _buildCompactMetric(Icons.local_fire_department_rounded, '${activity.caloriesBurned} ккал'),
                Row(
                  children: [
                    ...List.generate(3, (i) => const Icon(Icons.star_rounded, size: 14, color: Colors.amberAccent)),
                    const SizedBox(width: 4),
                    const Text('Средняя', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // AI ИНСАЙТ (для сегодняшнего дня или прошедших)
            if (isToday) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: Color(0xFF00E5FF), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Ты утром поел овсянку? Отлично! Сегодня я подобрал упражнения с фокусом на выносливость.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (activity.isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF51CF66).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFF51CF66), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Отличная работа! Ты выполнил все упражнения на 100%. Прогресс к цели: +1.2%',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (activity.skipped) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFF6B6B), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Ничего страшного! Я скорректировал план на неделю. Сегодня восстановись.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // СПИСОК УПРАЖНЕНИЙ (раскрывающийся)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExercisesExpanded = !_isExercisesExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Список упражнений',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          _isExercisesExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    if (_isExercisesExpanded) ...[
                      const SizedBox(height: 12),
                      ...exercises.asMap().entries.map((e) {
                        final idx = e.key;
                        final ex = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${idx + 1}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ex,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Статистика для прошедших
            if (activity.isCompleted) ...[
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   _buildStatColumn('Шаги', '${activity.steps}', Colors.blueAccent),
                   _buildStatColumn('Дистанция', '${activity.distance} км', Colors.greenAccent),
                   _buildStatColumn('Сделано', '6/6', Colors.purpleAccent),
                 ],
               ),
               const SizedBox(height: 16),
            ],

            // КНОПКИ
            if (isToday) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  WorkoutSessionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0A0E21),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 0),
                  elevation: 0,
                ),
                child: const Text('НАЧАТЬ ТРЕНИРОВКУ', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Изменить план (AI)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            ] else if (activityDate.isAfter(today)) ...[
              // Для будущих дней просто инфо
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF00E5FF), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Тренировка запланирована на этот день.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (activity.skipped) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Color(0xFFFF6B6B), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Тренировка была пропущена.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Вспомогательные виджеты
  Widget _buildCompactMetric(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _buildMiniStats(ActivityDay activity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniStat('Время', '${activity.activeMinutes} мин',
            Icons.timer_rounded),
        _miniStat(
            'Калории', '${activity.caloriesBurned} ккал',
            Icons.local_fire_department_rounded),
        _miniStat('Дистанция', '${activity.distance.toStringAsFixed(1)} км',
            Icons.route_rounded),
      ],
    );
  }

  Widget _miniStat(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                )),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
