// exercise_detail_screen.dart
import 'package:flutter/material.dart';
import 'workout_exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final WorkoutExercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515), // Главный темный фон приложения
      appBar: AppBar(
        backgroundColor: const Color(0xFF151515),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ОБ УПРАЖНЕНИИ',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Главный блок с картинкой/иконкой
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF242426),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        // Градиент на фоне иконки
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2C2C2E),
                              const Color(0xFF1C1C1E),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFFFF4538),
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Название упражнения
            Center(
              child: Text(
                exercise.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Блок Рекомендаций (Сеты, Повторы, Вес)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF242426),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFF4538).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flag_rounded, color: Color(0xFFFF4538), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'ЦЕЛЬ НА ПОДХОД',
                        style: TextStyle(
                          color: Color(0xFFFF4538),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('ПОДХОДЫ', '${exercise.sets}'),
                      _buildStatColumn('ПОВТОРЫ', '${exercise.reps}'),
                      _buildStatColumn('ВЕС', '${exercise.weight} кг'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Теги
            if (exercise.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exercise.tags.map((t) => _buildTag(t)).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Текстовые секции
            if (exercise.description.isNotEmpty) ...[
              _buildSectionCard('ОПИСАНИЕ', exercise.description, Icons.info_outline_rounded),
              const SizedBox(height: 16),
            ],

            if (exercise.instructions.isNotEmpty) ...[
              _buildSectionCard('ИНСТРУКЦИЯ', exercise.instructions, Icons.integration_instructions_outlined),
              const SizedBox(height: 16),
            ],

            if (exercise.muscles.isNotEmpty) ...[
              _buildSectionCard('МЫШЦЫ', exercise.muscles, Icons.accessibility_new_rounded),
              const SizedBox(height: 16),
            ],

            if (exercise.benefits.isNotEmpty) ...[
              _buildSectionCard('ПОЛЬЗА', exercise.benefits, Icons.star_border_rounded),
            ],
          ],
        ),
      ),
    );
  }

  // Виджет для колонок статистики
  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFAEAEB2),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // Виджет для тегов
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4538).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF4538).withOpacity(0.3),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFFF4538),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Виджет для текстовых карточек (Описание, Мышцы и тд)
  Widget _buildSectionCard(String title, String body, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF242426),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFAEAEB2), size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFAEAEB2),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
