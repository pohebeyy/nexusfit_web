import 'package:flutter/material.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1E33),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.celebration_rounded,
                  color: Color(0xFFFF4538), size: 64),
              const SizedBox(height: 16),
              const Text(
                'ТРЕНИРОВКА ЗАВЕРШЕНА',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFFF4538).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ноги (квадрицепс + ягодицы)',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Color(0xFFFF4538), size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Все упражнения выполнены',
                          style: TextStyle(
                              color: Color(0xFFFF4538), fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    _statRow('Общее время:', '43 мин'),
                    _statRow('Калории:', '385 ккал'),
                    _statRow('Интенсивность:', '94%'),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFF4538).withOpacity(0.2)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology_rounded,
                                  color: Color(0xFFFF4538), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'РЕЗУЛЬТАТ:',
                                style: TextStyle(
                                  color: Color(0xFFFF4538),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '"Отличная сессия! Ты выполнил план на 100%. Благодаря этому ты приблизился к своей цели на 1.2%"',
                            style: TextStyle(
                                color: Color(0xFFAEAEB2),
                                fontSize: 12,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    const Text(
                      'СТАТИСТИКА:',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _statRow('• Общий объём:', '15 тонн'),
                    _statRow('• Макс. вес:', '100 кг'),
                    _statRow('• Средняя интенсивность:', '87%'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4538),
                        foregroundColor: const Color(0xFFFFFFFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('ЗАВЕРШИТЬ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFFFFF),
                        side: BorderSide(
                            color: const Color(0xFFAEAEB2).withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('ДЕТАЛИ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFAEAEB2), fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
