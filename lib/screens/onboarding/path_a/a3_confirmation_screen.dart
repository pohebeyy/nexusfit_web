import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/path_a/a4_health_screening_screen.dart';


/// A3: Подтверждение корректности введенных данных
class A3ConfirmationScreen extends StatefulWidget {
  const A3ConfirmationScreen({super.key});

  @override
  State<A3ConfirmationScreen> createState() => _A3ConfirmationScreenState();
}

class _A3ConfirmationScreenState extends State<A3ConfirmationScreen> {
  bool _isConfirmed = false;

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),
                  
                  // Анимированная иконка успеха
                  _buildSuccessIcon(),
                  
                  const SizedBox(height: 32),
                  
                  // Заголовок
                  const Text(
                    'Готово!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Мы получили все твои данные и готовы создать персональную программу тренировок',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Карточка с кратким резюме
                  _buildSummaryCard(),
                  
                  const SizedBox(height: 32),
                  
                  // Чекбокс подтверждения
                  _buildConfirmationCheckbox(),
                  
                  const SizedBox(height: 16),
                  
                  // Предупреждение
                  _buildWarningNote(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Кнопка продолжить
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00D9FF).withOpacity(0.2),
              const Color(0xFF00D9FF).withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00D9FF).withOpacity(0.4),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.check_circle_outline,
          size: 50,
          color: Color(0xFF00D9FF),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summaryItems = [
      {'icon': Icons.person_outline, 'label': 'Параметры тела', 'value': 'Проверены'},
      {'icon': Icons.fitness_center, 'label': 'AI-анализ', 'value': 'Завершен'},
      {'icon': Icons.photo_camera, 'label': 'Фото', 'value': 'Загружено'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D9FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  color: const Color(0xFF00D9FF).withOpacity(0.8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Что мы получили',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Divider(
            color: const Color(0xFFB0B5C0).withOpacity(0.1),
            height: 1,
          ),
          
          ...summaryItems.asMap().entries.map((entry) {
            final isLast = entry.key == summaryItems.length - 1;
            final item = entry.value;
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: const Color(0xFF00D9FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: const Color(0xFFB0B5C0).withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF00FF88),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item['value'] as String,
                            style: const TextStyle(
                              color: Color(0xFF00FF88),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    color: const Color(0xFFB0B5C0).withOpacity(0.05),
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildConfirmationCheckbox() {
    return InkWell(
      onTap: () {
        setState(() {
          _isConfirmed = !_isConfirmed;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isConfirmed 
              ? const Color(0xFF00D9FF).withOpacity(0.1) 
              : const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isConfirmed 
                ? const Color(0xFF00D9FF) 
                : const Color(0xFFB0B5C0).withOpacity(0.2),
            width: _isConfirmed ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _isConfirmed ? const Color(0xFF00D9FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isConfirmed 
                      ? const Color(0xFF00D9FF) 
                      : const Color(0xFFB0B5C0).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: _isConfirmed
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Подтверждаю корректность введенных данных',
                style: TextStyle(
                  color: _isConfirmed ? const Color(0xFF00D9FF) : Colors.white,
                  fontSize: 14,
                  fontWeight: _isConfirmed ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Точность данных влияет на эффективность твоей программы',
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isConfirmed ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: _isConfirmed
                ? const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                  )
                : null,
            color: _isConfirmed ? null : const Color(0xFF1A1F3A),
            boxShadow: _isConfirmed
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
            onPressed: _isConfirmed
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const A4HealthScreeningScreen(),
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
                color: _isConfirmed ? Colors.white : const Color(0xFFB0B5C0).withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
