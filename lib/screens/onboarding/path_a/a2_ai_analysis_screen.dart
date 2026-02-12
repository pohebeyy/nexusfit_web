import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'a3_confirmation_screen.dart';

/// A2: AI-анализ и редактирование всех параметров тела
class A2AIAnalysisScreen extends StatefulWidget {
  final String photoPath;

  const A2AIAnalysisScreen({super.key, required this.photoPath});

  @override
  State<A2AIAnalysisScreen> createState() => _A2AIAnalysisScreenState();
}

class _A2AIAnalysisScreenState extends State<A2AIAnalysisScreen> {
  bool _isAnalyzing = true;
  
  // Основные параметры
  String _gender = 'male';
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');
  final _bodyFatController = TextEditingController(text: '18');
  String _bodyType = 'mesomorph';
  
  // Измерения тела (см)
  final _neckController = TextEditingController(text: '38');
  final _shouldersController = TextEditingController(text: '115');
  final _chestController = TextEditingController(text: '95');
  final _waistController = TextEditingController(text: '80');
  final _bicepsController = TextEditingController(text: '32');
  final _forearmController = TextEditingController(text: '28');
  final _wristController = TextEditingController(text: '17');
  final _ankleController = TextEditingController(text: '23');
  final _calfController = TextEditingController(text: '36');
  final _thighController = TextEditingController(text: '55');
  final _hipsController = TextEditingController(text: '95');
  
  // Расширяемые секции
  final Map<String, bool> _expandedSections = {
    'comment': false,
    'recommendations': false,
    'problems': false,
    'strengths': false,
    'summary': false,
  };

  @override
  void initState() {
    super.initState();
    // Симуляция AI-анализа (2 секунды)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _neckController.dispose();
    _shouldersController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _bicepsController.dispose();
    _forearmController.dispose();
    _wristController.dispose();
    _ankleController.dispose();
    _calfController.dispose();
    _thighController.dispose();
    _hipsController.dispose();
    super.dispose();
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
        title: Text(
          _isAnalyzing ? 'Анализируем...' : 'Редактировать данные',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: _isAnalyzing ? _buildAnalyzingState() : _buildEditableForm(),
    );
  }

  // Состояние анализа
  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Анализируем твои данные...',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AI обрабатывает фото и\nрассчитывает параметры',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFB0B5C0).withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Форма редактирования
  Widget _buildEditableForm() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildPhotoCard(),
              const SizedBox(height: 24),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildBasicParams(),
              const SizedBox(height: 24),
              _buildBodyTypeSelector(),
              const SizedBox(height: 24),
              _buildMeasurementsSection(),
              const SizedBox(height: 24),
              _buildExpandableSection(
                'comment',
                'Комментарий',
                'Твоему типу сложно набрать массу, но с правильным подходом результаты будут отличными',
                Icons.comment_outlined,
              ),
              const SizedBox(height: 12),
              _buildExpandableSection(
                'recommendations',
                'Рекомендации',
                'Фокус на силовых упражнениях с большими весами. Увеличить калорийность рациона на 300-500 ккал',
                Icons.lightbulb_outline,
              ),
              const SizedBox(height: 12),
              _buildExpandableSection(
                'problems',
                'Основные проблемы',
                '1. Низкий % мышечной массы\n2. Слабое развитие верха спины\n3. Недостаточная гибкость',
                Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 12),
              _buildExpandableSection(
                'strengths',
                'Сильные стороны',
                '1. Хороший обмен веществ\n2. Быстрое восстановление\n3. Низкий % жира',
                Icons.star_outline,
              ),
              const SizedBox(height: 12),
              _buildExpandableSection(
                'summary',
                'Итог',
                'Потенциал высокий, но нужна систематичность и правильное питание. При регулярных тренировках результат будет через 8-12 недель',
                Icons.assessment_outlined,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D9FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: kIsWeb
            ? Image.network(
                widget.photoPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(),
              )
            : Image.file(
                File(widget.photoPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Icon(
        Icons.photo_outlined,
        size: 60,
        color: const Color(0xFFB0B5C0).withOpacity(0.5),
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

  Widget _buildBasicParams() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallInputField('Возраст', _ageController, 'лет', TextInputType.number),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallInputField('Рост', _heightController, 'см', TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallInputField('Вес', _weightController, 'кг', const TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallInputField('% жира', _bodyFatController, '%', const TextInputType.numberWithOptions(decimal: true)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тип телосложения',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildBodyTypeChip('ectomorph', 'Эктоморф')),
            const SizedBox(width: 8),
            Expanded(child: _buildBodyTypeChip('mesomorph', 'Мезоморф')),
            const SizedBox(width: 8),
            Expanded(child: _buildBodyTypeChip('endomorph', 'Эндоморф')),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyTypeChip(String value, String label) {
    final isSelected = _bodyType == value;
    return InkWell(
      onTap: () => setState(() => _bodyType = value),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2C2E).withOpacity(0.15) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4538) : const Color(0xFFFF4538).withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFFFFFF) : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Измерения тела (см)',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildMeasurementRow('Шея', _neckController, 'Обхват плеч', _shouldersController),
        const SizedBox(height: 12),
        _buildMeasurementRow('Грудь', _chestController, 'Талия', _waistController),
        const SizedBox(height: 12),
        _buildMeasurementRow('Бицепс', _bicepsController, 'Предплечье', _forearmController),
        const SizedBox(height: 12),
        _buildMeasurementRow('Запястье', _wristController, 'Щиколотка', _ankleController),
        const SizedBox(height: 12),
        _buildMeasurementRow('Икра', _calfController, 'Бедро', _thighController),
        const SizedBox(height: 12),
        _buildSingleMeasurement('Таз', _hipsController),
      ],
    );
  }

  Widget _buildMeasurementRow(String label1, TextEditingController ctrl1, String label2, TextEditingController ctrl2) {
    return Row(
      children: [
        Expanded(child: _buildMeasurementField(label1, ctrl1)),
        const SizedBox(width: 12),
        Expanded(child: _buildMeasurementField(label2, ctrl2)),
      ],
    );
  }

  Widget _buildSingleMeasurement(String label, TextEditingController controller) {
    return _buildMeasurementField(label, controller);
  }

  Widget _buildMeasurementField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFB0B5C0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFFB0B5C0).withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInputField(String label, TextEditingController controller, String suffix, TextInputType keyboardType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB0B5C0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFB0B5C0).withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                suffix,
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String key, String title, String content, IconData icon) {
    final isExpanded = _expandedSections[key] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB0B5C0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[key] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFFFF4538),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF00D9FF),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 16, bottom: 16),
              child: Text(
                content,
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.8),
                  fontSize: 13,
                  height: 1.5,
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4538), Color(0xFFFF4538)],
          ),
          
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const A3ConfirmationScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Продолжить',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
