import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/diet_restrictions_screen.dart';



/// Shared: Оценка качества и продолжительности сна
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  String? _sleepDuration;
  String? _sleepQuality;
  String? _sleepSchedule;
  final List<String> _sleepIssues = [];

  final List<Map<String, dynamic>> _durationOptions = [
    {
      'id': 'less_5',
      'title': 'Меньше 5 часов',
      'subtitle': 'Критически мало',
      'icon': Icons.battery_0_bar,
      'color': const Color(0xFFFF5252),
    },
    {
      'id': '5_6',
      'title': '5-6 часов',
      'subtitle': 'Недостаточно',
      'icon': Icons.battery_2_bar,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': '6_7',
      'title': '6-7 часов',
      'subtitle': 'Приемлемо',
      'icon': Icons.battery_4_bar,
      'color': const Color(0xFF00D9FF),
    },
    {
      'id': '7_8',
      'title': '7-8 часов',
      'subtitle': 'Оптимально',
      'icon': Icons.battery_5_bar,
      'color': const Color(0xFF00FF88),
    },
    {
      'id': 'more_8',
      'title': 'Больше 8 часов',
      'subtitle': 'Много',
      'icon': Icons.battery_full,
      'color': const Color(0xFF00FF88),
    },
  ];

  final List<Map<String, dynamic>> _qualityOptions = [
    {
      'id': 'very_poor',
      'label': 'Очень плохо',
      'subtitle': 'Не высыпаюсь',
      'emoji': '😫',
      'color': const Color(0xFFFF5252),
    },
    {
      'id': 'poor',
      'label': 'Плохо',
      'subtitle': 'Часто просыпаюсь',
      'emoji': '😞',
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'fair',
      'label': 'Средне',
      'subtitle': 'Бывает по-разному',
      'emoji': '😐',
      'color': const Color(0xFF00D9FF),
    },
    {
      'id': 'good',
      'label': 'Хорошо',
      'subtitle': 'Обычно высыпаюсь',
      'emoji': '😊',
      'color': const Color(0xFF00FF88),
    },
    {
      'id': 'excellent',
      'label': 'Отлично',
      'subtitle': 'Всегда бодр',
      'emoji': '😃',
      'color': const Color(0xFF00FF88),
    },
  ];

  final List<Map<String, dynamic>> _scheduleOptions = [
    {
      'id': 'irregular',
      'label': 'Нерегулярный',
      'subtitle': 'Каждый день разное время',
      'icon': Icons.shuffle,
      'color': const Color(0xFFFF5252),
    },
    {
      'id': 'mostly_regular',
      'label': 'Почти регулярный',
      'subtitle': 'Стараюсь придерживаться',
      'icon': Icons.sync,
      'color': const Color(0xFF00D9FF),
    },
    {
      'id': 'regular',
      'label': 'Регулярный',
      'subtitle': 'Ложусь и встаю в одно время',
      'icon': Icons.schedule,
      'color': const Color(0xFF00FF88),
    },
  ];

  final List<Map<String, dynamic>> _issuesOptions = [
    {
      'id': 'insomnia',
      'label': 'Бессонница',
      'icon': Icons.nightlight_outlined,
      'color': const Color(0xFFFF5252),
    },
    {
      'id': 'snoring',
      'label': 'Храп',
      'icon': Icons.volume_up,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'apnea',
      'label': 'Апноэ',
      'icon': Icons.air,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'restless_legs',
      'label': 'Синдром беспокойных ног',
      'icon': Icons.accessibility,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 'nightmares',
      'label': 'Кошмары',
      'icon': Icons.psychology,
      'color': const Color(0xFF607D8B),
    },
    {
      'id': 'frequent_waking',
      'label': 'Частые пробуждения',
      'icon': Icons.alarm_off,
      'color': const Color(0xFFFF9800),
    },
  ];

  void _toggleIssue(String issueId) {
    setState(() {
      if (_sleepIssues.contains(issueId)) {
        _sleepIssues.remove(issueId);
      } else {
        _sleepIssues.add(issueId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
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
                  'Расскажи о\nсвоём сне',
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
                  'Качество сна напрямую влияет на восстановление и прогресс в тренировках',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Продолжительность сна
                _buildSectionTitle('Сколько часов ты спишь в среднем?'),
                const SizedBox(height: 12),
                
                ...List.generate(_durationOptions.length, (index) {
                  final option = _durationOptions[index];
                  final isSelected = _sleepDuration == option['id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDurationCard(
                      id: option['id'],
                      title: option['title'],
                      subtitle: option['subtitle'],
                      icon: option['icon'],
                      color: option['color'],
                      isSelected: isSelected,
                    ),
                  );
                }),
                
                const SizedBox(height: 32),
                
                // Качество сна
                _buildSectionTitle('Как ты оцениваешь качество сна?'),
                const SizedBox(height: 12),
                
                Row(
                  children: _qualityOptions.map((option) {
                    final isSelected = _sleepQuality == option['id'];
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildQualityChip(
                          id: option['id'],
                          emoji: option['emoji'],
                          label: option['label'],
                          color: option['color'],
                          isSelected: isSelected,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Режим сна
                _buildSectionTitle('Режим сна'),
                const SizedBox(height: 12),
                
                ...List.generate(_scheduleOptions.length, (index) {
                  final option = _scheduleOptions[index];
                  final isSelected = _sleepSchedule == option['id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildScheduleCard(
                      id: option['id'],
                      label: option['label'],
                      subtitle: option['subtitle'],
                      icon: option['icon'],
                      color: option['color'],
                      isSelected: isSelected,
                    ),
                  );
                }),
                
                const SizedBox(height: 32),
                
                // Проблемы со сном (опционально)
                _buildSectionTitle('Есть ли проблемы со сном? (опционально)'),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _issuesOptions.map((issue) {
                    final isSelected = _sleepIssues.contains(issue['id']);
                    
                    return _buildIssueChip(
                      id: issue['id'],
                      label: issue['label'],
                      icon: issue['icon'],
                      color: issue['color'],
                      isSelected: isSelected,
                    );
                  }).toList(),
                ),
                
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

  Widget _buildDurationCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _sleepDuration = id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : const Color(0xFF1A1F3A),
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
            Icon(
              icon,
              color: isSelected ? color : color.withOpacity(0.6),
              size: 28,
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

  Widget _buildQualityChip({
    required String id,
    required String emoji,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _sleepQuality = id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
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
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
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
    );
  }

  Widget _buildScheduleCard({
    required String id,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _sleepSchedule = id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color 
                : const Color(0xFFB0B5C0).withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : color.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueChip({
    required String id,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _toggleIssue(id),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : color.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
            Icons.bedtime,
            color: const Color(0xFF00D9FF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Для оптимального восстановления рекомендуется 7-9 часов качественного сна',
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
    final canContinue = _sleepDuration != null && 
                         _sleepQuality != null && 
                         _sleepSchedule != null;
    
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
                        builder: (_) => const DietRestrictionsScreen(),
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
