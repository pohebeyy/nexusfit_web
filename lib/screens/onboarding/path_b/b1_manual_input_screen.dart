import 'package:flutter/material.dart';
import 'package:startap/screens/onboarding/path_b/b2_health_screening_screen.dart';

/// B1: Ручной ввод базовых параметров тела
class B1ManualInputScreen extends StatefulWidget {
  const B1ManualInputScreen({super.key});

  @override
  State<B1ManualInputScreen> createState() => _B1ManualInputScreenState();
}

class _B1ManualInputScreenState extends State<B1ManualInputScreen> {
  String _gender = 'male';
  
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _ageController.text.isNotEmpty &&
           _heightController.text.isNotEmpty &&
           _weightController.text.isNotEmpty;
  }

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
                  'Расскажи о себе',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Эти данные помогут создать эффективную программу тренировок',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Выбор пола
                _buildSectionTitle('Пол'),
                const SizedBox(height: 12),
                _buildGenderSelector(),
                
                const SizedBox(height: 24),
                
                // Возраст
                _buildSectionTitle('Возраст'),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _ageController,
                  label: 'Сколько тебе лет?',
                  suffix: 'лет',
                  keyboardType: TextInputType.number,
                  icon: Icons.cake_outlined,
                ),
                
                const SizedBox(height: 24),
                
                // Рост
                _buildSectionTitle('Рост'),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _heightController,
                  label: 'Укажи рост',
                  suffix: 'см',
                  keyboardType: TextInputType.number,
                  icon: Icons.height,
                ),
                
                const SizedBox(height: 24),
                
                // Вес
                _buildSectionTitle('Вес'),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _weightController,
                  label: 'Укажи вес',
                  suffix: 'кг',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.monitor_weight_outlined,
                ),
                
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

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGenderOption('male', 'Мужской', Icons.male),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderOption('female', 'Женский', Icons.female),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF4538).withOpacity(0.15) 
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF4538) 
                : const Color(0xFF2C2C2E).withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFFB0B5C0),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFFFFF) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB0B5C0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Иконка
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: 22,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Поле ввода
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            
            // Суффикс
            Text(
              suffix,
              style: TextStyle(
                color: const Color(0xFFB0B5C0).withOpacity(0.6),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isValid = _isFormValid();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Счетчик заполненных полей
          if (isValid)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00FF88),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Все обязательные поля заполнены',
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          
          // Кнопка
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isValid ? 1.0 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isValid
                    ? const LinearGradient(
                        colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                      )
                    : null,
                color: isValid ? null : const Color(0xFF1A1F3A),
                boxShadow: isValid
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
                onPressed: isValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const B2HealthScreeningScreen(),
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
                    color: isValid 
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
}
