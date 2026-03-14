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

  Widget _buildWeekCell(
    DateTime date, {
    required bool isSelected,
    required bool isToday,
  }) {
    const weekdays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
    final weekdayStr = weekdays[date.weekday - 1];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          width: constraints.maxWidth,
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF4C4C4D),
                    width: 1,
                  ),
                )
              : isToday
                  ? BoxDecoration(
                      color:
                          const Color(0xFF2C2C2E).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF4C4C4D),
                        width: 1,
                      ),
                    )
                  : const BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                weekdayStr,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${date.day}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // контейнер с календарём
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF212123),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
          ),
          child: TableCalendar(
            locale: 'ru_RU',
            availableGestures: AvailableGestures.horizontalSwipe,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: widget.selectedDate,
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) =>
                isSameDay(widget.selectedDate, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Месяц',
              CalendarFormat.week: 'Неделя',
            },
            daysOfWeekVisible: _calendarFormat == CalendarFormat.month,
            rowHeight: _calendarFormat == CalendarFormat.week ? 85 : 52,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: Colors.grey[400]!, fontSize: 12),
              weekendStyle:
                  TextStyle(color: Colors.grey[400]!, fontSize: 12),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle:
                  const TextStyle(color: Colors.white70),
              cellMargin: const EdgeInsets.all(4),
              cellPadding:
                  const EdgeInsets.symmetric(vertical: 2),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF2C2C2E).withOpacity(0.3),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4C4C4D),
                  width: 1,
                ),
              ),
              selectedDecoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4C4C4D),
                  width: 1,
                ),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
              ),
              outsideDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              widget.onDateSelected(selectedDay);
            },
            onPageChanged: (focusedDay) {},
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                if (_calendarFormat == CalendarFormat.month) return null;
                return _buildWeekCell(
                  date,
                  isSelected: false,
                  isToday: false,
                );
              },
              selectedBuilder: (context, date, _) {
                if (_calendarFormat == CalendarFormat.month) return null;
                return _buildWeekCell(
                  date,
                  isSelected: true,
                  isToday: false,
                );
              },
              todayBuilder: (context, date, _) {
                if (_calendarFormat == CalendarFormat.month) return null;
                return _buildWeekCell(
                  date,
                  isSelected: false,
                  isToday: true,
                );
              },
              outsideBuilder: (context, date, _) {
                if (_calendarFormat == CalendarFormat.month) return null;
                return _buildWeekCell(
                  date,
                  isSelected: false,
                  isToday: false,
                );
              },
              markerBuilder: (context, date, events) {
                final normalizedDate =
                    DateTime(date.year, date.month, date.day);
                if (_workoutDays[normalizedDate] == true) {
                  return Align(
                    alignment: _calendarFormat == CalendarFormat.week
                        ? const Alignment(0, 0.82)
                        : const Alignment(0, 0.7),
                    child: Container(
                      width: 6,
                      height: 6,
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
        ),

        // стрелочка ВПЛОТНУЮ под календарём
        GestureDetector(
          onTap: () {
            setState(() {
              _calendarFormat = _calendarFormat == CalendarFormat.week
                  ? CalendarFormat.month
                  : CalendarFormat.week;
            });
          },
          child: Container(
            // чуть шире — уменьшаем отступы по бокам
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E), // цвет по запросу
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(999),
                bottomRight: Radius.circular(999),
              ),
              border: Border.all(
                color: const Color(0xFF2C2C2E),
                width: 1,
              ),
            ),
            child: Icon(
              _calendarFormat == CalendarFormat.week
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_up_rounded,
              color: Colors.grey[300],
              size: 16, // иконка чуть меньше по высоте
            ),
          ),
        ),
      ],
    );
  }
}
