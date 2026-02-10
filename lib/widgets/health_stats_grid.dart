// home_health_mini_stats_grid.dart
import 'package:flutter/material.dart';
import 'package:startap/models/DetailsModal.dart';

class HomeHealthMiniStatsGrid extends StatelessWidget {
  const HomeHealthMiniStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: [
        _buildMiniStatCard(
          context,
          'Калории/КБЖУ',
          Icons.bar_chart,
          const _CardBarMacro(),
          'macro',
        ),
        _buildMiniStatCard(
          context,
          'Вода',
          Icons.water_drop,
          const _CardBarWater(),
          'water',
        ),
        _buildMiniStatCard(
          context,
          'Сон',
          Icons.nightlight_rounded,
          const _CardBarSleep(),
          'sleep',
        ),
        _buildMiniStatCard(
          context,
          'Активность',
          Icons.directions_run,
          const _CardBarActivity(),
          'activity',
        ),
      ],
    );
  }

  static Widget _buildMiniStatCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget child,
    String type,
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF181836),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          builder: (ctx) => DetailsModal(type: type),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF181836), Color(0xFF1D1E33)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.13),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFA29BFE), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Ниже — те же классы диаграмм, что и в HealthDashboard (можно вынести в общий файл)

class _CardBarMacro extends StatelessWidget {
  const _CardBarMacro();

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

class _CardBarWater extends StatelessWidget {
  const _CardBarWater();

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

class _CardBarSleep extends StatelessWidget {
  const _CardBarSleep();

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

class _CardBarActivity extends StatelessWidget {
  const _CardBarActivity();

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
