import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/onboarding_provider.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/flexibility_screen.dart';


/// Shared: Выбор доступного оборудования для тренировок
class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final List<String> _selectedEquipment = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Базовое',
      'equipment': [
        {
          'id': 'bodyweight',
          'label': 'Только своё тело',
          'icon': Icons.accessibility_new,
          'color': const Color(0xFF00FF88),
          'exclusive': true,
        },
        {
          'id': 'full_gym',
          'label': 'Полный зал',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF00D9FF),
          'description': 'Доступно всё оборудование',
        },
      ],
    },
    {
      'title': 'Свободные веса',
      'equipment': [
        {
          'id': 'dumbbells',
          'label': 'Гантели',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF00D9FF),
        },
        {
          'id': 'barbell',
          'label': 'Штанга',
          'icon': Icons.horizontal_rule,
          'color': const Color(0xFF00BCD4),
        },
        {
          'id': 'kettlebell',
          'label': 'Гири',
          'icon': Icons.sports_gymnastics,
          'color': const Color(0xFF26C6DA),
        },
        {
          'id': 'ez_bar',
          'label': 'EZ-гриф',
          'icon': Icons.show_chart,
          'color': const Color(0xFF00ACC1),
        },
      ],
    },
    {
      'title': 'Тренажёры',
      'equipment': [
        {
          'id': 'cable_machine',
          'label': 'Блочный тренажёр',
          'icon': Icons.linear_scale,
          'color': const Color(0xFF9C27B0),
        },
        {
          'id': 'smith_machine',
          'label': 'Машина Смита',
          'icon': Icons.view_compact,
          'color': const Color(0xFFAB47BC),
        },
        {
          'id': 'leg_press',
          'label': 'Жим ногами',
          'icon': Icons.accessible_forward,
          'color': const Color(0xFFBA68C8),
        },
        {
          'id': 'chest_press',
          'label': 'Жим грудной',
          'icon': Icons.airline_seat_recline_normal,
          'color': const Color(0xFF9575CD),
        },
      ],
    },
    {
      'title': 'Кардио',
      'equipment': [
        {
          'id': 'treadmill',
          'label': 'Беговая дорожка',
          'icon': Icons.directions_run,
          'color': const Color(0xFFFF5252),
        },
        {
          'id': 'stationary_bike',
          'label': 'Велотренажёр',
          'icon': Icons.directions_bike,
          'color': const Color(0xFFEF5350),
        },
        {
          'id': 'elliptical',
          'label': 'Эллипсоид',
          'icon': Icons.sync_alt,
          'color': const Color(0xFFE57373),
        },
        {
          'id': 'rowing_machine',
          'label': 'Гребной тренажёр',
          'icon': Icons.rowing,
          'color': const Color(0xFFEF5350),
        },
      ],
    },
    {
      'title': 'Турники и брусья',
      'equipment': [
        {
          'id': 'pull_up_bar',
          'label': 'Турник',
          'icon': Icons.horizontal_distribute,
          'color': const Color(0xFFFF9800),
        },
        {
          'id': 'dip_bar',
          'label': 'Брусья',
          'icon': Icons.swap_horiz,
          'color': const Color(0xFFFFA726),
        },
        {
          'id': 'wall_bars',
          'label': 'Шведская стенка',
          'icon': Icons.grid_4x4,
          'color': const Color(0xFFFFB74D),
        },
      ],
    },
    {
      'title': 'Функциональное оборудование',
      'equipment': [
        {
          'id': 'trx',
          'label': 'TRX петли',
          'icon': Icons.anchor,
          'color': const Color(0xFF4CAF50),
        },
        {
          'id': 'resistance_bands',
          'label': 'Резиновые петли',
          'icon': Icons.dehaze,
          'color': const Color(0xFF66BB6A),
        },
        {
          'id': 'medicine_ball',
          'label': 'Медбол',
          'icon': Icons.sports_volleyball,
          'color': const Color(0xFF81C784),
        },
        {
          'id': 'bosu',
          'label': 'BOSU платформа',
          'icon': Icons.circle_outlined,
          'color': const Color(0xFF4DB6AC),
        },
        {
          'id': 'foam_roller',
          'label': 'Массажный ролик',
          'icon': Icons.straighten,
          'color': const Color(0xFF26A69A),
        },
      ],
    },
    {
      'title': 'Вспомогательное',
      'equipment': [
        {
          'id': 'bench',
          'label': 'Скамья',
          'icon': Icons.weekend,
          'color': const Color(0xFF607D8B),
        },
        {
          'id': 'yoga_mat',
          'label': 'Коврик',
          'icon': Icons.crop_landscape,
          'color': const Color(0xFF78909C),
        },
        {
          'id': 'jump_rope',
          'label': 'Скакалка',
          'icon': Icons.waves,
          'color': const Color(0xFF90A4AE),
        },
        {
          'id': 'ab_wheel',
          'label': 'Ролик для пресса',
          'icon': Icons.trip_origin,
          'color': const Color(0xFF546E7A),
        },
      ],
    },
  ];

  void _toggleEquipment(String equipmentId, bool isExclusive) {
    setState(() {
      if (isExclusive) {
        _selectedEquipment.clear();
        _selectedEquipment.add(equipmentId);
      } else {
        _selectedEquipment.remove('bodyweight');
        _selectedEquipment.remove('full_gym');
        
        if (_selectedEquipment.contains(equipmentId)) {
          _selectedEquipment.remove(equipmentId);
        } else {
          _selectedEquipment.add(equipmentId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Заголовок
                const Text(
                  'Какое оборудование\nу тебя есть?',
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
                  'Выбери всё доступное оборудование. Программа будет составлена с учётом этого',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Подсказка
                _buildInfoCard(),
                
                const SizedBox(height: 32),
                
                // Категории оборудования
                ...List.generate(_categories.length, (categoryIndex) {
                  final category = _categories[categoryIndex];
                  final isLastCategory = categoryIndex == _categories.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLastCategory ? 0 : 24),
                    child: _buildCategorySection(
                      title: category['title'],
                      equipment: category['equipment'],
                    ),
                  );
                }),
                
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2E).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: const Color(0xFFFF4538),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Выбери "Только своё тело" для домашних тренировок без оборудования или "Полный зал" если есть доступ ко всему',
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

  Widget _buildCategorySection({
    required String title,
    required List<Map<String, dynamic>> equipment,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок категории
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFFB0B5C0).withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Оборудование в категории
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipment.map((item) {
            final isSelected = _selectedEquipment.contains(item['id']);
            
            return _buildEquipmentChip(
              id: item['id'],
              label: item['label'],
              icon: item['icon'],
              color: item['color'],
              isSelected: isSelected,
              isExclusive: item['exclusive'] ?? false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentChip({
    required String id,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isExclusive,
  }) {
    return InkWell(
      onTap: () => _toggleEquipment(id, isExclusive),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color 
                : const Color(0xFFB0B5C0).withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : color.withOpacity(0.6),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected && !isExclusive) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle,
                color: color,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedEquipment.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Статистика
          if (_selectedEquipment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _selectedEquipment.contains('bodyweight')
                    ? 'Тренировки с собственным весом 💪'
                    : _selectedEquipment.contains('full_gym')
                        ? 'Полный доступ к залу 🏋️'
                        : 'Выбрано: ${_selectedEquipment.length} ${_getEquipmentWord(_selectedEquipment.length)}',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ),
          
          // Кнопка
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: canContinue ? 1.0 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: canContinue
                    ? const LinearGradient(
                        colors: [Color(0xFFFF4538), Color(0xFFFF4538)],
                      )
                    : null,
                color: canContinue ? null : const Color(0xFF1A1F3A),
                boxShadow: canContinue
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF4538).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
                            child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        // Сохраняем список оборудования в провайдер
                        context.read<OnboardingProvider>().setEquipment(List.from(_selectedEquipment));

                        // Переходим на следующий экран
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FlexibilityScreen(),
                          ),
                        );
                      }
                    : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Завершить',
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
        ],
      ),
    );
  }

  String _getEquipmentWord(int count) {
    if (count == 1) return 'позиция';
    if (count >= 2 && count <= 4) return 'позиции';
    return 'позиций';
  }
}
