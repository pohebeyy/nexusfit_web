import 'package:flutter/material.dart';
import 'workout_exercise.dart';
import 'exercise_detail_screen.dart';
import 'WorkoutPlayerScreen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String title;
  final List<Map<String, String>> exercises;

  final int? calories;
  final String difficulty;
  final String? aiTip;

  const WorkoutSessionScreen({
    super.key,
    required this.title,
    required this.exercises,
    this.calories = 420,
    this.difficulty = 'ВЫСОКАЯ СЛОЖНОСТЬ',
    this.aiTip,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  static const _bg = Color(0xFF1C1C1E);
  static const _card = Color(0xFF2C2C2E);
  static const _accent = Color(0xFFFF4538);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFFAEAEB2);
  static const _tipBorder = Color(0xFF7A5B1E);
  static const _tipBg = Color(0xFF2A241A);

  bool _started = false;
  late final List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();

    _exercises = widget.exercises.isNotEmpty
        ? widget.exercises.map((e) {
            final name = e['name'] ?? 'Упражнение';
            final display = e['display'] ?? '';
            final reps = int.tryParse(e['reps'] ?? '') ?? 10;
            final sets = int.tryParse(e['sets'] ?? '') ?? 3;
            final weight = int.tryParse(e['weight'] ?? '') ?? 0;

            final minutes = int.tryParse(e['minutes'] ?? '') ?? 5;

            return WorkoutExercise(
              id: name,
              name: name,
              description: display,
              instructions: '',
              benefits: '',
              muscles: '',
              tags: const [],
              sets: sets,
              reps: reps,
              weight: weight,
              estimatedMinutes: minutes,
            );
          }).toList()
        : [
            const WorkoutExercise(
              id: 'default_1',
              name: 'Тяга штанги в наклоне',
              description: '',
              instructions: '',
              benefits: '',
              muscles: '',
              tags: [],
              sets: 3,
              reps: 10,
              weight: 40,
              estimatedMinutes: 6,
            ),
            const WorkoutExercise(
              id: 'default_2',
              name: 'Подтягивания',
              description: '',
              instructions: '',
              benefits: '',
              muscles: '',
              tags: [],
              sets: 3,
              reps: 12,
              weight: 0,
              estimatedMinutes: 5,
            ),
            const WorkoutExercise(
              id: 'default_3',
              name: 'Сгибание на бицепс',
              description: '',
              instructions: '',
              benefits: '',
              muscles: '',
              tags: [],
              sets: 3,
              reps: 12,
              weight: 12,
              estimatedMinutes: 5,
            ),
          ];
  }

  int get _totalMinutes =>
      _exercises.fold(0, (sum, e) => sum + e.estimatedMinutes);

  String get _defaultTip {
    final firstWeighted = _exercises.cast<WorkoutExercise?>().firstWhere(
          (e) => e != null && e.weight > 0,
          orElse: () => null,
        );

    if (firstWeighted != null) {
      final nextWeight = (firstWeighted.weight + 2.5);
      return 'Твои показатели в ${firstWeighted.name.toLowerCase()} выросли. '
          'Сегодня мы увеличим нагрузку на ${nextWeight.toStringAsFixed(nextWeight % 1 == 0 ? 0 : 1)} кг.';
    }

    return 'Сегодня темп хороший — попробуй сохранить технику и сократить отдых между подходами.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 10),
            _buildMeta(),
            const SizedBox(height: 18),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _exercises.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index < _exercises.length) {
                    final ex = _exercises[index];
                    return _buildExerciseTile(context, ex);
                  }
                  return _buildAiTip();
                },
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF242426),
                borderRadius: BorderRadius.circular(21),
              ),
              child: IconButton(
                splashRadius: 20,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _textPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                widget.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_totalMinutes} МИН • ${widget.calories} ККАЛ • ${widget.difficulty}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeta() {
    return const SizedBox.shrink();
  }

  Widget _buildExerciseTile(BuildContext context, WorkoutExercise ex) {
    final subtitle = ex.weight > 0
        ? '${ex.sets} подхода x ${ex.reps} повторов'
        : '${ex.sets} подхода x МАКС';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(exercise: ex),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: _textSecondary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: _textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _tipBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _tipBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.bolt_rounded,
              color: Color(0xFFFFC857),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFFE7C56A),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  const TextSpan(text: 'СОВЕТ AI: '),
                  TextSpan(
                    text: (widget.aiTip ?? _defaultTip).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFF5D57B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () {
            setState(() => _started = true);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutPlayerScreen(
                  exercises: _exercises,
                  initialIndex: 0,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Colors.white.withOpacity(0.06),
            ),
          ),
          child: Text(
            _started ? 'ПРОДОЛЖИТЬ ТРЕНИРОВКУ' : 'НАЧАТЬ ТРЕНИРОВКУ',
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
