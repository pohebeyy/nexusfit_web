import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/onboarding_provider.dart';
import 'target_bodyfat_screen.dart';

/// Shared: Выбор целевого веса
class TargetWeightScreen extends StatefulWidget {
  final double currentWeight; // Текущий вес пользователя
  
  const TargetWeightScreen({
    super.key,
    this.currentWeight = 75.0,
  });

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  double? _targetWeight;
  String _weightUnit = 'kg';

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_onWeightChanged);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _onWeightChanged() {
    final value = double.tryParse(_weightController.text);
    setState(() {
      _targetWeight = value;
    });
  }

  double get _weightDifference {
    if (_targetWeight == null) return 0;
    return _targetWeight! - widget.currentWeight;
  }

  String get _goalType {
    if (_weightDifference > 5) return 'gain';
    if (_weightDifference < -5) return 'lose';
    return 'maintain';
  }

  Color get _goalColor {
    switch (_goalType) {
      case 'gain': return const Color(0xFF00D9FF);
      case 'lose': return const Color(0xFFFF5252);
      default: return const Color(0xFF00FF88);
    }
  }

  IconData get _goalIcon {
    switch (_goalType) {
      case 'gain': return Icons.trending_up;
      case 'lose': return Icons.trending_down;
      default: return Icons.horizontal_rule;
    }
  }

  String get _goalText {
    if (_weightDifference.abs() < 0.5) return 'Поддержание веса';
    if (_weightDifference > 0) {
      return 'Набор ${_weightDifference.abs().toStringAsFixed(1)} $_weightUnit';
    }
    return 'Сброс ${_weightDifference.abs().toStringAsFixed(1)} $_weightUnit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2C2C2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 8),
                
                // Заголовок
                const Text(
                  'Какой вес ты\nхочешь достичь?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Укажи реалистичную цель. Мы рассчитаем оптимальный план',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Текущий вес
                _buildCurrentWeightCard(),
                
                const SizedBox(height: 24),
                
                // Переключатель единиц измерения
                _buildUnitToggle(),
                
                const SizedBox(height: 24),
                
                // Ввод целевого веса
                _buildWeightInput(),
                
                const SizedBox(height: 24),
                
                // Визуализация прогресса
                if (_targetWeight != null) ...[
                  _buildProgressVisualization(),
                  const SizedBox(height: 24),
                ],
                
                // Рекомендации
                if (_targetWeight != null) ...[
                  _buildRecommendations(),
                  const SizedBox(height: 24),
                ],
                
                // Быстрые цели
                _buildQuickGoals(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Кнопка продолжить
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentWeightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB0B5C0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4538).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              color: Color(0xFFFF4538),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Текущий вес',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.currentWeight.toStringAsFixed(1)} $_weightUnit',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildUnitOption('kg', 'Килограммы'),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildUnitOption('lbs', 'Фунты'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitOption(String unit, String label) {
    final isSelected = _weightUnit == unit;
    
    return InkWell(
      onTap: () => setState(() => _weightUnit = unit),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFFFFFF).withOpacity(0.15) 
              : Color(0xFFFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2C2C2E) 
                : Color(0xFFFFFFF),
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2C2C2E) : const Color(0xFFB0B5C0),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2C2C2E).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Целевой вес',
            style: TextStyle(
              color: const Color(0xFFB0B5C0).withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.3),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                _weightUnit,
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressVisualization() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _goalColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _goalColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(_goalIcon, color: _goalColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _goalText,
                  style: TextStyle(
                    color: _goalColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeightPoint(
                'Сейчас',
                widget.currentWeight,
                const Color(0xFFB0B5C0),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFB0B5C0), _goalColor],
                    ),
                  ),
                ),
              ),
              _buildWeightPoint(
                'Цель',
                _targetWeight!,
                _goalColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPoint(String label, double weight, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            weight.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    String recommendation = '';
    IconData icon = Icons.info_outline;
    Color color = const Color(0xFF00D9FF);

    if (_weightDifference.abs() < 0.5) {
      recommendation = 'Отличная цель для поддержания формы и рекомпозиции тела';
      icon = Icons.check_circle_outline;
      color = const Color(0xFF00FF88);
    } else if (_weightDifference.abs() <= 5) {
      recommendation = 'Реалистичная цель, можно достичь за 1-2 месяца';
      icon = Icons.thumb_up_outlined;
      color = const Color(0xFF00FF88);
    } else if (_weightDifference.abs() <= 10) {
      recommendation = 'Хорошая цель, потребуется 2-4 месяца упорной работы';
      icon = Icons.access_time;
      color = const Color(0xFF00D9FF);
    } else if (_weightDifference.abs() <= 20) {
      recommendation = 'Амбициозная цель! Потребуется 4-8 месяцев дисциплины';
      icon = Icons.emoji_events;
      color = const Color(0xFFFF9800);
    } else {
      recommendation = 'Очень большая цель. Рекомендуем разбить на несколько этапов';
      icon = Icons.warning_amber;
      color = const Color(0xFFFF5252);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                color: const Color(0xFFB0B5C0).withOpacity(0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGoals() {
    final goals = [
      {'label': '-5 $_weightUnit', 'value': widget.currentWeight - 5},
      {'label': '-10 $_weightUnit', 'value': widget.currentWeight - 10},
      {'label': '+5 $_weightUnit', 'value': widget.currentWeight + 5},
      {'label': '+10 $_weightUnit', 'value': widget.currentWeight + 10},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрый выбор',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
  spacing: 8,
  runSpacing: 8,
  children: goals.map((goal) {
    return InkWell(
      onTap: () {
        _weightController.text = (goal['value'] as double).toStringAsFixed(1); // ✅ ИСПРАВЛЕНО
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFB0B5C0).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          goal['label'] as String,
          style: const TextStyle(
            color: Color(0xFFB0B5C0),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }).toList(),
),

      ],
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _targetWeight != null && _targetWeight! > 0;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: canContinue ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: canContinue
                ? const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                  )
                : null,
            color: canContinue ? null : const Color(0xFF1A1F3A),
            
          ),
                        child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        // Сохраняем целевой вес в Provider
                        if (_targetWeight != null) {
                          context.read<OnboardingProvider>().setTargetWeight(_targetWeight!);
                        }

                        // Переходим на следующий экран
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TargetBodyfatScreen(),
                          ),
                        );
                      }
                    : null,

            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF4538),
              
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Продолжить',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: canContinue 
                    ? Colors.white 
                    : const Color(0xFFB0B5C0).withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
