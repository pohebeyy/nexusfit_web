// WorkoutCompleteScreen.dart
import 'package:flutter/material.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  final int totalMinutes;
  final int caloriesBurned;

  const WorkoutCompleteScreen({
    super.key,
    required this.totalMinutes,
    required this.caloriesBurned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515), // Темный фон
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Иконка кубка с красным свечением
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF4538).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4538).withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFF4538),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Заголовок
              const Text(
                'ТРЕНИРОВКА\nЗАВЕРШЕНА',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // Карточка со статусом и статистикой
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF242426),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    // Статус сессии
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'СТАТУС СЕССИИ',
                                style: TextStyle(
                                  color: Color(0xFFAEAEB2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ВСЕ УПРАЖНЕНИЯ\nВЫПОЛНЕНЫ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Статистика (Время, Калории, Интенсивность)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn('TIME', '$totalMinutes мин', Colors.white),
                        _buildStatColumn('ENERGY', '$caloriesBurned\nккал', Colors.white),
                        _buildStatColumn('INTENSITY', '94%', const Color(0xFFFF4538)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Карточка AI Анализ
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF242426),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF4538).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4538).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFFF4538),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI АНАЛИЗ',
                            style: TextStyle(
                              color: Color(0xFFAEAEB2),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '"Отличная сессия! Ты выполнил план на 100%. Мы стали на 1.2% ближе к цели."',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Нижние кнопки
              Row(
                children: [
                  
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Закрывает всё до главного экрана
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4538),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        'ЗАВЕРШИТЬ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
