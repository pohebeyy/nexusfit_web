import 'package:flutter/material.dart';

class CardBarMacroWeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final macro = [119, 55, 185];
    final macroMax = [145, 78, 210];
    final colors = [Colors.cyanAccent, Colors.orangeAccent, Colors.yellowAccent];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) {
        final percent = (macro[i] / macroMax[i]).clamp(0.0, 1.0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              width: 18,
              height: 70 * percent,
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${macro[i]}г',
              style: TextStyle(
                color: colors[i],
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class CardBarWaterWeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [300, 620, 1100, 2000];
    final norm = 2000;
    final hours = ['6', '12', '18', '23'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) {
            final percent = (data[i] / norm).clamp(0.0, 1.0);
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  width: 13,
                  height: 60 * percent,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hours[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          '${data.last}/$norm мл',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class CardBarSleepWeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sleepH = [7.5, 8.2, 6, 7.1, 6.9, 8.0, 8.4];
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final percent = (sleepH[i] / 10).clamp(0.0, 1.0);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              width: 9,
              height: 58 * percent,
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(7),
              ),
            );
          }),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days
              .map((d) => Text(
                    d,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ))
              .toList(),
        ),
        const SizedBox(height: 2),
        const Text(
          '7-8 ч',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        )
      ],
    );
  }
}

class CardBarActivityWeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _doubleBar('Устал.', 63, Colors.redAccent),
        const SizedBox(width: 15),
        _doubleBar('Восст.', 83, Colors.greenAccent),
      ],
    );
  }

  Widget _doubleBar(String label, int value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          height: 58 * (value / 100),
          width: 23,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
