import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeCalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const HomeCalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<HomeCalendarWidget> createState() => _HomeCalendarWidgetState();
}

class _HomeCalendarWidgetState extends State<HomeCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  Map<DateTime, bool> _workoutDays = {};

  @override
  void initState() {
    super.initState();
    _loadWorkoutDays();
  }

  // Парсим кэш, чтобы поставить точки под датами, где есть тренировка
  Future<void> _loadWorkoutDays() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString('calendar_workouts');
    if (rawJson == null) return;

    final Map<String, dynamic> calendarCache = jsonDecode(rawJson);
    final Map<DateTime, bool> days = {};

    for (final entry in calendarCache.entries) {
      final dateStr = entry.key;
      final data = entry.value;
      final dt = DateTime.tryParse(dateStr);
      if (dt != null && data is Map) {
        final calories =
            int.tryParse(data['calories']?.toString() ?? '0') ?? 0;
        final workoutName = data['workout_name']?.toString() ?? '';

        if (calories > 0 ||
            (workoutName.isNotEmpty && workoutName != 'День отдыха')) {
          days[DateTime(dt.year, dt.month, dt.day)] = true;
        }
      }
    }
    if (mounted) {
      setState(() => _workoutDays = days);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF212123), // фон календаря
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Column(
        children: [
          TableCalendar(
            locale: 'ru_RU',
            availableGestures: AvailableGestures.horizontalSwipe,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: widget.selectedDate,
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Месяц',
              CalendarFormat.week: 'Неделя',
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 18,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.grey[400]!,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: Colors.grey[400]!,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),

            // ВАЖНО: все decoration пустые, рисуем свои через builders
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(),
              todayDecoration: BoxDecoration(),
              cellPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              defaultTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            onDaySelected: (selectedDay, focusedDay) {
              widget.onDateSelected(selectedDay);
            },
            onPageChanged: (focusedDay) {},

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, events) =>
                  _buildDayCell(context, date),
              outsideBuilder: (context, date, events) =>
                  _buildDayCell(context, date, isOutside: true),
              todayBuilder: (context, date, events) =>
                  _buildDayCell(context, date, isToday: true),
              // selectedBuilder больше НЕ используем
            ),
          ),

          // Стрелочка для раскрытия/сворачивания
          GestureDetector(
            onTap: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week
                    ? CalendarFormat.month
                    : CalendarFormat.week;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8),
              color: Colors.transparent,
              child: Icon(
                _calendarFormat == CalendarFormat.week
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime date, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final hasWorkout = _workoutDays[normalizedDate] == true;

    // базовые цвета
    final baseBg = const Color(0xFF212123);
    final todayBg = const Color(0xFF2C2C2E).withOpacity(0.95);
    final todayBorder = const Color(0xFF49494B); // уже не голубой

    // для выбранного дня (пока не используем, но оставим)
    final selectedBg = const Color(0xFF2C2C2E); // #2c2c2e
    final selectedBorder = const Color(0xFF49494B); // #49494b

    Color bgColor = baseBg;
    Color borderColor = Colors.transparent;

    if (isSelected) {
      bgColor = selectedBg;
      borderColor = selectedBorder;
    } else if (isToday) {
      bgColor = todayBg;
      borderColor = todayBorder;
    }

    final textColor = isOutside
        ? Colors.white.withOpacity(0.25)
        : Colors.white.withOpacity(0.9);

    // обычная ширина и увеличенная для сегодняшнего дня (3x)
    const double normalWidth = 60;
    const double height = 40;
    final double width = isToday ? normalWidth * 3 : normalWidth;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2), // овал/капсула
        border: Border.all(
          color: borderColor,
          width: borderColor == Colors.transparent ? 0 : 1.6,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          if (hasWorkout)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF51CF66),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
