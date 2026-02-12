import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/equipment_screen.dart';


/// Shared: Детальный выбор опыта тренировок
class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  String? _selectedExperience;

  final List<Map<String, dynamic>> _experienceLevels = [
    {
      'id': 'complete_beginner',
      'title': 'Полный новичок',
      'subtitle': 'Никогда не тренировался или давно не занимался',
      'duration': '0-3 месяца',
      'features': [
        'Обучение базовой технике',
        'Упражнения с собственным весом',
        'Лёгкие веса и тренажёры',
        'Акцент на правильную форму',
      ],
      'example': 'Не могу сделать 5 подтягиваний или 20 отжиманий',
      'icon': Icons.child_care,
      'color': const Color(0xFF00FF88),
    },
    {
      'id': 'beginner',
      'title': 'Начинающий',
      'subtitle': 'Тренируюсь 3-12 месяцев',
      'duration': '3-12 месяцев',
      'features': [
        'Базовые упражнения освоены',
        'Работа со свободными весами',
        'Прогрессивная перегрузка',
        'Фулл-боди или сплит 2-3 дня',
      ],
      'example': 'Жму штангу 50-70% от веса тела, присед 70-90%',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF00D9FF),
    },
    {
      'id': 'intermediate',
      'title': 'Средний',
      'subtitle': 'Тренируюсь 1-3 года стабильно',
      'duration': '1-3 года',
      'features': [
        'Уверенная техника базовых упражнений',
        'Сплит-программы 4-5 дней',
        'Периодизация нагрузок',
        'Работа с большими весами',
      ],
      'example': 'Жму штангу 90-120% от веса тела, присед 120-150%',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'advanced',
      'title': 'Продвинутый',
      'subtitle': 'Тренируюсь 3+ года, есть спортивные достижения',
      'duration': '3+ года',
      'features': [
        'Продвинутые программы',
        'Сложная периодизация',
        'Специализация на группы мышц',
        'Продвинутые техники тренинга',
      ],
      'example': 'Жим 130%+, присед 160%+, становая 180%+ от веса тела',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'athlete',
      'title': 'Атлет',
      'subtitle': 'Профессиональный спорт или высокий уровень',
      'duration': '5+ лет',
      'features': [
        'Спортивная специализация',
        'Индивидуальные программы',
        'Микро/макро циклы',
        'Предсоревновательная подготовка',
      ],
      'example': 'Участие в соревнованиях, разряды, КМС/МС',
      'icon': Icons.military_tech,
      'color': const Color(0xFFFFD700),
    },
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
                  'Твой тренировочный\nопыт',
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
                  'Выбери уровень, который наиболее точно описывает твою текущую физическую форму',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Карточки уровней опыта
                ...List.generate(_experienceLevels.length, (index) {
                  final level = _experienceLevels[index];
                  final isSelected = _selectedExperience == level['id'];
                  final isLast = index == _experienceLevels.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: _buildExperienceCard(
                      id: level['id'],
                      title: level['title'],
                      subtitle: level['subtitle'],
                      duration: level['duration'],
                      features: List<String>.from(level['features']),
                      example: level['example'],
                      icon: level['icon'],
                      color: level['color'],
                      isSelected: isSelected,
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Подсказка
                _buildInfoCard(),
                
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

  Widget _buildExperienceCard({
    required String id,
    required String title,
    required String subtitle,
    required String duration,
    required List<String> features,
    required String example,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedExperience = id),
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
            // Заголовок с иконкой
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.2) 
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: const Color(0xFFB0B5C0).withOpacity(0.6),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              color: const Color(0xFFB0B5C0).withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
            
            const SizedBox(height: 12),
            
            // Подзаголовок
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFFB0B5C0).withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            
            // Детали (показывается только для выбранного)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Фичи
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: color,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    color: const Color(0xFFB0B5C0).withOpacity(0.9),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Пример
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            example,
                            style: TextStyle(
                              color: const Color(0xFFB0B5C0).withOpacity(0.8),
                              fontSize: 11,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              'Не переживай, если сомневаешься! Программа адаптируется под твой реальный уровень в процессе тренировок',
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

  Widget _buildContinueButton() {
    final canContinue = _selectedExperience != null;
    
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
                        builder: (_) => const EquipmentScreen(),
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
