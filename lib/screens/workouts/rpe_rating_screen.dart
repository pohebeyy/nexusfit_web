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
  int _selectedRpe = 8;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Более приятная "пружинящая" анимация появления карточки
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getRpeDescription(int rpe) {
    if (rpe <= 4) return 'Оставалось сил на 5+ повторений';
    if (rpe == 5 || rpe == 6) return 'Оставалось сил на 3-4 повторения';
    if (rpe == 7) return 'Оставалось сил на 3 повторения';
    if (rpe == 8) return 'Оставалось сил на 2 повторения';
    if (rpe == 9) return 'Оставалось сил на 1 повторение';
    return 'Отказ, больше ни одного повторения';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515).withOpacity(0.95),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242426),
                    borderRadius: BorderRadius.circular(28),
                    // Добавлена оранжевая/красная обводка по краям контейнера
                    border: Border.all(
                      color: const Color(0xFFFF4538).withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      // Легкое свечение обводки
                      BoxShadow(
                        color: const Color(0xFFFF4538).withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      const Text(
                        'Как далось упражнение?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Название упражнения
                      Text(
                        widget.exercise.name.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFF4538),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Описание про AI
                      Text(
                        'Честная оценка поможет AI откалибровать веса и сделать следующую тренировку эффективнее для тебя.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Подписи зон
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildZoneLabel('ЛЕГКО', const Color(0xFF4CAF50)),
                          _buildZoneLabel('НОРМА', const Color(0xFFFFC107)),
                          _buildZoneLabel('ТЯЖЕЛО', const Color(0xFFFF9800)),
                          _buildZoneLabel('ОТКАЗ', const Color(0xFFFF4538)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Шкала RPE 1-10 с увеличенными цифрами и анимацией
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(10, (index) {
                            final value = index + 1;
                            final isSelected = value == _selectedRpe;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedRpe = value);
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: const Color(0xFFFF4538).withOpacity(0.3),
                                highlightColor: Colors.transparent,
                                child: AnimatedScale(
                                  // Если выбрано — чуть увеличиваем кнопку
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutBack,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 32, // Сделали кнопку шире
                                    height: 44, // и выше
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFF4538)
                                          : const Color(0xFF1C1C1E),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFFF4538).withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$value',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white54,
                                        fontSize: 16, // Цифры стали больше
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Динамический текст
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          // Ключ нужен, чтобы AnimatedSwitcher понимал, что текст изменился
                          child: Text(
                            _getRpeDescription(_selectedRpe),
                            key: ValueKey<int>(_selectedRpe),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Кнопка подтверждения
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, _selectedRpe),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4538),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ).copyWith(
                            overlayColor: WidgetStateProperty.all(
                              Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ПОДТВЕРДИТЬ И ДАЛЬШЕ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoneLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}
