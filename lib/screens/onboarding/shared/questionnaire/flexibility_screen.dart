import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/sleep_screen.dart';


/// Shared: Оценка гибкости и мобильности
class FlexibilityScreen extends StatefulWidget {
  const FlexibilityScreen({super.key});

  @override
  State<FlexibilityScreen> createState() => _FlexibilityScreenState();
}

class _FlexibilityScreenState extends State<FlexibilityScreen> {
  String? _overallFlexibility;
  final Map<String, String?> _bodyPartFlexibility = {};

  final List<Map<String, dynamic>> _overallLevels = [
    {
      'id': 'very_poor',
      'title': 'Очень низкая',
      'subtitle': 'Не могу дотянуться до пальцев ног',
      'icon': Icons.accessibility,
      'color': const Color(0xFFFF5252),
    },
    {
      'id': 'poor',
      'title': 'Низкая',
      'subtitle': 'Едва дотягиваюсь до колен',
      'icon': Icons.accessible_forward,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'average',
      'title': 'Средняя',
      'subtitle': 'Дотягиваюсь до щиколоток',
      'icon': Icons.accessibility_new,
      'color': const Color(0xFF00D9FF),
    },
    {
      'id': 'good',
      'title': 'Хорошая',
      'subtitle': 'Дотягиваюсь до пальцев ног',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF00FF88),
    },
    {
      'id': 'excellent',
      'title': 'Отличная',
      'subtitle': 'Могу положить ладони на пол',
      'icon': Icons.sports_gymnastics,
      'color': const Color(0xFFFFD700),
    },
  ];

  final List<Map<String, dynamic>> _bodyParts = [
    {
      'id': 'shoulders',
      'title': 'Плечи',
      'icon': Icons.accessibility,
      'color': const Color(0xFF00D9FF),
      'test': 'Можешь сцепить руки за спиной?',
    },
    {
      'id': 'hips',
      'title': 'Тазобедренные суставы',
      'icon': Icons.accessible_forward,
      'color': const Color(0xFFFF9800),
      'test': 'Можешь сесть в глубокий присед?',
    },
    {
      'id': 'hamstrings',
      'title': 'Задняя поверхность бедра',
      'icon': Icons.straighten,
      'color': const Color(0xFFE91E63),
      'test': 'Можешь наклониться с прямыми ногами?',
    },
    {
      'id': 'spine',
      'title': 'Позвоночник',
      'icon': Icons.linear_scale,
      'color': const Color(0xFF9C27B0),
      'test': 'Можешь повернуть корпус на 90°?',
    },
  ];

  final List<Map<String, dynamic>> _flexibilityOptions = [
    {'value': 'poor', 'label': 'Плохая', 'emoji': '😣'},
    {'value': 'fair', 'label': 'Средняя', 'emoji': '😐'},
    {'value': 'good', 'label': 'Хорошая', 'emoji': '😊'},
    {'value': 'excellent', 'label': 'Отличная', 'emoji': '🤸'},
  ];

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
                const SizedBox(height: 8),
                
                // Заголовок
                const Text(
                  'Оцени свою\nгибкость',
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
                  'Это поможет подобрать правильные упражнения на растяжку и избежать травм',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Общая гибкость
                _buildSectionTitle('Общая гибкость'),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Попробуй наклониться вперёд с прямыми ногами. Насколько низко ты можешь дотянуться?',
                  Icons.info_outline,
                  const Color(0xFF00D9FF),
                ),
                const SizedBox(height: 16),
                
                ...List.generate(_overallLevels.length, (index) {
                  final level = _overallLevels[index];
                  final isSelected = _overallFlexibility == level['id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFlexibilityCard(
                      id: level['id'],
                      title: level['title'],
                      subtitle: level['subtitle'],
                      icon: level['icon'],
                      color: level['color'],
                      isSelected: isSelected,
                      onTap: () => setState(() => _overallFlexibility = level['id']),
                    ),
                  );
                }),
                
                const SizedBox(height: 32),
                
                // Гибкость отдельных частей тела
                _buildSectionTitle('Проблемные зоны (опционально)'),
                const SizedBox(height: 12),
                
                Text(
                  'Отметь области, где чувствуешь скованность или ограничение движений',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ...List.generate(_bodyParts.length, (index) {
                  final part = _bodyParts[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBodyPartSection(
                      id: part['id'],
                      title: part['title'],
                      test: part['test'],
                      icon: part['icon'],
                      color: part['color'],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFFB0B5C0).withOpacity(0.9),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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

  Widget _buildFlexibilityCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? color 
                : const Color(0xFFB0B5C0).withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withOpacity(0.2) 
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            
            const SizedBox(width: 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected 
                      ? color 
                      : const Color(0xFFB0B5C0).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyPartSection({
    required String id,
    required String title,
    required String test,
    required IconData icon,
    required Color color,
  }) {
    final selectedValue = _bodyPartFlexibility[id];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок части тела
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Тест
        Text(
          test,
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.7),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Опции
        Row(
          children: _flexibilityOptions.map((option) {
            final isSelected = selectedValue == option['value'];
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _bodyPartFlexibility[id] = option['value'];
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? color.withOpacity(0.15) 
                          : const Color(0xFF1A1F3A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected 
                            ? color 
                            : const Color(0xFFB0B5C0).withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          option['emoji'],
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['label'],
                          style: TextStyle(
                            color: isSelected ? color : const Color(0xFFB0B5C0),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
    final canContinue = _overallFlexibility != null;
    
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
                        builder: (_) => const SleepScreen(),
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
    );
  }
}
