import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CardBarMacro extends StatelessWidget {
  final DateTime selectedDay;
  
  const CardBarMacro({required this.selectedDay});
  
  @override
  Widget build(BuildContext context) {
    final random = Random(selectedDay.day + selectedDay.month * 100);
    final macro = [
      100 + random.nextInt(50),
      45 + random.nextInt(20),
      160 + random.nextInt(50),
    ];
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

class CardBarWater extends StatelessWidget {
  final DateTime selectedDay;
  
  const CardBarWater({required this.selectedDay});
  
  @override
  Widget build(BuildContext context) {
    final random = Random(selectedDay.day + selectedDay.month * 100);
    final totalWater = 1500 + random.nextInt(700);
    final norm = 2000;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.water_drop,
          color: Colors.blueAccent,
          size: 50,
        ),
        const SizedBox(height: 10),
        Text(
          '$totalWater/$norm мл',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CardBarCalories extends StatelessWidget {
  final DateTime selectedDay;
  
  const CardBarCalories({required this.selectedDay});
  
  @override
  Widget build(BuildContext context) {
    final random = Random(selectedDay.day + selectedDay.month * 100);
    final calories = 200 + random.nextInt(400);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.local_fire_department,
          color: Colors.orangeAccent,
          size: 50,
        ),
        const SizedBox(height: 10),
        Text(
          '$calories ккал',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CardBarActivity extends StatelessWidget {
  final DateTime selectedDay;
  
  const CardBarActivity({required this.selectedDay});
  
  @override
  Widget build(BuildContext context) {
    final random = Random(selectedDay.day + selectedDay.month * 100);
    final steps = 5000 + random.nextInt(10000);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.directions_walk,
          color: Colors.greenAccent,
          size: 50,
        ),
        const SizedBox(height: 10),
        Text(
          '$steps',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'шагов',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
