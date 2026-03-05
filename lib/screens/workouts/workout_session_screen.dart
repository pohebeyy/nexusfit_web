import 'package:flutter/material.dart';
import 'workout_exercise.dart';
import 'exercise_detail_screen.dart';
import 'WorkoutPlayerScreen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String title;
  final List<Map<String, String>> exercises;

  const WorkoutSessionScreen({
    super.key,
    required this.title,
    required this.exercises,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  bool _started = false;
  late final List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();

    // Мапим данные из плана (имя + display) в WorkoutExercise
    _exercises = widget.exercises.isNotEmpty
        ? widget.exercises.map((e) {
            final name = e['name'] ?? 'Упражнение';
            final display = e['display'] ?? '';
            return WorkoutExercise(
              id: name,
              name: name,
              description: display,
              instructions: '',
              benefits: '',
              muscles: '',
              tags: const [],
              sets: 3,
              reps: 10,
              weight: 0,
              estimatedMinutes: 5,
            );
          }).toList()
        :
        // если вдруг список пустой — одна заглушка
        [
            const WorkoutExercise(
              id: 'default',
              name: 'Жим штанги лёжа',
              description:
                  'Упражнение для груди с использованием штанги на горизонтальной скамье.',
              instructions:
                  '• Лягте ровно на скамью, ноги крепко на земле.\n'
                  '• Возьмитесь за штангу верхним хватом, руки чуть шире плеч.\n'
                  '• Снимите штангу со стойки и держите её прямо над грудью.\n'
                  '• Медленно опускайте штангу вниз к груди.\n'
                  '• Сделайте паузу, затем выжмите её обратно.',
              benefits:
                  '• Нацеливается на грудные мышцы, плечи и трицепсы.\n'
                  '• Увеличивает силу верхней части тела.',
              muscles:
                  '• Грудные мышцы.\n'
                  '• Дельтовидные мышцы.\n'
                  '• Трицепсы.',
              tags: ['Сила', 'Штанга', 'Грудь'],
              sets: 4,
              reps: 8,
              weight: 30,
              estimatedMinutes: 9,
            ),
          ];
  }

  int get _totalMinutes =>
      _exercises.fold(0, (sum, e) => sum + e.estimatedMinutes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ХЕДЕР С ИНФО
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: Color(0xFFAEAEB2), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '~ $_totalMinutes мин',
                        style: const TextStyle(
                          color: Color(0xFFAEAEB2),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // СПИСОК УПРАЖНЕНИЙ
          Expanded(
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ex = _exercises[index];
                return _buildExerciseTile(context, ex, index);
              },
            ),
          ),

          // КНОПКА НАЧАТЬ/ПРОДОЛЖИТЬ
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                if (_started)
                  TextButton(
                    onPressed: () {
                      setState(() => _started = false);
                    },
                    child: const Text(
                      'Завершить тренировку',
                      style: TextStyle(
                        color: Color(0xFFAEAEB2),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF4538),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _started
                          ? 'Продолжить тренировку'
                          : 'Начать тренировку',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(
      BuildContext context, WorkoutExercise ex, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(exercise: ex),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color(0xFF1D1E33),
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFFFF4538),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '~ ${ex.estimatedMinutes} мин, '
                    '${ex.sets} сета x ${ex.weight} кг x ${ex.reps} повт.',
                    style: const TextStyle(
                      color: Color(0xFFAEAEB2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFAEAEB2), size: 22),
          ],
        ),
      ),
    );
  }
}
