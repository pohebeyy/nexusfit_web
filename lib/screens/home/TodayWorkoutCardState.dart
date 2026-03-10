import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:startap/screens/home/adaptiom_sheet.dart';
import 'package:startap/screens/workouts/workout_plan_screen.dart';
import 'package:startap/services/api/StringApi.dart';

class TodayWorkoutCard extends StatefulWidget {
  // Добавляем поле для хранения переданной даты
  final DateTime selectedDate;

  // Обновляем конструктор: делаем selectedDate обязательным параметром (required)
  const TodayWorkoutCard({
    Key? key, 
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<TodayWorkoutCard> createState() => TodayWorkoutCardState();
}

class TodayWorkoutCardState extends State<TodayWorkoutCard> {
  bool _isExpanded = false;
  bool _isLoading = true;

  // Динамические переменные
  String _workoutName = 'Загрузка...';
  String _difficulty = 'medium';
  int _calories = 0;
  int _durationMinutes = 0;
  List<Map<String, String>> _exercises = [];

   @override
  void initState() {
    super.initState();
    loadWorkoutPlan(); 
  }

  // ОБЯЗАТЕЛЬНО добавляем метод для реагирования на смену даты кликом в календаре:
  @override
  void didUpdateWidget(TodayWorkoutCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      loadWorkoutPlan();
    }
  }

  Future<void> loadWorkoutPlan() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    // БЕРЕМ ИМЕННО ВЫБРАННУЮ ДАТУ
    final String targetDate = widget.selectedDate.toIso8601String().split('T')[0];
    final String? rawCalendar = prefs.getString('calendar_workouts');
    
    bool needsFetch = true;

    if (rawCalendar != null) {
      try {
        final Map<String, dynamic> calendarCache = jsonDecode(rawCalendar);
        
        // Проверка: кэш не устарел?
        DateTime? maxDate;
        for (String key in calendarCache.keys) {
          final d = DateTime.tryParse(key);
          if (d != null) {
            if (maxDate == null || d.isAfter(maxDate)) maxDate = d;
          }
        }
        
        final todayDt = DateTime.now();
        final todayStart = DateTime(todayDt.year, todayDt.month, todayDt.day);
        
        // Если в кэше есть данные на сегодня и будущее — он валидный
        if (maxDate != null && !maxDate.isBefore(todayStart)) {
          needsFetch = false; 
        }

        // Пытаемся вытянуть тренировку именно на выбранную дату (targetDate)
        if (calendarCache.containsKey(targetDate)) {
          _parseJsonAndSetState(calendarCache[targetDate]);
        } else {
          // Выходной или пустой день
          _setRestDay();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    if (needsFetch) {
      // Идет запрос в сеть только если кэша нет (он даст план на 30 дней)
      await _fetchFromNetwork(prefs, targetDate); 
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Вспомогательный метод для дня отдыха
  void _setRestDay() {
    setState(() {
      _workoutName = 'День отдыха';
      _difficulty = 'easy';
      _calories = 0;
      _durationMinutes = 0;
      _exercises = [];
      _isLoading = false;
    });
  }

  // Загрузка по сети (n8n)
  Future<void> _fetchFromNetwork(SharedPreferences prefs, String todayDate) async {
    try {
      final String userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';
      debugPrint('Запрос тренировки (main) для почты: $userEmail');

      final response = await http.post(
        Uri.parse(StringApi.apiUrl), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          
          // 1. Сохраняем весь календарь на месяц
          if (data['month_calendar'] != null) {
            final monthCalendar = data['month_calendar'];
            await prefs.setString('calendar_workouts', jsonEncode(monthCalendar));
            
            // 2. Пытаемся достать сегодняшнюю тренировку прямо из сгенерированного плана
            // (или берем today_workout от n8n, если он передается отдельно)
            final todayWorkout = monthCalendar[todayDate] ?? data['today_workout'];
            
            if (todayWorkout != null) {
              _parseJsonAndSetState(todayWorkout);
            } else {
              _setRestDay(); // Если ИИ сгенерировал первый день как выходной
            }
          } else {
            _setRestDay();
          }
          
        } else {
          setState(() => _isLoading = false);
          debugPrint('Ошибка сервера: ${data['error']}');
        }
      } else {
        setState(() => _isLoading = false);
        debugPrint('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Ошибка сети: $e');
    }
  }


  // Парсинг JSON в стейт виджета
  bool _parseJsonAndSetState(dynamic workoutData) {
    try {
      setState(() {
        _workoutName = workoutData['workout_name'] ?? 'Тренировка на сегодня';
        _difficulty  = workoutData['difficulty']    ?? 'medium';
        
        _calories = int.tryParse(workoutData['calories']?.toString() ?? '0') ?? 0;
        _durationMinutes = int.tryParse(workoutData['duration_min']?.toString() ?? '0') ?? 0;

        _exercises = [];
        if (workoutData['exercises'] != null) {
          for (var ex in workoutData['exercises']) {
            _exercises.add({
              'name':    ex['name']?.toString() ?? 'Упражнение',
              'display': ex['display_string']?.toString() ?? '${ex['reps']} x ${ex['sets']}',
            });
          }
        }
        _isLoading = false;
      });

      return true; // успешно
    } catch (e) {
      debugPrint('Ошибка парсинга JSON тренировки: $e');
      return false; // битый
    }
  }

  // Обновляем старый метод, чтобы он понимал, что в кэше теперь лежит JSON, а не YAML
  bool _tryParseAndSetState(String cachedData) {
    try {
      final jsonData = jsonDecode(cachedData);
      return _parseJsonAndSetState(jsonData);
    } catch (e) {
      debugPrint('Ошибка парсинга кэша: $e');
      return false;
    }
  }

  // ==================== UI МЕТОДЫ ====================

  Future<void> _showAdaptationSheet(BuildContext context) async {
    // ЖДЕМ РЕЗУЛЬТАТ ИЗ ШТОРКИ (true если адаптировано, null если просто закрыли)
    final bool? isAdapted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AdaptationSheet(),
    );

    // ЕСЛИ УСПЕШНО — ПЕРЕЗАГРУЖАЕМ ТРЕНИРОВКУ ИЗ КЭША
    if (isAdapted == true) {
      setState(() => _isLoading = true);
      await loadWorkoutPlan();
    }
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30))),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ПЛАН НА СЕГОДНЯ',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[500],
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _workoutName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: i < (_difficulty == 'hard' ? 5 : _difficulty == 'medium' ? 3 : 2) 
                              ? const Color(0xFFFFD700) 
                              : Colors.grey[700],
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    _buildDot(),
                    const SizedBox(width: 8),
                    Text(
                      '$_durationMinutes мин',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildDot(),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF6B35),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_calories ккал',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      ..._exercises.map((ex) => _ExerciseRow(
                            name: ex['name']!,
                            reps: ex['display']!.split(' - ').last, 
                            icon: Icons.fitness_center,
                          )),
                      const SizedBox(height: 12),
                    ],
                  ),
                  crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlanScreen()));
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'НАЧАТЬ ТРЕНИРОВКУ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFFFF3B30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(
                          color: Color(0xFFFF3B30),
                          width: 2,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => _showAdaptationSheet(context),
                    child: Text(
                      'ИЗМЕНИТЬ ПОД ОБСТОЯТЕЛЬСТВА',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final String name;
  final String reps;
  final IconData icon;

  const _ExerciseRow({required this.name, required this.reps, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          Text(
            reps,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
