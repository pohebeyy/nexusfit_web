// workout_player_screen.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:startap/providers/workout_provider.dart';
import 'package:startap/screens/workouts/workout_exercise.dart';
import 'package:startap/screens/workouts/rpe_rating_screen.dart';
import 'dart:html' as html;
// ВАЖНО: Проверь, что путь правильный. Здесь мы импортируем новый экран завершения тренировки.
import 'package:startap/screens/workouts/WorkoutCompleteScreen.dart'; 

class WorkoutPlayerScreen extends StatefulWidget {
  final dynamic session;
  final int initialIndex;
  final List<WorkoutExercise> exercises;

  const WorkoutPlayerScreen({
    super.key,
    this.session,
    required this.initialIndex,
    required this.exercises,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late WorkoutExercise _currentExercise;

  late Ticker _ticker;
  Duration _elapsed = Duration.zero;
  bool _isTimerRunning = false;
  DateTime? _startTime;
  List<int> _rpeHistory = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentExercise = widget.exercises[_currentIndex];
    
    _startTime = DateTime.now();

    _ticker = createTicker((elapsedTimer) {
      if (_isTimerRunning) {
        setState(() {
          _elapsed = elapsedTimer;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
  void playClick() {
  final audio = html.AudioElement('assets/sounds/click.mp3');
  audio.play();
}
 void _startTimer() {
  if (_isTimerRunning) return;

  playClick();

  _isTimerRunning = true;
  _elapsed = Duration.zero;
  _ticker.start();
}

void _stopTimer() {
  if (!_isTimerRunning) return;

  playClick();

  _isTimerRunning = false;
  _ticker.stop();
  setState(() {
    _elapsed = Duration.zero;
  });
}

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isLastExercise => _currentIndex == widget.exercises.length - 1;

    Future<void> _finishAndSaveWorkout() async {
    try {
      final duration = DateTime.now().difference(_startTime ?? DateTime.now());
      int activeMinutes = duration.inMinutes;
      
      // Убираем искусственную накрутку минут, 
      // но если прошла меньше 1 минуты (например, 30 сек), ставим хотя бы 1 минуту,
      // чтобы статистика (калории) не умножалась на ноль.
      if (activeMinutes == 0) {
        activeMinutes = 1; 
      }

      double avgRpe = 5.0;
      if (_rpeHistory.isNotEmpty) {
        avgRpe = _rpeHistory.reduce((a, b) => a + b) / _rpeHistory.length;
      }

      int caloriesBurned = ((avgRpe * 1.2) * activeMinutes).round();
      int avgHeartRate = (100 + (avgRpe * 7)).round();

      final localDate = DateTime.now();
      final formattedDate = "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";

      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'akk@gmail.com';

      final response = await http.post(
        Uri.parse('https://n8n.nexusfit.ru/webhook/activty'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail, 
          'userId': 1,
          'steps': 0,
          'active_calories': caloriesBurned, 
          'active_minutes': activeMinutes,
          'heart_rate_avg': avgHeartRate,
          'date': formattedDate
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Статистика сохранена: $caloriesBurned ккал за $activeMinutes мин.');
      }
    } catch (e) {
      debugPrint('Ошибка сети: $e');
    }
  }


  Future<void> _onCompleteSetPressed() async {
    _stopTimer();

    final rpe = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => RpeRatingScreen(
          exercise: _currentExercise,
          exerciseNumber: _currentIndex + 1,
          totalExercises: widget.exercises.length,
        ),
      ),
    );

    if (rpe == null) return;

    _rpeHistory.add(rpe);

    final provider = context.read<WorkoutProvider>();
    final sessionId = widget.session?.id;
    if (sessionId != null) {
      provider.saveExerciseRpe(
        sessionId: sessionId,
        exerciseId: _currentExercise.id,
        rpe: rpe,
        durationSeconds: _elapsed.inSeconds,
      );
    }

    if (_isLastExercise) {
      await _finishAndSaveWorkout();
      
      // Вычисляем реальные данные
      int totalMins = DateTime.now().difference(_startTime ?? DateTime.now()).inMinutes;
      if (totalMins == 0) totalMins = 1; // минимум 1 минута

      final avgRpe = _rpeHistory.isNotEmpty ? _rpeHistory.reduce((a, b) => a + b) / _rpeHistory.length : 5.0;
      final calories = ((avgRpe * 1.2) * totalMins).round();
      
      if (mounted) {
        // Переход на новый экран
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutCompleteScreen(
              // Передаем реальное время без костылей
              totalMinutes: totalMins, 
              caloriesBurned: calories,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _currentIndex++;
        _currentExercise = widget.exercises[_currentIndex];
        _elapsed = Duration.zero;
      });
    }
  }

  Future<void> _onBackPressed() async {
    _stopTimer();
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Прервать тренировку?', style: TextStyle(color: Colors.white)),
        content: Text('Прогресс текущего упражнения не сохранится', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Продолжить', style: TextStyle(color: Color(0xFF00D9FF)))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Выйти', style: TextStyle(color: Colors.red.shade400))),
        ],
      ),
    );
    if (shouldExit == true && mounted) Navigator.pop(context);
  }

  // ==========================================
  // UI СБОРКА ЭКРАНА
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildImageSection(),
            
            const Spacer(),
            
            // Нижняя карточка
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildValueCard('ВЕС (КГ)', _currentExercise.weight.toString().replaceAll(RegExp(r'\.0$'), ''), _editWeightDialog)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildValueCard('ПОДХОДЫ', _currentExercise.sets.toString(), _editSetsDialog)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildValueCard('ПОВТОРЫ', _currentExercise.reps.toString(), _editRepsDialog)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFullWidthTimer(),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 64, 
                    child: ElevatedButton(
                      onPressed: _onCompleteSetPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4538),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _isLastExercise ? 'ЗАВЕРШИТЬ ТРЕНИРОВКУ' : 'ЗАВЕРШИТЬ ПОДХОД',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ВНУТРЕННИЕ ВИДЖЕТЫ
  // ==========================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildCircularIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
          Expanded(
            child: Text(
              _currentExercise.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildCircularIconButton(icon: Icons.menu_rounded, onTap: () {}),
          const SizedBox(width: 8),
          _buildCircularIconButton(icon: Icons.close_rounded, onTap: _onBackPressed),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF2C2C2E),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: Colors.white, size: 20)),
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(24)),
        child: Stack(
          children: [
            Center(child: Icon(Icons.fitness_center_rounded, color: Colors.white.withOpacity(0.05), size: 80)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color(0xFF1C1C1E).withOpacity(0.9)],
                ),
              ),
            ),
            Positioned(
              left: 20, bottom: 20, right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ТЕКУЩЕЕ УПРАЖНЕНИЕ', style: TextStyle(color: Color(0xFFFF4538), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(_currentExercise.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFFAEAEB2), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthTimer() {
    return GestureDetector(
      onTap: () {
        if (_isTimerRunning) {
          _stopTimer();
        } else {
          _startTimer();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isTimerRunning ? const Color(0xFFFF4538) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _isTimerRunning
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4538).withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              _isTimerRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: _isTimerRunning ? const Color(0xFFFF4538) : Colors.white70,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _isTimerRunning ? 'ОСТАНОВИТЬ' : 'ЗАПУСТИТЬ ТАЙМЕР',
              style: TextStyle(
                color: _isTimerRunning ? const Color(0xFFFF4538) : const Color(0xFFAEAEB2),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              _formatDuration(_elapsed),
              style: TextStyle(
                color: _isTimerRunning ? const Color(0xFFFF4538) : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ДИАЛОГИ И РЕДАКТИРОВАНИЕ
  // ==========================================

  Future<void> _editWeightDialog() async {
    final v = await _editNumberDialog(title: 'Вес (кг)', initial: _currentExercise.weight.toDouble());
    if (v != null) setState(() => _currentExercise = _currentExercise.copyWith(weight: v.toInt()));
  }

  Future<void> _editSetsDialog() async {
    final v = await _editIntDialog(title: 'Подходы', initial: _currentExercise.sets);
    if (v != null) setState(() => _currentExercise = _currentExercise.copyWith(sets: v));
  }

  Future<void> _editRepsDialog() async {
    final v = await _editIntDialog(title: 'Повторения', initial: _currentExercise.reps);
    if (v != null) setState(() => _currentExercise = _currentExercise.copyWith(reps: v));
  }

  Future<double?> _editNumberDialog({required String title, required double initial}) async {
    final controller = TextEditingController(text: initial.toStringAsFixed(0));
    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFF0A0E27),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFF00D9FF), width: 2)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Отмена', style: TextStyle(color: Colors.white.withOpacity(0.7)))),
            ElevatedButton(
              onPressed: () {
                final v = double.tryParse(controller.text.replaceAll(',', '.'));
                if (v != null) Navigator.of(ctx).pop(v);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D9FF), foregroundColor: const Color(0xFF0A0E27)),
              child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _editIntDialog({required String title, required int initial}) async {
    final controller = TextEditingController(text: initial.toString());
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller, autofocus: true, keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFF0A0E27),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFF00D9FF), width: 2)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Отмена', style: TextStyle(color: Colors.white.withOpacity(0.7)))),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text);
                if (parsed != null) Navigator.of(ctx).pop(parsed);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D9FF), foregroundColor: const Color(0xFF0A0E27)),
              child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}
