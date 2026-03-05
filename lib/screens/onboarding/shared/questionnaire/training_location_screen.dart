import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/onboarding_provider.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/experience_screen.dart';


/// Shared: Выбор места тренировок
class TrainingLocationScreen extends StatefulWidget {
  const TrainingLocationScreen({super.key});

  @override
  State<TrainingLocationScreen> createState() => _TrainingLocationScreenState();
}

class _TrainingLocationScreenState extends State<TrainingLocationScreen> {
  String? _selectedLocation;

  final List<Map<String, dynamic>> _locations = [
    {
      'id': 'gym',
      'title': 'Тренажёрный зал',
      'subtitle': 'Полный доступ к оборудованию',
      'description': 'Штанги, гантели, тренажёры, блоки - всё необходимое для эффективных тренировок',
      'icon': Icons.fitness_center,
      'color': const Color(0xFF00D9FF),
      'emoji': '🏋️',
      'pros': [
        'Максимум оборудования',
        'Профессиональная атмосфера',
        'Мотивация от окружающих',
      ],
    },
    {
      'id': 'home',
      'title': 'Дома',
      'subtitle': 'Удобство и экономия времени',
      'description': 'Тренировки с минимальным оборудованием или собственным весом',
      'icon': Icons.home,
      'color': const Color(0xFF00FF88),
      'emoji': '🏠',
      'pros': [
        'Не тратишь время на дорогу',
        'Комфортная обстановка',
        'Экономия на абонементе',
      ],
    },
    {
      'id': 'outdoor',
      'title': 'На улице',
      'subtitle': 'Свежий воздух и турники',
      'description': 'Воркаут, бег, функциональный тренинг на спортплощадках',
      'icon': Icons.park,
      'color': const Color(0xFF4CAF50),
      'emoji': '🌳',
      'pros': [
        'Свежий воздух',
        'Бесплатно',
        'Функциональный тренинг',
      ],
    },
    {
      'id': 'hybrid',
      'title': 'Комбинированно',
      'subtitle': 'Сочетание разных локаций',
      'description': 'Гибкий подход: зал + дом или зал + улица',
      'icon': Icons.sync_alt,
      'color': const Color(0xFFFF9800),
      'emoji': '🔄',
      'pros': [
        'Максимальная гибкость',
        'Разнообразие тренировок',
        'Адаптация под обстоятельства',
      ],
    },
    {
      'id': 'hotel_travel',
      'title': 'В командировках/поездках',
      'subtitle': 'Отели, гостиницы',
      'description': 'Тренировки в условиях частых переездов с минимумом оборудования',
      'icon': Icons.flight,
      'color': const Color(0xFF9C27B0),
      'emoji': '✈️',
      'pros': [
        'Компактные программы',
        'Без привязки к месту',
        'Быстрые тренировки',
      ],
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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF00D9FF)),
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
                  'Где ты будешь\nтренироваться?',
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
                  'Выбери основное место. Программа будет адаптирована под доступное оборудование',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Карточки локаций
                ...List.generate(_locations.length, (index) {
                  final location = _locations[index];
                  final isSelected = _selectedLocation == location['id'];
                  final isLast = index == _locations.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: _buildLocationCard(
                      id: location['id'],
                      title: location['title'],
                      subtitle: location['subtitle'],
                      description: location['description'],
                      icon: location['icon'],
                      color: location['color'],
                      emoji: location['emoji'],
                      pros: List<String>.from(location['pros']),
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

  Widget _buildLocationCard({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required String emoji,
    required List<String> pros,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedLocation = id),
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
                // Эмодзи + иконка
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.2) 
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 14,
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
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: const Color(0xFFB0B5C0).withOpacity(0.8),
                          fontSize: 13,
                          height: 1.3,
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
            
            // Описание и преимущества (показывается только для выбранного)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Описание
                  Container(
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
                  
                  const SizedBox(height: 12),
                  
                  // Преимущества
                  ...pros.map((pro) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: color,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pro,
                              style: TextStyle(
                                color: const Color(0xFFB0B5C0).withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
            Icons.info_outline,
            color: const Color(0xFF00D9FF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Место можно будет изменить в настройках. Программа адаптируется автоматически',
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
    final canContinue = _selectedLocation != null;
    
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
            boxShadow: canContinue
                ? [
                    BoxShadow(
                      color: const Color(0xFF00D9FF).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
                        child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        // Сохраняем место тренировок в провайдер
                        if (_selectedLocation != null) {
                          context.read<OnboardingProvider>().setTrainingLocation(_selectedLocation!);
                        }

                        // Переходим на следующий экран
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExperienceScreen(),
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
