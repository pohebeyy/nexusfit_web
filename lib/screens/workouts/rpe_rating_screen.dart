// rpe_rating_screen.dart
import 'package:flutter/material.dart';
import 'package:startap/screens/workouts/workout_exercise.dart';

class RpeRatingScreen extends StatefulWidget {
  final WorkoutExercise exercise;
  final int exerciseNumber;
  final int totalExercises;

  const RpeRatingScreen({
    super.key,
    required this.exercise,
    required this.exerciseNumber,
    required this.totalExercises,
  });

  @override
  State<RpeRatingScreen> createState() => _RpeRatingScreenState();
}

class _RpeRatingScreenState extends State<RpeRatingScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRpe = 7;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getRpeDescription(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
      case 3:
      case 4:
        return 'Очень легко\nБольшой запас по повторениям';
      case 5:
      case 6:
        return 'Комфортно\n3–4 повторения в запасе';
      case 7:
        return 'Средне-тяжело\n2–3 повторения в запасе';
      case 8:
        return 'Тяжело\n1–2 повторения в запасе';
      case 9:
        return 'Почти максимум\n0–1 повторение в запасе';
      case 10:
        return 'Максимум\nДальше не пойдёт';
      default:
        return '';
    }
  }

  Color _getRpeColor(int rpe) {
    if (rpe <= 4) return const Color(0xFF4CAF50);
    if (rpe <= 6) return const Color(0xFF00D9FF);
    if (rpe <= 8) return const Color(0xFFFFA726);
    return const Color(0xFFFF4538);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '${widget.exerciseNumber} / ${widget.totalExercises}',
                    style: const TextStyle(
                      color: Color(0xFFAEAEB2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4538).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Оценка RPE',
                      style: TextStyle(
                        color: Color(0xFFFF4538),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Animated Icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _getRpeColor(_selectedRpe).withOpacity(0.3),
                              _getRpeColor(_selectedRpe).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: _getRpeColor(_selectedRpe),
                          size: 50,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Насколько тяжёлым было\nупражнение?',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Exercise Name
                    Text(
                      widget.exercise.name,
                      style: const TextStyle(
                        color: Color(0xFFAEAEB2),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // RPE Scale Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _getRpeColor(_selectedRpe).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getRpeColor(_selectedRpe).withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Шкала RPE',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRpeColor(_selectedRpe),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_selectedRpe / 10',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // RPE Buttons Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              final value = index + 1;
                              final isSelected = value == _selectedRpe;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedRpe = value);
                                  _animController.reset();
                                  _animController.forward();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: isSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              _getRpeColor(value),
                                              _getRpeColor(value)
                                                  .withOpacity(0.7),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : const Color(0xFF1D1E33),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : _getRpeColor(value).withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: _getRpeColor(value)
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$value',
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFFFFFFFF)
                                            : const Color(0xFFAEAEB2),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Description
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getRpeColor(_selectedRpe).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    _getRpeColor(_selectedRpe).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getRpeDescription(_selectedRpe),
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF4538).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Color(0xFFFF4538),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Оценка RPE помогает AI адаптировать\nтвой план под текущее состояние',
                              style: TextStyle(
                                color: Color(0xFFAEAEB2),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFAEAEB2),
                        side: BorderSide(
                          color: const Color(0xFFAEAEB2).withOpacity(0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Пропустить',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedRpe),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4538),
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Продолжить',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
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
}
