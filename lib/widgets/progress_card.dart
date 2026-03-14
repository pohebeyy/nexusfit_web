import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final int current;
  final int target;
  final String unit;
  final Color color;

  const ProgressCard({
    Key? key,
    required this.title,
    required this.progress,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$current / $target $unit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingS),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
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
