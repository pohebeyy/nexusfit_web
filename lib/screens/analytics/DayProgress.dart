import 'dart:math';
import 'package:flutter/material.dart';

class DayProgress {
  final double caloriesProgress; // 0.0 - 1.0
  final double stepsProgress;
  final double waterProgress;
  final int caloriesBurned; // ДОБАВЛЕНО ЭТО ПОЛЕ
  
  DayProgress({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.waterProgress,
    required this.caloriesBurned, // ДОБАВЛЕН ЭТОТ ПАРАМЕТР
  });
}

// CustomPainter для рисования вложенных кружков
class NestedCirclesPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double waterProgress;
  
  NestedCirclesPainter({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.waterProgress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Внешний круг - Калории (красный)
    final caloriesPaint = Paint()
      ..color = const Color(0xFFFF6B6B).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final caloriesProgressPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, 18, caloriesPaint);
    
    if (caloriesProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 18),
        -pi / 2,
        2 * pi * caloriesProgress,
        false,
        caloriesProgressPaint,
      );
    }
    
    // Средний круг - Шаги (зеленый)
    final stepsPaint = Paint()
      ..color = const Color(0xFF51CF66).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final stepsProgressPaint = Paint()
      ..color = const Color(0xFF51CF66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, 13, stepsPaint);
    
    if (stepsProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 13),
        -pi / 2,
        2 * pi * stepsProgress,
        false,
        stepsProgressPaint,
      );
    }
    
    // Внутренний круг - Вода (голубой)
    final waterPaint = Paint()
      ..color = const Color(0xFF00D2FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final waterProgressPaint = Paint()
      ..color = const Color(0xFF00D2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, 8, waterPaint);
    
    if (waterProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 8),
        -pi / 2,
        2 * pi * waterProgress,
        false,
        waterProgressPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(NestedCirclesPainter oldDelegate) {
    return oldDelegate.caloriesProgress != caloriesProgress ||
        oldDelegate.stepsProgress != stepsProgress ||
        oldDelegate.waterProgress != waterProgress;
  }
}
