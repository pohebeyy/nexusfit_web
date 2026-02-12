import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/shared/your_strategy_screen.dart';


/// Shared: Выбор диетических ограничений и предпочтений
class DietRestrictionsScreen extends StatefulWidget {
  const DietRestrictionsScreen({super.key});

  @override
  State<DietRestrictionsScreen> createState() => _DietRestrictionsScreenState();
}

class _DietRestrictionsScreenState extends State<DietRestrictionsScreen> {
  final List<String> _selectedRestrictions = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Общие предпочтения',
      'restrictions': [
        {
          'id': 'none',
          'label': 'Нет ограничений',
          'icon': Icons.restaurant,
          'color': const Color(0xFF00FF88),
          'exclusive': true,
        },
      ],
    },
    {
      'title': 'Типы питания',
      'restrictions': [
        {
          'id': 'vegetarian',
          'label': 'Вегетарианство',
          'icon': Icons.spa,
          'color': const Color(0xFF4CAF50),
        },
        {
          'id': 'vegan',
          'label': 'Веганство',
          'icon': Icons.eco,
          'color': const Color(0xFF66BB6A),
        },
        {
          'id': 'pescatarian',
          'label': 'Пескетарианство',
          'icon': Icons.set_meal,
          'color': const Color(0xFF00BCD4),
        },
        {
          'id': 'keto',
          'label': 'Кето/Low-carb',
          'icon': Icons.restaurant_menu,
          'color': const Color(0xFFFF9800),
        },
        {
          'id': 'paleo',
          'label': 'Палео',
          'icon': Icons.local_dining,
          'color': const Color(0xFFFFA726),
        },
      ],
    },
    {
      'title': 'Религиозные ограничения',
      'restrictions': [
        {
          'id': 'halal',
          'label': 'Халяль',
          'icon': Icons.mosque,
          'color': const Color(0xFF00D9FF),
        },
        {
          'id': 'kosher',
          'label': 'Кошерное',
          'icon': Icons.star,
          'color': const Color(0xFF2196F3),
        },
      ],
    },
    {
      'title': 'Аллергии и непереносимость',
      'restrictions': [
        {
          'id': 'lactose',
          'label': 'Лактоза',
          'icon': Icons.water_drop_outlined,
          'color': const Color(0xFFE91E63),
        },
        {
          'id': 'gluten',
          'label': 'Глютен',
          'icon': Icons.grain,
          'color': const Color(0xFFFF5252),
        },
        {
          'id': 'nuts',
          'label': 'Орехи',
          'icon': Icons.nature,
          'color': const Color(0xFFFFA726),
        },
        {
          'id': 'seafood',
          'label': 'Морепродукты',
          'icon': Icons.phishing,
          'color': const Color(0xFF00BCD4),
        },
        {
          'id': 'eggs',
          'label': 'Яйца',
          'icon': Icons.egg_outlined,
          'color': const Color(0xFFFFEB3B),
        },
        {
          'id': 'soy',
          'label': 'Соя',
          'icon': Icons.local_florist,
          'color': const Color(0xFF8BC34A),
        },
      ],
    },
    {
      'title': 'Исключаемые продукты',
      'restrictions': [
        {
          'id': 'no_pork',
          'label': 'Без свинины',
          'icon': Icons.block,
          'color': const Color(0xFFE91E63),
        },
        {
          'id': 'no_beef',
          'label': 'Без говядины',
          'icon': Icons.no_food,
          'color': const Color(0xFFEF5350),
        },
        {
          'id': 'no_poultry',
          'label': 'Без птицы',
          'icon': Icons.close,
          'color': const Color(0xFFFF9800),
        },
        {
          'id': 'no_fish',
          'label': 'Без рыбы',
          'icon': Icons.not_interested,
          'color': const Color(0xFF00BCD4),
        },
        {
          'id': 'no_dairy',
          'label': 'Без молочных продуктов',
          'icon': Icons.liquor,
          'color': const Color(0xFF9C27B0),
        },
      ],
    },
    {
      'title': 'Другое',
      'restrictions': [
        {
          'id': 'low_sodium',
          'label': 'Низкое содержание соли',
          'icon': Icons.invert_colors_off,
          'color': const Color(0xFF607D8B),
        },
        {
          'id': 'low_sugar',
          'label': 'Низкое содержание сахара',
          'icon': Icons.hide_source,
          'color': const Color(0xFFFF9800),
        },
        {
          'id': 'organic_only',
          'label': 'Только органические продукты',
          'icon': Icons.verified,
          'color': const Color(0xFF4CAF50),
        },
      ],
    },
  ];

  void _toggleRestriction(String restrictionId, bool isExclusive) {
    setState(() {
      if (isExclusive) {
        _selectedRestrictions.clear();
        _selectedRestrictions.add(restrictionId);
      } else {
        _selectedRestrictions.remove('none');
        
        if (_selectedRestrictions.contains(restrictionId)) {
          _selectedRestrictions.remove(restrictionId);
        } else {
          _selectedRestrictions.add(restrictionId);
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
                  'Диетические\nограничения',
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
                  'Выбери всё, что относится к твоему питанию. Мы подберём подходящий рацион',
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
                
                // Категории с ограничениями
                ...List.generate(_categories.length, (categoryIndex) {
                  final category = _categories[categoryIndex];
                  final isLastCategory = categoryIndex == _categories.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLastCategory ? 0 : 24),
                    child: _buildCategorySection(
                      title: category['title'],
                      restrictions: category['restrictions'],
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
        color: const Color(0xFF00D9FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D9FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: const Color(0xFF00D9FF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Можешь выбрать несколько пунктов. План питания будет адаптирован под все твои требования',
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
    required List<Map<String, dynamic>> restrictions,
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
        
        // Ограничения в категории
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: restrictions.map((restriction) {
            final isSelected = _selectedRestrictions.contains(restriction['id']);
            
            return _buildRestrictionChip(
              id: restriction['id'],
              label: restriction['label'],
              icon: restriction['icon'],
              color: restriction['color'],
              isSelected: isSelected,
              isExclusive: restriction['exclusive'] ?? false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRestrictionChip({
    required String id,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isExclusive,
  }) {
    return InkWell(
      onTap: () => _toggleRestriction(id, isExclusive),
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
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedRestrictions.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Статистика
          if (_selectedRestrictions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _selectedRestrictions.contains('none')
                    ? 'Отлично! Ограничений нет 🍽️'
                    : 'Выбрано: ${_selectedRestrictions.length} ${_getRestrictionWord(_selectedRestrictions.length)}',
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
                
              ),
              child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const YourStrategyScreen(),
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
        ],
      ),
    );
  }

  String _getRestrictionWord(int count) {
    if (count == 1) return 'ограничение';
    if (count >= 2 && count <= 4) return 'ограничения';
    return 'ограничений';
  }
}
