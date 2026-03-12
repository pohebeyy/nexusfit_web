import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:startap/providers/onboarding_provider.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/target_zones_screen.dart';



/// Shared: Выбор целевого процента жира в теле
class TargetBodyfatScreen extends StatefulWidget {
  const TargetBodyfatScreen({super.key});

  @override
  State<TargetBodyfatScreen> createState() => _TargetBodyfatScreenState();
}

class _TargetBodyfatScreenState extends State<TargetBodyfatScreen> {
  String? _selectedGender = 'male';
  String? _selectedTarget;

  final Map<String, List<Map<String, dynamic>>> _bodyfatRanges = {
    'male': [
      {
        'id': 'essential',
        'title': '2-5%',
        'label': 'Экстремально низкий',
        'subtitle': 'Профессиональные бодибилдеры на соревнованиях',
        'description': 'Очень сухой, видны вены и волокна мышц. Опасно для здоровья на длительный срок',
        'icon': Icons.warning_amber,
        'color': const Color(0xFFFF5252),
        'visual': '💀',
      },
      {
        'id': 'athlete',
        'title': '6-13%',
        'label': 'Атлетический',
        'subtitle': 'Спортсмены, фитнес-модели',
        'description': 'Выраженный пресс кубиками, рельеф мышц, минимум жира',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFFD700),
        'visual': '🏆',
      },
      {
        'id': 'fitness',
        'title': '14-17%',
        'label': 'Фитнес',
        'subtitle': 'Подтянутый, спортивный вид',
        'description': 'Видимый пресс, хороший рельеф, здоровый баланс',
        'icon': Icons.fitness_center,
        'color': const Color(0xFF00FF88),
        'visual': '💪',
      },
      {
        'id': 'average',
        'title': '18-24%',
        'label': 'Средний',
        'subtitle': 'Нормальное телосложение',
        'description': 'Небольшой животик, общая форма хорошая',
        'icon': Icons.person,
        'color': const Color(0xFF00D9FF),
        'visual': '👤',
      },
      {
        'id': 'above_average',
        'title': '25%+',
        'label': 'Избыточный',
        'subtitle': 'Лишний вес',
        'description': 'Заметный живот, округлые формы, стоит сбросить',
        'icon': Icons.trending_up,
        'color': const Color(0xFFFF9800),
        'visual': '⚠️',
      },
    ],
    'female': [
      {
        'id': 'essential',
        'title': '10-13%',
        'label': 'Экстремально низкий',
        'subtitle': 'Профессиональные спортсменки',
        'description': 'Очень сухая форма, может нарушиться цикл. Опасно для здоровья',
        'icon': Icons.warning_amber,
        'color': const Color(0xFFFF5252),
        'visual': '💀',
      },
      {
        'id': 'athlete',
        'title': '14-20%',
        'label': 'Атлетический',
        'subtitle': 'Спортсменки, фитнес-модели',
        'description': 'Выраженный пресс, рельеф мышц, спортивная фигура',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFFD700),
        'visual': '🏆',
      },
      {
        'id': 'fitness',
        'title': '21-24%',
        'label': 'Фитнес',
        'subtitle': 'Подтянутая, здоровая форма',
        'description': 'Плоский живот, намечается пресс, женственная фигура',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF00FF88),
        'visual': '💪',
      },
      {
        'id': 'average',
        'title': '25-31%',
        'label': 'Средний',
        'subtitle': 'Нормальное телосложение',
        'description': 'Небольшой животик, здоровый баланс',
        'icon': Icons.person,
        'color': const Color(0xFF00D9FF),
        'visual': '👤',
      },
      {
        'id': 'above_average',
        'title': '32%+',
        'label': 'Избыточный',
        'subtitle': 'Лишний вес',
        'description': 'Заметный живот, стоит сбросить для здоровья',
        'icon': Icons.trending_up,
        'color': const Color(0xFFFF9800),
        'visual': '⚠️',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentRanges = _bodyfatRanges[_selectedGender]!;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFF4538)),
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
                  'Какой % жира\nты хочешь достичь?',
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
                  'Выбери целевой уровень. Это поможет рассчитать время и план питания',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Переключатель пола
                _buildGenderToggle(),
                
                const SizedBox(height: 24),
                
                // Важная информация
                _buildInfoCard(),
                
                const SizedBox(height: 24),
                
                // Диапазоны жира
                ...List.generate(currentRanges.length, (index) {
                  final range = currentRanges[index];
                  final isSelected = _selectedTarget == range['id'];
                  final isLast = index == currentRanges.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: _buildBodyfatCard(
                      id: range['id'],
                      title: range['title'],
                      label: range['label'],
                      subtitle: range['subtitle'],
                      description: range['description'],
                      icon: range['icon'],
                      color: range['color'],
                      visual: range['visual'],
                      isSelected: isSelected,
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

    Widget _buildGenderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Цвет контейнеров по твоей палитре
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGenderOption('male', 'Мужчина', Icons.male),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildGenderOption('female', 'Женщина', Icons.female),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    
    return InkWell(
      onTap: () => setState(() {
        _selectedGender = value;
        _selectedTarget = null; // Сбрасываем выбор при смене пола
      }),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF4538) // Акцентный цвет для выбранного
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFB0B5C0),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB0B5C0),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedTarget != null;
    
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
            // Заменил старый 1A1F3A на твой цвет контейнеров 2C2C2E для неактивной кнопки
            color: canContinue ? null : const Color(0xFF2C2C2E), 
          ),
          child: ElevatedButton(
            onPressed: canContinue
                ? () {
                    // Сохраняем целевой % жира в провайдер
                    if (_selectedTarget != null) {
                      context.read<OnboardingProvider>().setTargetBodyFat(_selectedTarget!);
                    }

                    // Переходим на следующий экран
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TargetZonesScreen(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFFF4538),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Важно знать',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Слишком низкий процент жира может быть опасен для здоровья. Рекомендуем консультацию с врачом при выборе экстремальных целей',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyfatCard({
    required String id,
    required String title,
    required String label,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required String visual,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedTarget = id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? color 
                : const Color(0xFFB0B5C0).withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Визуал + иконка
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.2) 
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          visual,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Заголовок
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? color : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              color: const Color(0xFFB0B5C0).withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: const Color(0xFFB0B5C0).withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Radio индикатор
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
            
            // Описание (показывается только для выбранного)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              crossFadeState: isSelected 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  
}
