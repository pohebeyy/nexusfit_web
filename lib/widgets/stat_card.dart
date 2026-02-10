import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final double progress;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.progress = 0.7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(icon, color: color),
              ],
            ),
            SizedBox(height: AppSizes.paddingM),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
              ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: AppSizes.paddingM),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
