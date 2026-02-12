import 'package:flutter/material.dart';
import 'package:bodychart_heatmap/bodychart_heatmap.dart';
import 'package:startap/screens/onboarding/shared/questionnaire/training_location_screen.dart';

/// Shared: Выбор целевых зон тела для акцента (ИДЕАЛЬНАЯ КАЛИБРОВКА)
class TargetZonesScreen extends StatefulWidget {
  const TargetZonesScreen({super.key});

  @override
  State<TargetZonesScreen> createState() => _TargetZonesScreenState();
}

class _TargetZonesScreenState extends State<TargetZonesScreen> {
  final Set<String> _selectedZones = {};
  final int _maxSelections = 3;
  BodyViewType _viewType = BodyViewType.front;

  final Map<String, Map<String, dynamic>> _bodyZones = {
    'chest': {
      'title': '',
      'subtitle': 'Грудные мышцы',
      'icon': '💪',
      'color': const Color(0xFF00D9FF),
      'side': 'front',
    },
    'back': {
      'title': 'Спина',
      'subtitle': 'Широчайшие, трапеции',
      'icon': '🏋️',
      'color': const Color(0xFF4CAF50),
      'side': 'back',
    },
    'shoulder': {
      'title': 'Плечи',
      'subtitle': 'Дельтовидные мышцы',
      'icon': '🦾',
      'color': const Color(0xFFFF9800),
      'side': 'both',
    },
    'arm': {
      'title': 'Руки',
      'subtitle': 'Бицепс, трицепс, предплечья',
      'icon': '💪',
      'color': const Color(0xFF9C27B0),
      'side': 'both',
    },
    'abs': {
      'title': 'Пресс',
      'subtitle': 'Прямая и косые мышцы живота',
      'icon': '🔥',
      'color': const Color(0xFFFFD700),
      'side': 'front',
    },
    'butt': {
      'title': 'Ягодицы',
      'subtitle': 'Ягодичные мышцы',
      'icon': '🍑',
      'color': const Color(0xFFFF5252),
      'side': 'back',
    },
    'leg': {
      'title': 'Ноги',
      'subtitle': 'Квадрицепс, бицепс бедра, икры',
      'icon': '🦵',
      'color': const Color(0xFF00BCD4),
      'side': 'both',
    },
  };

  void _toggleZone(String zoneId) {
    setState(() {
      if (_selectedZones.contains(zoneId)) {
        _selectedZones.remove(zoneId);
      } else {
        if (_selectedZones.length >= _maxSelections) {
          _showMaxSelectionWarning();
          return;
        }
        _selectedZones.add(zoneId);
      }
    });
  }

  void _showMaxSelectionWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Максимум 3 зоны',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: const Color(0xFFFF5252),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🔥 ИДЕАЛЬНАЯ КАЛИБРОВКА ПОД bodychart_heatmap
  String? _detectZoneFromTap(Offset localPosition, Size size) {
    // Центр контейнера
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Смещение для центрирования модели (340x500 в контейнере)
    final modelWidth = 340.0;
    final modelHeight = 500.0;
    final offsetX = (size.width - modelWidth) / 2;
    final offsetY = (size.height - modelHeight) / 2;
    
    // Координаты относительно модели
    final relX = (localPosition.dx - offsetX) / modelWidth;
    final relY = (localPosition.dy - offsetY) / modelHeight;
    
    // Если клик вне модели - игнор
    if (relX < 0 || relX > 1 || relY < 0 || relY > 1) {
      return null;
    }
    
    // Зоны по X (центр модели)
    final bool isCenter = relX >= 0.30 && relX <= 0.70;
    final bool isLeft = relX < 0.30;
    final bool isRight = relX > 0.70;
    
    if (_viewType == BodyViewType.front) {
      // ============ СПЕРЕДИ ============
      
      // 1. Голова (пропуск) - 0.00 - 0.10
      if (relY < 0.10) return null;
      
      // 2. Плечи - 0.10 - 0.20
      if (relY >= 0.10 && relY < 0.20) {
        return 'shoulder';
      }
      
      // 3. Руки (боковые зоны) - 0.20 - 0.48
      if (relY >= 0.20 && relY < 0.48) {
        if (isLeft || isRight) {
          return 'arm';
        }
      }
      
      // 4. Грудь (центр верх) - 0.20 - 0.35
      if (relY >= 0.20 && relY < 0.35 && isCenter) {
        return 'chest';
      }
      
      // 5. Пресс (центр середина) - 0.35 - 0.58
      if (relY >= 0.35 && relY < 0.58 && isCenter) {
        return 'abs';
      }
      
      // 6. Ноги - 0.58 - 1.0
      if (relY >= 0.58) {
        return 'leg';
      }
      
    } else if (_viewType == BodyViewType.back) {
      // ============ СЗАДИ ============
      
      // 1. Голова (пропуск) - 0.00 - 0.10
      if (relY < 0.10) return null;
      
      // 2. Плечи - 0.10 - 0.20
      if (relY >= 0.10 && relY < 0.20) {
        return 'shoulder';
      }
      
      // 3. Руки (боковые зоны) - 0.20 - 0.48
      if (relY >= 0.20 && relY < 0.48) {
        if (isLeft || isRight) {
          return 'arm';
        }
      }
      
      // 4. Спина (центр верх) - 0.20 - 0.50
      if (relY >= 0.20 && relY < 0.50 && isCenter) {
        return 'back';
      }
      
      // 5. Ягодицы (центр середина) - 0.50 - 0.63
      if (relY >= 0.50 && relY < 0.63 && isCenter) {
        return 'butt';
      }
      
      // 6. Ноги - 0.63 - 1.0
      if (relY >= 0.63) {
        return 'leg';
      }
    }
    
    return null;
  }

  List<String> _getVisibleZones() {
    if (_viewType == BodyViewType.front) {
      return _bodyZones.entries
          .where((e) => e.value['side'] == 'front' || e.value['side'] == 'both')
          .map((e) => e.key)
          .toList();
    } else if (_viewType == BodyViewType.back) {
      return _bodyZones.entries
          .where((e) => e.value['side'] == 'back' || e.value['side'] == 'both')
          .map((e) => e.key)
          .toList();
    } else {
      return _bodyZones.keys.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF00D9FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 8),

                const Text(
                  'На какие зоны\nсделать акцент?',
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
                  'Выбери до $_maxSelections зон. Нажми на тело или на кнопки ниже',
                  style: TextStyle(
                    color: const Color(0xFFB0B5C0).withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                _buildViewToggle(),

                const SizedBox(height: 24),

                _buildBodyVisualization(),

                const SizedBox(height: 24),

                _buildSelectionHint(),

                const SizedBox(height: 24),

                _buildZoneChips(),

                const SizedBox(height: 100),
              ],
            ),
          ),

          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Спереди',
              Icons.accessibility_new,
              BodyViewType.front,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleButton(
              'Сзади',
              Icons.accessibility,
              BodyViewType.back,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, BodyViewType type) {
    final isSelected = _viewType == type;

    return InkWell(
      onTap: () => setState(() => _viewType = type),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4538), Color(0xFFFF4538)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFB0B5C0),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB0B5C0),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyVisualization() {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00D9FF).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            _buildGridBackground(),

            // 🔥 ИДЕАЛЬНАЯ КЛИКАБЕЛЬНОСТЬ
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  // Получаем RenderBox этого GestureDetector
                  final RenderBox? box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  
                  // Конвертируем в локальные координаты
                  final localPos = box.globalToLocal(details.globalPosition);
                  
                  // Определяем зону
                  final zone = _detectZoneFromTap(localPos, box.size);
                  
                  if (zone != null) {
                    _toggleZone(zone);
                  }
                },
                child: SizedBox(
                  width: 340,
                  height: 500,
                  child: BodyChart(
                    selectedParts: _selectedZones,
                    selectedColor: const Color(0xFF00D9FF),
                    unselectedColor: const Color(0xFF2A2A3E),
                    viewType: _viewType,
                    width: 340,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: _buildSelectionCounter(),
            ),

            if (_selectedZones.isEmpty)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4538).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF4538).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Color(0xFFFF4538), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Нажми на тело',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }

  Widget _buildSelectionCounter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: _selectedZones.length >= _maxSelections
            ? const LinearGradient(colors: [Color(0xFFFF4538), Color(0xFFFF4538)])
            : const LinearGradient(colors: [Color(0xFFFF4538), Color(0xFFFF4538)]),
        borderRadius: BorderRadius.circular(20),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _selectedZones.length >= _maxSelections
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${_selectedZones.length}/$_maxSelections',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHint() {
    return AnimatedOpacity(
      opacity: _selectedZones.isEmpty ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2C2C2E).withOpacity(0.15),
              const Color(0xFF2C2C2E).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2C2C2E).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _selectedZones.isEmpty ? Icons.touch_app : Icons.lightbulb_outline,
              color: const Color(0xFFFF4538),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _selectedZones.isEmpty
                    ? 'Нажми на зоны тела или выбери кнопками ниже'
                    : 'Программа добавит больше упражнений на выбранные области',
                style: TextStyle(
                  color: const Color(0xFFB0B5C0).withOpacity(0.95),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneChips() {
    final visibleZones = _getVisibleZones();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: visibleZones.map((zoneId) {
        final zone = _bodyZones[zoneId]!;
        final isSelected = _selectedZones.contains(zoneId);
        final color = zone['color'] as Color;

        return AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: () => _toggleZone(zoneId),
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [color.withOpacity(0.3), color.withOpacity(0.15)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(zone['icon'] as String, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        zone['title'] as String,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (zone['subtitle'] != null)
                        Text(
                          zone['subtitle'] as String,
                          style: TextStyle(
                            color: const Color(0xFFB0B5C0).withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingButton() {
    final canContinue = _selectedZones.isNotEmpty;

    return AnimatedSlide(
      offset: canContinue ? Offset.zero : const Offset(0, 2),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: canContinue ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canContinue
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrainingLocationScreen(),
                          ),
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Продолжить',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0B5C0).withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 25.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
