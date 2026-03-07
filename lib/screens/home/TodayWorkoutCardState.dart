import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:startap/screens/home/adaptiom_sheet.dart';
import 'package:startap/screens/home/home_screen.dart';
import 'package:startap/screens/workouts/workout_plan_screen.dart';
import 'package:startap/services/api/StringApi.dart';

class TodayWorkoutCard extends StatefulWidget {
  const TodayWorkoutCard({Key? key}) : super(key: key);

  @override
  State<TodayWorkoutCard> createState() => TodayWorkoutCardState();
}

class TodayWorkoutCardState extends State<TodayWorkoutCard> {
  bool _isExpanded = false;
  bool _isLoading = true;

  // Динамические переменные
  String _workoutName = 'Загрузка...';
  String _difficulty = 'Определяется';
  int _calories = 0;
  int _durationMinutes = 0;
  List<Map<String, String>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  // Главная функция: проверяем кэш, если его нет/устарел — идем в сеть
  // Главная функция: проверяем кэш, если его нет/устарел — идем в сеть
Future<void> _loadWorkoutPlan() async {
  final prefs = await SharedPreferences.getInstance();
  final String todayDate = DateTime.now().toIso8601String().split('T')[0];
  final String? cachedDate = prefs.getString('workout_date');
  final String? cachedYaml = prefs.getString('workout_yaml');

  if (cachedDate == todayDate && cachedYaml != null) {
    debugPrint("Используем кэшированную тренировку за $todayDate");
    // Пробуем распарсить — если битый, сбрасываем и качаем заново
    final bool valid = _tryParseAndSetState(cachedYaml);
    if (!valid) {
      debugPrint("Кэш битый — сбрасываем и качаем заново...");
      await prefs.remove('workout_date');
      await prefs.remove('workout_yaml');
      await _fetchFromNetwork(prefs, todayDate);
    }
  } else {
    debugPrint("Кэш устарел или пуст. Скачиваем новую тренировку...");
    await _fetchFromNetwork(prefs, todayDate);
  }
}

// Загрузка по сети (n8n)
Future<void> _fetchFromNetwork(SharedPreferences prefs, String todayDate) async {
  try {
    final response = await http.post(
      Uri.parse(StringApi.apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'akk@gmail.com',
        'user_id': 1
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String yamlString = data['workout']['content'];

      // Валидируем YAML перед сохранением — битый не пишем
      try {
        loadYaml(yamlString);
      } catch (e) {
        debugPrint('API вернул битый YAML, в кэш не сохраняем: $e');
        setState(() => _isLoading = false);
        return;
      }

      await prefs.setString('workout_date', todayDate);
      await prefs.setString('workout_yaml', yamlString);

      _tryParseAndSetState(yamlString);
    } else {
      setState(() => _isLoading = false);
      debugPrint('Ошибка сервера: ${response.statusCode}');
    }
  } catch (e) {
    setState(() => _isLoading = false);
    debugPrint('Ошибка сети: $e');
  }
}

// Парсинг YAML — возвращает true если успешно, false если битый
bool _tryParseAndSetState(String yamlString) {
  try {
    final yamlMap = loadYaml(yamlString);

    setState(() {
      _workoutName = yamlMap['workout_name'] ?? 'Тренировка на сегодня';
      _difficulty  = yamlMap['difficulty']    ?? 'medium';
      _calories    = yamlMap['estimated_calories']    ?? 0;
      _durationMinutes = yamlMap['estimated_duration_min'] ?? 0;

      _exercises = [];
      if (yamlMap['exercises'] != null) {
        for (var ex in yamlMap['exercises']) {
          _exercises.add({
            'name':    ex['name'].toString(),
            'display': ex['display_string'] ?? '${ex['reps']} x ${ex['sets']}',
          });
        }
      }
      _isLoading = false;
    });

    return true; // успешно
  } catch (e) {
    debugPrint('Ошибка парсинга YAML: $e');
    return false; // битый
  }
}

  // Загрузка по сети (n8n)
  

  // Парсинг YAML и обновление UI
  void _parseAndSetState(String yamlString) {
    try {
      final yamlMap = loadYaml(yamlString);

      setState(() {
        _workoutName = yamlMap['workout_name'] ?? 'Тренировка на сегодня';
        _difficulty = yamlMap['difficulty'] ?? 'medium';
        _calories = yamlMap['estimated_calories'] ?? 0;
        _durationMinutes = yamlMap['estimated_duration_min'] ?? 0;

        _exercises = [];
        if (yamlMap['exercises'] != null) {
          for (var ex in yamlMap['exercises']) {
            _exercises.add({
              'name': ex['name'].toString(),
              'display': ex['display_string'] ?? '${ex['reps']} x ${ex['sets']}',
            });
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка парсинга YAML: $e');
      setState(() => _isLoading = false);
    }
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

  void _showAdaptationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1D1E33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AdaptationSheet(),
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
