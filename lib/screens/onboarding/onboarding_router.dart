import 'package:flutter/material.dart';
import 'path_a/a1_photo_upload_screen.dart';
import 'path_b/b1_manual_input_screen.dart';

/// Роутер онбординга: выбор пути A (с фото) или B (без фото)
class OnboardingRouter extends StatelessWidget {
  const OnboardingRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Заголовок
              const Text(
                'Выбери способ начала',
                style: TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Мы можем проанализировать твоё фото с помощью AI или ты можешь ввести данные вручную',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Option A: С фото (AI)
              _buildPathOption(
                context,
                title: 'С фото (AI-анализ)',
                description: 'Сделай фото и получи точные данные автоматически',
                icon: Icons.photo_camera,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const A1PhotoUploadScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Option B: Без фото (ручной ввод)
              _buildPathOption(
                context,
                title: 'Без фото (ручной ввод)',
                description: 'Введи параметры тела самостоятельно',
                icon: Icons.edit_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4FFF), Color(0xFF8B6FFF)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const B1ManualInputScreen()),
                  );
                },
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
