import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'a2_ai_analysis_screen.dart';

/// A1: Загрузка фото с инструкциями
class A1PhotoUploadScreen extends StatefulWidget {
  const A1PhotoUploadScreen({super.key});

  @override
  State<A1PhotoUploadScreen> createState() => _A1PhotoUploadScreenState();
}

class _A1PhotoUploadScreenState extends State<A1PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => A2AIAnalysisScreen(photoFile: image),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке фото: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),
                  
                  // Заголовок
                  const Text(
                    'Делаем фото твоего тела',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'AI проанализирует твоё фото и автоматически определит параметры тела',
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Карточка с инструкцией (большая)
                  _buildInstructionCard(),
                  
                  const SizedBox(height: 32),
                  
                  // Требования (чек-лист)
                  _buildRequirementsList(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Кнопки снизу
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2C2C2E).withOpacity(0.2),
          width: 1,
        ),
        
      ),
      child: Column(
        children: [
          // Визуализация (placeholder для гифки/изображения)
          Container(
            height: 280,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C2C2E),
                  Color(0xFF2C2C2E),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Центральная иконка (замена для гифки)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF4538).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Color(0xFFFF4538),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Фото спереди',
                        style: TextStyle(
                          color: const Color(0xFFB0B5C0).withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Бейджи "Правильно" / "Неправильно"
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildBadge('✓ Правильно', true),
                ),
              ],
            ),
          ),
          
          // Подсказка внизу карточки
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFFB0B5C0).withOpacity(0.8),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Встань ровно, камера на уровне груди, расстояние ~2 метра',
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCorrect 
            ? const Color(0xFFB0B5C0).withOpacity(0.15) 
            : const Color(0xFFB0B5C0).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? const Color(0xFFB0B5C0) : const Color(0xFFFF6B6B),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isCorrect ? const Color(0xFF1C1C1E) : const Color(0xFFFF6B6B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRequirementsList() {
    final requirements = [
      {'icon': Icons.wb_sunny_outlined, 'text': 'Нейтральное освещение'},
      {'icon': Icons.checkroom_outlined, 'text': 'В спортивной одежде или без'},
      {'icon': Icons.visibility_outlined, 'text': 'Хорошо видны контуры тела'},
      {'icon': Icons.phone_android, 'text': 'Держи телефон вертикально'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Важные условия',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...requirements.map((req) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    req['icon'] as IconData,
                    color: const Color(0xFFFF4538),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    req['text'] as String,
                    style: TextStyle(
                      color: const Color(0xFFB0B5C0).withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Кнопка "Снять фото"
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4538), Color(0xFFFF4538)],
              ),
              
            ),
            child: ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Снять фото',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Кнопка "Загрузить из галереи"
          OutlinedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
              side: BorderSide(
                color: const Color(0xFF2C2C2E).withOpacity(0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.photo_library_outlined, color: Color(0xFFFF4538), size: 22),
                SizedBox(width: 10),
                Text(
                  'Загрузить из галереи',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4538),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
