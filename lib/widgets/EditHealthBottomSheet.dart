
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:startap/models/health_data.dart';
import 'package:startap/providers/health_provider.dart';

class EditHealthBottomSheet extends StatefulWidget {
  final HealthData? currentData;

  const EditHealthBottomSheet({super.key, this.currentData});

  @override
  State<EditHealthBottomSheet> createState() => _EditHealthBottomSheetState();
}

class _EditHealthBottomSheetState extends State<EditHealthBottomSheet> {
  late TextEditingController _stepsController;
  late TextEditingController _heartRateController;
  late TextEditingController _sleepController;
  late TextEditingController _waterController;
  late TextEditingController _weightController;
  late TextEditingController _caloriesController;
  late TextEditingController _activeMinutesController;

  @override
  void initState() {
    super.initState();
    final data = widget.currentData ?? HealthData(date: DateTime.now());
    
    _stepsController = TextEditingController(text: '${data.steps}');
    _heartRateController = TextEditingController(text: '${data.heartRate}');
    _sleepController = TextEditingController(text: '${data.sleepHours}');
    _waterController = TextEditingController(text: '${data.waterGlassesConsumed}');
    _weightController = TextEditingController(text: '${data.weight}');
    _caloriesController = TextEditingController(text: '${data.calories}');
    _activeMinutesController = TextEditingController(text: '${data.activeMinutes}');
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _heartRateController.dispose();
    _sleepController.dispose();
    _waterController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    _activeMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Параметры здоровья',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildStyledTextField(
                    controller: _stepsController,
                    label: 'Шаги',
                    icon: Icons.directions_walk_rounded,
                    color: const Color(0xFF00D2FF),
                    suffix: 'шагов',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _heartRateController,
                    label: 'Пульс',
                    icon: Icons.favorite_rounded,
                    color: const Color(0xFFFF6B6B),
                    suffix: 'уд/мин',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _sleepController,
                    label: 'Сон',
                    icon: Icons.bedtime_rounded,
                    color: const Color(0xFF6C5CE7),
                    suffix: 'часов',
                    isDecimal: true,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _waterController,
                    label: 'Вода',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF00D2FF),
                    suffix: 'стаканов',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _weightController,
                    label: 'Вес',
                    icon: Icons.monitor_weight_rounded,
                    color: const Color(0xFFFFD93D),
                    suffix: 'кг',
                    isDecimal: true,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _caloriesController,
                    label: 'Калории',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF6B6B),
                    suffix: 'ккал',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _activeMinutesController,
                    label: 'Активность',
                    icon: Icons.timer_rounded,
                    color: const Color(0xFF51CF66),
                    suffix: 'минут',
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF6C5CE7).withOpacity(0.5),
                      ),
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String suffix,
    bool isDecimal = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        inputFormatters: [
          if (isDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _saveData() {
    final newData = HealthData(
      date: widget.currentData?.date ?? DateTime.now(),
      steps: int.tryParse(_stepsController.text) ?? 0,
      heartRate: int.tryParse(_heartRateController.text) ?? 72,
      sleepHours: double.tryParse(_sleepController.text) ?? 7.0,
      waterGlassesConsumed: int.tryParse(_waterController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 75.0,
      calories: int.tryParse(_caloriesController.text) ?? 0,
      activeMinutes: int.tryParse(_activeMinutesController.text) ?? 0,
    );

    context.read<HealthProvider>().updateHealthData(newData);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Данные сохранены!'),
        backgroundColor: const Color(0xFF51CF66),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
