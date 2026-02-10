import 'dart:ui';

import 'package:flutter/material.dart';

class DetailsModal extends StatelessWidget {
  final String type;
  const DetailsModal({required this.type});

  @override
  Widget build(BuildContext context) {
    String title = '';
    List<Widget> details = [];
    String warnings = '';
    String prediction = '';
    
    if (type == 'macro') {
      title = 'Детали по БЖУ';
      details = [
        const Text('Общий белок: 119г'),
        const Text('Общий жир: 55г'),
        const Text('Общие углеводы: 185г'),
        const SizedBox(height: 9),
        const Text('Всего блюд: 6'),
      ];
      warnings = 'Недостаточно белка на завтрак!';
      prediction = 'Завтра употреби еще 20г белка для лучшего восстановления.';
    } else if (type == 'water') {
      title = 'Детали по воде';
      details = [
        const Text('Потреблено: 2000 мл'),
        const Text('Лучшее время: 9:00, 15:00, 21:00'),
      ];
      warnings = 'Перерыв между приёмами воды слишком длинный (более 5 ч).';
      prediction = 'Рекомендовано напоминание о воде к 11:00 и 16:00.';
    } else if (type == 'sleep') {
      title = 'Детали сна';
      details = [
        const Text('Сон: 7ч 32м'),
        const Text('Самочувствие: хорошо'),
      ];
      warnings = 'Поздний подъём уменьшает бодрость.';
      prediction = 'Попробуй лечь на 30 мин раньше — прогноз: улучшение самочувствия.';
    } else if (type == 'activity') {
      title = 'Физическая активность';
      details = [
        const Text('Шагов: 9150'),
        const Text('Калорий: 622'),
        const Text('Время активности: 74 мин'),
        const Text('Восстановление: 83, усталость: 63'),
      ];
      warnings = 'Высокая утомляемость вечером (проверь нагрузки).';
      prediction = 'Завтра — больше динамики утром, снизить нагрузку вечером.';
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          ...details.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                  child: e,
                ),
              )),
          if (warnings.isNotEmpty) ...[
            const Divider(height: 18, thickness: 1, color: Colors.deepOrangeAccent),
            Text(
              'Предупреждения:',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade100,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              warnings,
              style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 14),
            ),
          ],
          if (prediction.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Прогноз на завтра:',
              style: TextStyle(
                color: Colors.lightBlueAccent.shade100,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prediction,
              style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
