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
        final calories = int.tryParse(data['calories']?.toString() ?? '0') ?? 0;
        final workoutName = data['workout_name']?.toString() ?? '';
        
        // Считаем день тренировочным, если есть калории или имя тренировки не равно дню отдыха
        if (calories > 0 || (workoutName.isNotEmpty && workoutName != 'День отдыха')) {
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Column(
        children: [
          TableCalendar(
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
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left_rounded, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right_rounded, color: Colors.white),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.grey[400]!, fontSize: 12),
              weekendStyle: TextStyle(color: Colors.grey[400]!, fontSize: 12),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              todayDecoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              widget.onDateSelected(selectedDay);
            },
            onPageChanged: (focusedDay) {},
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final normalizedDate = DateTime(date.year, date.month, date.day);
                if (_workoutDays[normalizedDate] == true) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF51CF66),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
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
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
