import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../utils/theme.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealCard({
    Key? key,
    required this.meal,
    this.onTap,
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
              Text(
                meal.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: AppSizes.paddingS),
              Text(
                meal.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSizes.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrient('${meal.calories.toInt()} ккал', Colors.orange),
                  _buildNutrient('${meal.protein.toInt()}г Б', Colors.red),
                  _buildNutrient('${meal.carbs.toInt()}г У', Colors.blue),
                  _buildNutrient('${meal.fats.toInt()}г Ж', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrient(String label, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
