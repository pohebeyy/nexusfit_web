import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/theme.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const WorkoutCard({
    Key? key,
    required this.workout,
    this.onTap,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: workout.isCompleted
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      workout.isCompleted ? 'Завершено' : 'Запланировано',
                      style: TextStyle(
                        fontSize: 12,
                        color: workout.isCompleted
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.paddingS),
              Text(
                workout.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSizes.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16),
                      SizedBox(width: 4),
                      Text('${workout.durationMinutes} мин'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 16),
                      SizedBox(width: 4),
                      Text('${workout.estimatedCalories} ккал'),
                    ],
                  ),
                  if (!workout.isCompleted)
                    GestureDetector(
                      onTap: onComplete,
                      child: Icon(Icons.check_circle_outline,
                          color: AppTheme.primaryColor),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
