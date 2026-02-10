import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

// Импортируй ActivityDay если используешь аналитику/прогресс.

import 'package:flutter/material.dart';
import 'dart:math';

class WeeklyOverviewCalendar extends StatefulWidget {
  final VoidCallback? onOpenStats;

  const WeeklyOverviewCalendar({super.key, this.onOpenStats});

  @override
  State<WeeklyOverviewCalendar> createState() => _WeeklyOverviewCalendarState();
}

class _WeeklyOverviewCalendarState extends State<WeeklyOverviewCalendar> {
  final List<List<double>> _dailyProgress = List.generate(
    7, 
    (index) => [
      Random().nextDouble(),
      Random().nextDouble(),
      Random().nextDouble(),
    ]
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

    return GestureDetector(
      onTap: widget.onOpenStats,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final isToday = (date.year == now.year && 
                            date.month == now.month && 
                            date.day == now.day);
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 6 ? 0 : 11, // Убираем отступ справа у последнего элемента
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekDays[index],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isToday 
                            ? const Color(0xFF2C2C2E) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(26), // Овальная форма
                        border: isToday 
                            ? Border.all(
                                color: const Color(0xFFFF3B30),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}


// Рисовалка для 3-х кругов
class _ThreeRingsPainter extends CustomPainter {
  final List<double> progressValues; // [0.5, 0.8, 0.3]
  final List<Color> colors;
  final Color backgroundColor;

  _ThreeRingsPainter({
    required this.progressValues,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    // Толщина линии кольца
    final strokeWidth = 2.5; 
    // Промежуток между кольцами
    final gap = 1.5;

    for (int i = 0; i < 3; i++) {
      if (i >= progressValues.length) break;

      final radius = maxRadius - (i * (strokeWidth + gap));
      final progress = progressValues[i].clamp(0.0, 1.0);
      final color = colors[i % colors.length];

      // Фон кольца (тусклый)
      final bgPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, bgPaint);

      // Активное кольцо
      final activePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Рисуем дугу (начинаем с -90 градусов, т.е. сверху)
      // 2 * pi * progress = угол в радианах
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, 
        2 * pi * progress, 
        false, 
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _ExpandedCalendarSheet extends StatefulWidget {
  final Function(String type)? onEdit;
  const _ExpandedCalendarSheet({this.onEdit});
  @override
  State<_ExpandedCalendarSheet> createState() => _ExpandedCalendarSheetState();
}

class _ExpandedCalendarSheetState extends State<_ExpandedCalendarSheet> {
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, bool> _dataDays = {};

  @override
  void initState() {
    super.initState();
    // fill random days with data (emulated)
    for (int i = -12; i <= 5; i++) {
      final d = DateTime.now().add(Duration(days: i));
      if (Random().nextBool()) {
        _dataDays[DateTime(d.year, d.month, d.day)] = true;
      }
    }
  }

  bool _hasData(DateTime d) => _dataDays[DateTime(d.year, d.month, d.day)] == true;

  void _showDetailsModal(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181836),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => _DetailsModal(type: type, onEdit: widget.onEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.91,
      minChildSize: 0.60,
      maxChildSize: 0.98,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0E21),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          controller: ctrl,
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700], borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 17, vertical: 0),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(20)
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (d) => d.year == _focusedDay.year && d.month == _focusedDay.month && d.day == _focusedDay.day,
                onDaySelected: (sel, foc) => setState(() => _focusedDay = sel),
                onPageChanged: (fd) => setState(() => _focusedDay = fd),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left_rounded, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right_rounded, color: Colors.white),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(.39), shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: Color(0xFF6C5CE7), shape: BoxShape.circle),
                  defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
                  weekendTextStyle: TextStyle(color: Colors.white.withOpacity(.75)),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: Colors.white.withOpacity(.45),
                    fontWeight: FontWeight.bold,
                  ),
                  weekdayStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w700,
                  )),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, d, _) {
                    if (_hasData(d)) {
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 9, height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFF51CF66),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: const Color(0xFF51CF66).withOpacity(.7),
                              blurRadius: 7, offset: const Offset(0, 4),
                            )],
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            // --- 2x2 сетка карточек статистики ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatsCard(
                        title: 'Калории/КБЖУ',
                        icon: Icons.bar_chart,
                        onTap: () => _showDetailsModal('macro'),
                        child: _CardBarMacro(),
                      )),
                      const SizedBox(width: 14),
                      Expanded(child: _StatsCard(
                        title: 'Вода',
                        icon: Icons.water_drop,
                        onTap: () => _showDetailsModal('water'),
                        child: _CardBarWater(),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _StatsCard(
                        title: 'Сон',
                        icon: Icons.nightlight_rounded,
                        onTap: () => _showDetailsModal('sleep'),
                        child: _CardBarSleep(),
                      )),
                      const SizedBox(width: 14),
                      Expanded(child: _StatsCard(
                        title: 'Активность',
                        icon: Icons.directions_run,
                        onTap: () => _showDetailsModal('activity'),
                        child: _CardBarActivity(),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Рекомендации дня', style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF181836),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF6C5CE7), width: 1.1)),
                    child: const Text(
                      'Попробуй пить больше воды до тренировки и добавить еще один приём пищи утром.',
                      style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.43),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onTap;
  const _StatsCard({required this.title, required this.icon, required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF181836), Color(0xFF1D1E33)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.13),
              blurRadius: 16, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFA29BFE), size: 22),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// БАРЫ и карточки-диаграммы
class _CardBarMacro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final macro = [119, 55, 185];
    final macroMax = [145, 78, 210];
    final colors = [Colors.cyanAccent, Colors.orangeAccent, Colors.yellowAccent];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
          final percent = (macro[i] / macroMax[i]).clamp(0.0, 1.0);
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 900),
                width: 18,
                height: 70 * percent,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: colors[i].withOpacity(.18),
                      blurRadius: 11,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text('${macro[i]}г', style: TextStyle(color: colors[i], fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          );
        })),
      ],
    );
  }
}

class _CardBarWater extends StatelessWidget {
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
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 900),
                width: 13,
                height: 60 * percent,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('${hours[i]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 11)),
            ],
          );
        })),
        const SizedBox(height: 6),
        Text('${data.last}/$norm мл', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _CardBarSleep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sleepH = [7.5, 8.2, 6, 7.1, 6.9, 8.0, 8.4];
    final days = ['Пн','Вт','Ср','Чт','Пт','Сб','Вс'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
          final percent = (sleepH[i] / 10).clamp(0.0, 1.0);
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 900),
                width: 9,
                height: 58 * percent,
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigoAccent.withOpacity(.15),
                      blurRadius: 9,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ]);
          })),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((d) => Text(d, style: const TextStyle(color: Colors.white70, fontSize: 10))).toList(),
        ),
        const SizedBox(height: 2),
        const Text('7-8 ч', style: TextStyle(color: Colors.white38, fontSize: 11))
      ],
    );
  }
}

class _CardBarActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fatigue = 63;
    final recovery = 83;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _doubleBar('Устал.', fatigue, Colors.redAccent),
        const SizedBox(width: 15),
        _doubleBar('Восст.', recovery, Colors.greenAccent),
      ],
    );
  }

  Widget _doubleBar(String label, int value, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          height: 58 * (value / 100),
          width: 23,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.17),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        Text('$value', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}

// Модалка-подробности при клике по карточке
class _DetailsModal extends StatelessWidget {
  final String type;
  final Function(String type)? onEdit;
  const _DetailsModal({required this.type, this.onEdit});

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
        const Text('Ещё балансировать жиры утром!'),
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
    final mq = MediaQuery.of(context);
    return SafeArea(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
          padding: EdgeInsets.only(
            top: 18,
            left: 16,
            right: 16,
            bottom: mq.viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 6, width: 38,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
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
              const SizedBox(height: 6),
              if (warnings.isNotEmpty) ...[
                const Divider(height: 18, thickness: 1, color: Colors.deepOrangeAccent),
                Text('Возможные угрозы/предупреждения:', style: TextStyle(color: Colors.deepOrangeAccent.shade100, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text(warnings, style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 14)),
              ],
              if (prediction.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Прогноз на завтра:', style: TextStyle(color: Colors.lightBlueAccent.shade100, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(prediction, style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 14)),
              ],
              const SizedBox(height: 18),
              
            ],
          ),
        ),
      ),
    );
  }
}

