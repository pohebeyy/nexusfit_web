// workout_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/workout_provider.dart';
import 'package:startap/screens/workouts/workout_exercise.dart';
import 'package:startap/screens/workouts/rpe_rating_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
    _currentExercise = widget.exercises[_currentIndex];

    _ticker = createTicker((elapsed) {
      if (_isTimerRunning) {
        setState(() {
          _elapsed = elapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _elapsed = Duration.zero;
    _ticker.start();
  }

  void _stopTimer() {
    if (!_isTimerRunning) return;
    _isTimerRunning = false;
    _ticker.stop();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isLastExercise => _currentIndex == widget.exercises.length - 1;

  Future<void> _onCompleteSetPressed() async {
    _stopTimer();

    // Переход на отдельный экран RPE
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

    if (rpe == null) return; // Юзер вернулся назад

    // Сохраняем RPE
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

    // Проверяем - последнее упражнение?
    if (_isLastExercise) {
      await _showWorkoutCompletedSheet();
      if (mounted) Navigator.pop(context);
    } else {
      // Переходим к следующему
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Прервать тренировку?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Прогресс текущего упражнения не сохранится',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Продолжить',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Выйти',
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showWorkoutCompletedSheet() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).padding.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAEAEB2).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF4538).withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFFF4538),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '🎉 Тренировка завершена',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF4538).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Упражнений:',
                            style: TextStyle(
                              color: Color(0xFFAEAEB2),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${widget.exercises.length}',
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Общее время:',
                            style: TextStyle(
                              color: Color(0xFFAEAEB2),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatDuration(_elapsed),
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Neuro‑Collider обновит твой план\nс учётом ответов по RPE',
                  style: TextStyle(
                    color: Color(0xFFAEAEB2),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4538),
                      foregroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Отлично, вернуться',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final total = widget.exercises.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _onBackPressed,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Тренировка',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentIndex + 1} / $total',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 8,
                  color: const Color(0xFF1A1A2E),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00D9FF),
                                Color(0xFF7C3AED),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Video/Image Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF2C2C2E).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 72,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Видео упражнения',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Exercise Details Card
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF2C2C2E).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Name
                      Text(
                        _currentExercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Recommended Weight
                      if (_currentExercise.weight != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4538).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: const Color(0xFFFFFFFFF),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Рекомендуемый вес: ${_currentExercise.weight} кг',
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            icon: Icons.fitness_center_rounded,
                            label: 'Подходов',
                            value: _currentExercise.sets.toString(),
                          ),
                          _buildTimerCard(),
                          _buildStatCard(
                            icon: Icons.repeat_rounded,
                            label: 'Повторений',
                            value: _currentExercise.reps.toString(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Editable Fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableField(
                              label: 'Вес (кг)',
                              value: _currentExercise.weight.toString(),
                              icon: Icons.fitness_center_rounded,
                              onTap: () async {
                                final v = await _editNumberDialog(
                                  title: 'Вес (кг)',
                                  initial: _currentExercise.weight.toDouble(),
                                );
                                if (v != null) {
                                  setState(() {
                                    _currentExercise = _currentExercise.copyWith(
                                      weight: v.toInt(),
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEditableField(
                              label: 'Повторения',
                              value: _currentExercise.reps.toString(),
                              icon: Icons.repeat_rounded,
                              onTap: () async {
                                final v = await _editIntDialog(
                                  title: 'Повторения',
                                  initial: _currentExercise.reps,
                                );
                                if (v != null) {
                                  setState(() {
                                    _currentExercise =
                                        _currentExercise.copyWith(reps: v);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onCompleteSetPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4538),
                            foregroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '✓ Завершить подход',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              if (_isLastExercise) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.celebration_rounded, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF4538).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF4538), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAEAEB2),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    final text = _formatDuration(_elapsed);
    return GestureDetector(
      onTap: () {
        if (_isTimerRunning) {
          _stopTimer();
        } else {
          _startTimer();
        }
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isTimerRunning
                ? const Color(0xFFFF4538)
                : const Color(0xFFFF4538).withOpacity(0.3),
            width: 3,
          ),
          color: const Color(0xFF2C2C2E),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2E),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: const Color(0xFFFF4538),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Отдых',
                style: TextStyle(
                  color: Color(0xFFAEAEB2),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF4538).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFFF4538),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFAEAEB2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_rounded,
                  color: const Color(0xFFFF4538),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<double?> _editNumberDialog({
    required String title,
    required double initial,
  }) async {
    final controller = TextEditingController(text: initial.toStringAsFixed(0));

    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Введите значение',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E27),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: Color(0xFF00D9FF),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final v = double.tryParse(controller.text.replaceAll(',', '.'));
                if (v != null) {
                  Navigator.of(ctx).pop(v);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: const Color(0xFF0A0E27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _editIntDialog({
    required String title,
    required int initial,
  }) async {
    final controller = TextEditingController(text: initial.toString());
    
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Введите значение',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E27),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: Color(0xFF00D9FF),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text);
                if (parsed != null) {
                  Navigator.of(ctx).pop(parsed);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: const Color(0xFF0A0E27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}
