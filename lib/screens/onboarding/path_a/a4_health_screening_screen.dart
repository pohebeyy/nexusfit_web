import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/onboarding_provider.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/goal_screen.dart';

/// A4: Скрининг здоровья - проверка ограничений и противопоказаний
class A4HealthScreeningScreen extends StatefulWidget {
  const A4HealthScreeningScreen({super.key});

  @override
  State<A4HealthScreeningScreen> createState() => _A4HealthScreeningScreenState();
}

class _A4HealthScreeningScreenState extends State<A4HealthScreeningScreen> {
  final List<String> _selectedIssues = [];
  final TextEditingController _otherIssueController = TextEditingController(); // Контроллер для ввода "Другое"
  bool _showOtherInput = false; // Флаг отображения поля ввода

  final List<Map<String, dynamic>> _healthIssues = [
    {
      'id': 'none',
      'title': 'Нет проблем',
      'subtitle': 'У меня всё отлично',
      'icon': Icons.favorite,
      'color': const Color(0xFF00FF88),
      'exclusive': true,
    },
    {
      'id': 'back_pain',
      'title': 'Боли в спине',
      'subtitle': 'Поясничный отдел, грыжи',
      'icon': Icons.accessibility_new,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'joints',
      'title': 'Проблемы с суставами',
      'subtitle': 'Колени, локти, плечи',
      'icon': Icons.linear_scale,
      'color': const Color(0xFFFF5252),
    },
    {
      'id': 'heart',
      'title': 'Сердечно-сосудистые',
      'subtitle': 'Давление, аритмия',
      'icon': Icons.favorite_border,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'breathing',
      'title': 'Дыхательная система',
      'subtitle': 'Астма, одышка',
      'icon': Icons.air,
      'color': const Color(0xFF00D9FF),
    },
    {
      'id': 'diabetes',
      'title': 'Диабет',
      'subtitle': 'Тип 1 или 2',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 'pregnancy',
      'title': 'Беременность',
      'subtitle': 'Или послеродовой период',
      'icon': Icons.child_care,
      'color': const Color(0xFFFF80AB),
    },
    {
      'id': 'injury',
      'title': 'Недавние травмы',
      'subtitle': 'Переломы, растяжения',
      'icon': Icons.healing,
      'color': const Color(0xFFFFA726),
    },
    {
      'id': 'surgery',
      'title': 'Операции',
      'subtitle': 'За последний год',
      'icon': Icons.local_hospital,
      'color': const Color(0xFFEF5350),
    },
    {
      'id': 'other',
      'title': 'Другое',
      'subtitle': 'Укажу подробнее',
      'icon': Icons.more_horiz,
      'color': const Color(0xFFB0B5C0),
    },
  ];

  @override
  void dispose() {
    _otherIssueController.dispose();
    super.dispose();
  }

  void _toggleIssue(String issueId, bool isExclusive) {
    setState(() {
      if (isExclusive) {
        _selectedIssues.clear();
        _selectedIssues.add(issueId);
        _showOtherInput = false;
        _otherIssueController.clear();
      } else {
        _selectedIssues.remove('none');
        
        if (_selectedIssues.contains(issueId)) {
          _selectedIssues.remove(issueId);
          if (issueId == 'other') {
            _showOtherInput = false;
            _otherIssueController.clear();
          }
        } else {
          _selectedIssues.add(issueId);
          if (issueId == 'other') {
            _showOtherInput = true;
          }
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
                const Text(
                  'Есть ли у тебя\nпроблемы со здоровьем?',
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
                  'Это поможет нам адаптировать программу и избежать травм',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildWarningCard(),
                
                const SizedBox(height: 24),
                
                ...List.generate(_healthIssues.length, (index) {
                  final issue = _healthIssues[index];
                  final isSelected = _selectedIssues.contains(issue['id']);
                  final isLast = index == _healthIssues.length - 1;
                  
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        child: _buildHealthIssueCard(
                          id: issue['id'],
                          title: issue['title'],
                          subtitle: issue['subtitle'],
                          icon: issue['icon'],
                          color: issue['color'],
                          isSelected: isSelected,
                          isExclusive: issue['exclusive'] ?? false,
                        ),
                      ),
                      
                      // Показываем поле ввода, если выбрано "Другое"
                      if (issue['id'] == 'other' && _showOtherInput)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 8), // Отступ
                          child: _buildOtherInput(),
                        ),
                    ],
                  );
                }),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildOtherInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextField(
        controller: _otherIssueController,
        style: const TextStyle(color: Colors.white),
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Опиши свои ограничения (например: травма запястья, грыжа L5-S1)...',
          hintStyle: TextStyle(color: const Color(0xFFB0B5C0).withOpacity(0.5)),
          filled: true,
          fillColor: const Color(0xFF1A1F3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFB0B5C0).withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D9FF)),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) {
           setState(() {}); // Обновляем состояние кнопки "Продолжить" при вводе
        },
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF5252).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF5252),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Важно!',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'При серьезных проблемах со здоровьем обязательно проконсультируйся с врачом перед началом тренировок',
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

  Widget _buildHealthIssueCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isExclusive,
  }) {
    return InkWell(
      onTap: () => _toggleIssue(id, isExclusive),
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
            
            const SizedBox(width: 16),
            
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
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected 
                      ? color 
                      : const Color(0xFFB0B5C0).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    // Проверка: можно продолжать, если выбрано что-то. 
    // Если выбрано "Другое", то поле ввода не должно быть пустым.
    bool canContinue = _selectedIssues.isNotEmpty;
    if (_selectedIssues.contains('other') && _otherIssueController.text.trim().isEmpty) {
      canContinue = false;
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_selectedIssues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _selectedIssues.contains('none')
                    ? 'Отлично! Можем приступать 💪'
                    : 'Выбрано: ${_selectedIssues.length} ${_getIssueWord(_selectedIssues.length)}',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ),
          
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
                        // 1. Собираем данные
                        List<String> finalIssues = List.from(_selectedIssues);
                        
                        // Если выбрано "Другое", добавляем текст, который ввел юзер
                        if (_selectedIssues.contains('other') && _otherIssueController.text.isNotEmpty) {
                          // Можно убрать 'other' из списка и заменить его на реальный текст
                          finalIssues.remove('other'); 
                          finalIssues.add('Другое: ${_otherIssueController.text.trim()}');
                        }

                        // 2. Сохраняем в Provider
                        context.read<OnboardingProvider>().setHealthIssues(finalIssues);

                        // 3. Переходим на следующий экран
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GoalScreen(),
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

  String _getIssueWord(int count) {
    if (count == 1) return 'проблема';
    if (count >= 2 && count <= 4) return 'проблемы';
    return 'проблем';
  }
}
