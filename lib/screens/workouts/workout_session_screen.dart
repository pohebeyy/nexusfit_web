import 'package:flutter/material.dart';
import 'package:startap/screens/workouts/WorkoutPlayerScreen.dart';
import 'exercise_detail_screen.dart';
import 'workout_exercise.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  bool _started = false;

  final List<WorkoutExercise> _exercises = const [
    WorkoutExercise(
      id: 'bench_press',
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
    WorkoutExercise(
      id: 'incline_db_press',
      name: 'Жим гантелей на наклонной скамье',
      description: 'Упражнение для верхней части груди и передних дельт.',
      instructions:
          '• Установите скамью под углом 30–45°.\n'
          '• Лягте и поднимите гантели над грудью.\n'
          '• Медленно опускайте гантели к бокам груди.\n'
          '• Выжмите гантели вверх, сводя их над грудью.',
      benefits:
          '• Акцент на верхнюю часть грудных.\n'
          '• Развивает силу плечевого пояса.',
      muscles:
          '• Верхняя часть грудных мышц.\n• Передние дельтовидные.\n• Трицепсы.',
      tags: ['Гантели', 'Грудь', 'Плечи'],
      sets: 3,
      reps: 8,
      weight: 18,
      estimatedMinutes: 6,
    ),
    WorkoutExercise(
      id: 'pec_deck',
      name: 'Жим на тренажере "Пек Дек"',
      description:
          'Изолирующее упражнение на грудные мышцы с использованием тренажёра.',
      instructions:
          '• Сядьте в тренажёр, спина прижата к спинке.\n'
          '• Возьмитесь за рукояти на уровне груди.\n'
          '• Сводите руки перед собой, чувствуя сокращение груди.\n'
          '• Медленно возвращайтесь в исходное положение.',
      benefits:
          '• Хорошо изолирует грудные мышцы.\n'
          '• Подходит новичкам и для добивания груди в конце.',
      muscles: '• Большая грудная мышца.\n• Малая грудная мышца.',
      tags: ['Тренажёр', 'Грудь'],
      sets: 3,
      reps: 12,
      weight: 22,
      estimatedMinutes: 7,
    ),
  ];

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Тренировка',
          style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
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
                  const Text(
                    'Неделя 1. Грудь · Плечи',
                    style: TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                      _started ? 'Продолжить тренировку' : 'Начать тренировку',
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
