import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/target_weight_screen.dart';


/// Shared: Выбор основной цели тренировок
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? _selectedGoal;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'lose_weight',
      'title': 'Похудеть',
      'subtitle': 'Сбросить лишний вес и жир',
      'description': 'Кардио + силовые, дефицит калорий, акцент на жиросжигание',
      'icon': Icons.trending_down,
      'color': const Color(0xFFFF5252),
      'emoji': '🔥',
    },
    {
      'id': 'build_muscle',
      'title': 'Набрать массу',
      'subtitle': 'Увеличить мышечную массу',
      'description': 'Силовые тренировки, профицит калорий, гипертрофия',
      'icon': Icons.fitness_center,
      'color': const Color(0xFF00D9FF),
      'emoji': '💪',
    },
    {
      'id': 'get_toned',
      'title': 'Рельеф',
      'subtitle': 'Подтянуть тело и прорисовать мышцы',
      'description': 'Микс силовых и кардио, легкий дефицит, сушка',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFFFF9800),
      'emoji': '✨',
    },
    {
      'id': 'gain_strength',
      'title': 'Стать сильнее',
      'subtitle': 'Увеличить силовые показатели',
      'description': 'Базовые упражнения, большие веса, низкое число повторений',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD700),
      'emoji': '🏆',
    },
    {
      'id': 'improve_endurance',
      'title': 'Выносливость',
      'subtitle': 'Улучшить кардио и общую выносливость',
      'description': 'Кардио-тренировки, функциональный тренинг, высокий пульс',
      'icon': Icons.directions_run,
      'color': const Color(0xFF00FF88),
      'emoji': '🏃',
    },
    {
      'id': 'stay_healthy',
      'title': 'Поддержать здоровье',
      'subtitle': 'Общая физическая форма и здоровье',
      'description': 'Сбалансированные тренировки, умеренная интенсивность',
      'icon': Icons.favorite,
      'color': const Color(0xFFE91E63),
      'emoji': '❤️',
    },
    {
      'id': 'flexibility',
      'title': 'Гибкость',
      'subtitle': 'Улучшить растяжку и мобильность',
      'description': 'Йога, стретчинг, функциональные движения',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF9C27B0),
      'emoji': '🧘',
    },
    {
      'id': 'athletic_performance',
      'title': 'Спортивные показатели',
      'subtitle': 'Подготовка к соревнованиям',
      'description': 'Специализированный тренинг под конкретный вид спорта',
      'icon': Icons.sports_score,
      'color': const Color(0xFF00BCD4),
      'emoji': '🎯',
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
                  'Какая у тебя\nглавная цель?',
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
                  'Выбери одну основную цель. Программа будет построена именно под неё',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Карточки целей
                ...List.generate(_goals.length, (index) {
                  final goal = _goals[index];
                  final isSelected = _selectedGoal == goal['id'];
                  final isLast = index == _goals.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: _buildGoalCard(
                      id: goal['id'],
                      title: goal['title'],
                      subtitle: goal['subtitle'],
                      description: goal['description'],
                      icon: goal['icon'],
                      color: goal['color'],
                      emoji: goal['emoji'],
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

  Widget _buildGoalCard({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required String emoji,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedGoal = id),
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
                          emoji,
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
                
                // Заголовок и подзаголовок
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
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: color,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            color: const Color(0xFFB0B5C0).withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
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
              'Цель можно будет изменить в любой момент. AI адаптирует программу под новые задачи',
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
    final canContinue = _selectedGoal != null;
    
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TargetWeightScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF4538),
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
