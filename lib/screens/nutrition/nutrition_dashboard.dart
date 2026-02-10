import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:startap/widgets/appnar.dart';

class NutritionDashboard extends StatefulWidget {
  const NutritionDashboard({Key? key}) : super(key: key);

  @override
  State<NutritionDashboard> createState() => _NutritionDashboardState();
}

class _NutritionDashboardState extends State<NutritionDashboard> {
  late PageController _pageController;
  bool _isInitialized = false;
  
  int caloriesLeft = 2046;
  int caloriesMax = 2400;
  int protein = 0, proteinMax = 153;
  int fat = 0, fatMax = 68;
  int carb = 0, carbMax = 205;
  
  int waterGoal = 2000;
  int waterCurrent = 0;
  
  String _currentDay = 'today';
  int _currentPageIndex = 1;
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
 Map<String, Map<String, Object>> _daysData = {
  'yesterday': {'history': <Map<String, Object>>[], 'water': 0},
  'today': {'history': <Map<String, Object>>[], 'water': 0},
  'tomorrow': {'history': <Map<String, Object>>[], 'water': 0},
};


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _loadSampleData();
    _checkAutoReset();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkAutoReset() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final midnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final timeUntilReset = midnight.difference(now);
    
    Future.delayed(timeUntilReset, () {
      if (mounted) {
        setState(() {
          _daysData['yesterday'] = _daysData['today']!;
          _daysData['today'] = _daysData['tomorrow']!;
          _daysData['tomorrow'] = {'history': [], 'water': 0};
          _currentDay = 'today';
          _currentPageIndex = 1;
          _pageController.jumpToPage(1);
        });
        _checkAutoReset();
      }
    });
  }

  void _loadSampleData() {
    setState(() {
      _daysData['today']!['history'] = [
        {
          'name': 'Гречневая каша',
          'desc': 'С молоком и ягодами',
          'calories': 280,
          'protein': 8,
          'fat': 4,
          'carb': 52,
          'dt': TimeOfDay(hour: 7, minute: 0),
          'emoji': '🍚',
          'mealType': 'breakfast',
        },
        {
          'name': 'Омлет с сыром',
          'desc': 'Омлет из 2 яиц с сыром',
          'calories': 220,
          'protein': 12,
          'fat': 11,
          'carb': 17,
          'dt': TimeOfDay(hour: 8, minute: 30),
          'emoji': '🍳',
          'mealType': 'breakfast',
        },
        {
          'name': 'Куриная грудка',
          'desc': 'Бурый рис, овощи',
          'calories': 450,
          'protein': 45,
          'fat': 8,
          'carb': 35,
          'dt': TimeOfDay(hour: 13, minute: 0),
          'emoji': '🍗',
          'mealType': 'lunch',
        },
        {
          'name': 'Салат Цезарь',
          'desc': 'С курицей и сухариками',
          'calories': 320,
          'protein': 28,
          'fat': 16,
          'carb': 18,
          'dt': TimeOfDay(hour: 13, minute: 30),
          'emoji': '🥗',
          'mealType': 'lunch',
        },
        {
          'name': 'Стейк из рыбы',
          'desc': 'С лимоном и травами',
          'calories': 380,
          'protein': 42,
          'fat': 19,
          'carb': 8,
          'dt': TimeOfDay(hour: 19, minute: 0),
          'emoji': '🐟',
          'mealType': 'dinner',
        },
      ];
      _daysData['today']!['water'] = 800;
      _updateMacros();
    });
  }

  void _updateMacros() {
    final history = _daysData[_currentDay]!['history'] as List;
    protein = history.fold(0, (sum, item) => sum + (item['protein'] as int));
    fat = history.fold(0, (sum, item) => sum + (item['fat'] as int));
    carb = history.fold(0, (sum, item) => sum + (item['carb'] as int));
    int totalCalories = history.fold(0, (sum, item) => sum + (item['calories'] as int));
    caloriesLeft = (caloriesMax - totalCalories).clamp(0, caloriesMax);
    waterCurrent = _daysData[_currentDay]!['water'] as int;
  }

  String _getMealTypeByTime(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return 'breakfast';
    } else if (hour >= 12 && hour < 17) {
      return 'lunch';
    } else {
      return 'dinner';
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
      _currentDay = ['yesterday', 'today', 'tomorrow'][index];
      _updateMacros();
    });
  }

  void _addWater(int ml) {
    setState(() {
      int current = (_daysData[_currentDay]!['water'] as int) + ml;
      _daysData[_currentDay]!['water'] = current.clamp(0, waterGoal * 3);
      waterCurrent = _daysData[_currentDay]!['water'] as int;
    });
  }

  void _changeWaterGoal() {
    final c = TextEditingController(text: waterGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💧 Установить цель по воде',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: c,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'мл',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        final v = int.tryParse(c.text) ?? waterGoal;
                        setState(() => waterGoal = v.clamp(500, 6000));
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(
                          color: Color(0xFF0A0E21),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddMenu() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1D1E33),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 30,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _PremiumTileButton(
                icon: Icons.camera_alt_rounded,
                color: Colors.deepOrange,
                label: 'Посчитать калории по фото',
                subtitle: 'Сканируй блюдо и узнай его калории',
                onTap: () => Navigator.pop(ctx, "tracker"),
              ),
              const SizedBox(height: 16),
              _PremiumTileButton(
                icon: Icons.kitchen_rounded,
                color: Colors.purpleAccent,
                label: 'Что приготовить?',
                subtitle: 'Рецепты из твоего холодильника',
                onTap: () => Navigator.pop(ctx, "fridge"),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == "tracker") _showInputMethodMenu(isFridge: false);
    if (action == "fridge") _showInputMethodMenu(isFridge: true);
  }

  Future<void> _showInputMethodMenu({required bool isFridge}) async {
    final input = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1D1E33),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _PremiumTileButton(
                icon: Icons.camera_alt_rounded,
                color: Colors.deepOrange,
                label: 'Камера',
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              const SizedBox(height: 12),
              _PremiumTileButton(
                icon: Icons.photo_library_rounded,
                color: Colors.blueAccent,
                label: 'Галерея',
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              const SizedBox(height: 12),
              _PremiumTileButton(
                icon: Icons.edit_rounded,
                color: Colors.yellow[700]!,
                label: 'Ввести вручную',
                onTap: () => Navigator.pop(ctx, 'manual'),
              ),
              if (!isFridge) ...[
                const SizedBox(height: 12),
                _PremiumTileButton(
                  icon: Icons.star_rounded,
                  color: Colors.pinkAccent,
                  label: 'Избранное блюдо',
                  onTap: () => Navigator.pop(ctx, 'fav'),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (input == 'camera' || input == 'gallery') {
      ImageSource src = input == 'camera' ? ImageSource.camera : ImageSource.gallery;
      await _handlePhoto(src, isFridge: isFridge);
    } else if (input == "manual") {
      _addManual();
    } else if (input == "fav") {
      _addFav();
    }
  }

  Future<void> _handlePhoto(ImageSource src, {required bool isFridge}) async {
    final image = await _picker.pickImage(source: src);
    if (image == null) return;
    
    setState(() => _selectedImage = File(image.path));
    
    await showDialog(
      context: context,
      builder: (ctx) => FoodAnalyzeDialog(
        image: _selectedImage!,
        scenario: isFridge ? "fridge" : "tracker",
        analysis: isFridge
            ? {
                'name': 'Омлет с сыром',
                'desc': 'Из вашего холодильника можно приготовить 3 блюда. Совет: омлет идеален к завтраку!',
                'calories': 220,
                'protein': 12,
                'fat': 11,
                'carb': 17,
                'dt': TimeOfDay.now(),
                'emoji': '🍳',
              }
            : {
                'name': 'Йогуртовый смузи',
                'desc': 'слегка сладкий смузи с йогуртом',
                'calories': 180,
                'protein': 6,
                'fat': 3,
                'carb': 29,
                'dt': TimeOfDay.now(),
                'emoji': '🥤',
              },
        onSave: _addHistoryEntry,
      ),
    );
    
    setState(() => _selectedImage = null);
  }

  void _addManual() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: _ManualInputModal(
        onSubmit: (text) async {
          Navigator.pop(ctx);
          
          final now = TimeOfDay.now();
          final entry = {
            'name': 'Еда',
            'desc': text,
            'calories': 250,
            'protein': 15,
            'fat': 10,
            'carb': 25,
            'dt': now,
            'emoji': '🍽️',
            'mealType': _getMealTypeByTime(now),
          };
          
          // Показываем диалог подтверждения
          await showDialog(
            context: context,
            builder: (dialogCtx) => FoodConfirmDialog(
              analysis: entry,
              onSave: _addHistoryEntry,
            ),
          );
        },
      ),
    ),
  );
}




  void _addFav() {
    final now = TimeOfDay.now();
    final entry = {
      'name': 'Омлет с ветчиной',
      'desc': 'избранное блюдо',
      'calories': 195,
      'protein': 11,
      'fat': 10,
      'carb': 12,
      'dt': now,
      'emoji': '🍳',
      'mealType': _getMealTypeByTime(now),
    };
    _addHistoryEntry(entry);
  }

  void _addHistoryEntry(Map<String, dynamic> entry) {
  setState(() {
    final history = (_daysData[_currentDay]!['history'] as List);
    history.insert(0, Map<String, Object>.from(entry));
    _updateMacros();
  });
}


  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF00D9FF)),
          ),
        ),
      );
    }

    final hasHistory = (_daysData[_currentDay]!['history'] as List).isNotEmpty;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: CustomScrollView(
        slivers: [
          Appnar.buildModernAppBar(context, "Питание"),
          
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // _SwipeDayNavigation(
                  //   pageController: _pageController,
                  //   currentDay: _currentDay,
                  //   onPageChanged: _onPageChanged,
                  // ),
                  
                  
                  const SizedBox(height: 20),
                  
                  _MainCard(
                    caloriesLeft: caloriesLeft,
                    caloriesMax: caloriesMax,
                    protein: protein,
                    proteinMax: proteinMax,
                    fat: fat,
                    fatMax: fatMax,
                    carb: carb,
                    carbMax: carbMax,
                    waterGoal: waterGoal,
                    waterCurrent: waterCurrent,
                    onAddWater: _addWater,
                    onChangeGoal: _changeWaterGoal,
                  ),
                  
                  const SizedBox(height: 32),
                  _WaterIntakeCard(
                    waterCurrent: waterCurrent,
                    waterGoal: waterGoal,
                    onAddWater: () {
                      // Открыть диалог выбора количества воды
                      showWaterDialog(context);
                    },
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Дневник питания',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(_daysData[_currentDay]!['history'] as List).length} блюд сегодня',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          
          if (hasHistory)
            SliverToBoxAdapter(
              child: _MealsSectionBuilder(
                history: (_daysData[_currentDay]!['history'] as List).cast<Map<String, dynamic>>(),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _EmptyHistoryCard(),
              ),
            ),
          
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 28),
  child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeOutBack,
    builder: (_, val, child) {
      return Transform.scale(scale: val, child: child);
    },
    child: FloatingActionButton(
      backgroundColor: const Color(0xFFFF4538),
      shape: const CircleBorder(), // Изменено на круг
      elevation: 12,
      onPressed: _showAddMenu,
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    ),
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Добавь эту строку в Scaffold

    );
  }
}

// ============ КОМПОНЕНТЫ ============

class _SwipeDayNavigation extends StatefulWidget {
  final PageController pageController;
  final String currentDay;
  final Function(int) onPageChanged;
  
  const _SwipeDayNavigation({
    required this.pageController,
    required this.currentDay,
    required this.onPageChanged,
  });

  @override
  State<_SwipeDayNavigation> createState() => _SwipeDayNavigationState();
}

class _SwipeDayNavigationState extends State<_SwipeDayNavigation> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: widget.pageController,
        onPageChanged: widget.onPageChanged,
        itemCount: 2,
        itemBuilder: (context, index) {
          final days = ['← Вчера', 'СЕГОДНЯ'];
          final dayNames = ['yesterday', 'today', 'tomorrow'];
          final isActive = widget.currentDay == dayNames[index];

          return Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isActive ? 1 : 0.7),
              duration: const Duration(milliseconds: 300),
              builder: (_, scale, __) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF00D9FF).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: isActive
                          ? Border.all(
                              color: const Color(0xFF00D9FF).withOpacity(0.4),
                              width: 2,
                            )
                          : Border.all(color: Colors.transparent),
                      // ✅ УМЕНЬШЕННЫЕ ТЕНИ
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D9FF).withOpacity(0.08), // было 0.2
                                blurRadius: 8, // было 16
                                spreadRadius: 0, // было 2
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? const Color(0xFF00D9FF) : Colors.white.withOpacity(0.4),
                        letterSpacing: isActive ? 1.2 : 0,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}





class _WaterIntakeCard extends StatelessWidget {
  final int waterCurrent;
  final int waterGoal;
  final VoidCallback onAddWater;

  const _WaterIntakeCard({
    required this.waterCurrent,
    required this.waterGoal,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final waterProgress = (waterCurrent / waterGoal).clamp(0.0, 1.0);
    final liters = (waterCurrent / 1000).toStringAsFixed(1);
    final litersGoal = (waterGoal / 1000).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          // Иконка воды
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Color(0xFF0A84FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$liters л из $litersGoal л',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$waterCurrent мл',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Кнопка +
          GestureDetector(
            onTap: onAddWater,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF0A84FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
void showWaterDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Добавить воду',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WaterButton(ml: 100, onTap: () {
                Navigator.pop(context);
                // Добавить 100 мл
              }),
              _WaterButton(ml: 200, onTap: () {
                Navigator.pop(context);
                // Добавить 200 мл
              }),
              _WaterButton(ml: 300, onTap: () {
                Navigator.pop(context);
                // Добавить 300 мл
              }),
            ],
          ),
        ],
      ),
    ),
  );
}
class _WaterButton extends StatelessWidget {
  final int ml;
  final VoidCallback onTap;

  const _WaterButton({required this.ml, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0A84FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0A84FF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$ml',
              style: const TextStyle(
                color: Color(0xFF0A84FF),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'мл',
              style: TextStyle(
                color: Color(0xFF0A84FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _MainCard extends StatelessWidget {
  final int caloriesLeft, caloriesMax, protein, proteinMax, fat, fatMax, carb, carbMax;
  final int waterGoal, waterCurrent;
  final void Function(int ml) onAddWater;
  final VoidCallback onChangeGoal;

  const _MainCard({
    required this.caloriesLeft,
    required this.caloriesMax,
    required this.protein,
    required this.proteinMax,
    required this.fat,
    required this.fatMax,
    required this.carb,
    required this.carbMax,
    required this.waterGoal,
    required this.waterCurrent,
    required this.onAddWater,
    required this.onChangeGoal,
  });

  @override
  Widget build(BuildContext context) {
    
    final calProgress = (caloriesLeft / caloriesMax).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
      color: const Color(0xFF2C2C2E), // Изменено здесь
      borderRadius: BorderRadius.circular(28),
    ),
      child: Column(
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) {
                  return Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: val * calProgress,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF64D2FF)),
                          strokeWidth: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          Text(
                            '${caloriesMax - caloriesLeft}/${caloriesMax}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'осталось $caloriesLeft',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PremiumMacroBar(
                      label: 'Белки',
                      value: protein,
                      max: proteinMax,
                      color: Color(0xFF30D158),
                    ),
                    const SizedBox(height: 12),
                    _PremiumMacroBar(
                      label: 'Жиры',
                      value: fat,
                      max: fatMax,
                      color: Color(0xFFFF9F0A)
                    ),
                    const SizedBox(height: 12),
                    _PremiumMacroBar(
                      label: 'Углеводы',
                      value: carb,
                      max: carbMax,
                      color: Color(0xFF64D2FF)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
        ],
      ),
    );
  }
}

class _PremiumMacroBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _PremiumMacroBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$value г',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              height: 6,
              width: 110 * percent,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WaterChip extends StatelessWidget {
  final int ml;
  final VoidCallback onTap;

  const _WaterChip({required this.ml, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.1),
                  const Color(0xFF0099CC).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D9FF).withOpacity(0.3),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                '+${ml}',
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealsSectionBuilder extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const _MealsSectionBuilder({required this.history});

  Map<String, List<Map<String, dynamic>>> _groupByMealType() {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
    };

    for (var item in history) {
      final mealType = item['mealType'] as String? ?? 'breakfast';
      if (grouped.containsKey(mealType)) {
        grouped[mealType]!.add(item);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByMealType();
    
    final mealData = {
      'breakfast': {'label': 'Завтрак', 'icon': '', 'emoji': '🍳'},
      'lunch': {'label': 'Обед', 'icon': '', 'emoji': '🍽️'},
      'dinner': {'label': 'Ужин', 'icon': '', 'emoji': '🍴'},
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          ...['breakfast', 'lunch', 'dinner'].map((mealType) {
            final items = grouped[mealType] ?? [];
            final data = mealData[mealType];
            final firstMealTime = items.isNotEmpty ? items.first['dt'] as TimeOfDay : null;
            
            return _MealCard(
              mealType: mealType,
              label: data!['label'] as String,
              icon: data['icon'] as String,
              items: items,
              mealTime: firstMealTime,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String mealType;
  final String label;
  final String icon;
  final List<Map<String, dynamic>> items;
  final TimeOfDay? mealTime;

  const _MealCard({
    required this.mealType,
    required this.label,
    required this.icon,
    required this.items,
    required this.mealTime,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = items.fold<int>(0, (sum, item) => sum + (item['calories'] as int? ?? 0));
    final mealNames = items.map((item) => item['name'] as String? ?? 'блюдо').join(', ');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C2C2E),
            const Color(0xFF2C2C2E).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Левая линия
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C3E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с иконкой и время
                  Row(
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (mealTime != null)
                              Text(
                                mealTime!.format(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (items.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64D2FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF64D2FF).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '$totalCalories ккал',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64D2FF),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Текст с блюдами через запятую или уведомление
                  if (items.isEmpty)
                    Text(
                      'Нажмите +, чтобы добавить',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Text(
                      mealNames,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodHistoryCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const FoodHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final TimeOfDay dt = entry['dt'] as TimeOfDay? ?? TimeOfDay.now();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C2C2E),
            const Color(0xFF2C2C2E)
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Text(
                entry['emoji'] ?? '🍽️',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  entry['desc'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _macroTag('П', entry['protein'], Colors.pinkAccent),
                    const SizedBox(width: 6),
                    _macroTag('Ж', entry['fat'], Colors.deepOrangeAccent),
                    const SizedBox(width: 6),
                    _macroTag('У', entry['carb'], Colors.lightBlueAccent),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry['calories']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'ккал',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dt.format(context),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroTag(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '🍽️',
            style: TextStyle(fontSize: 48, height: 0.8),
          ),
          const SizedBox(height: 20),
          const Text(
            'Пока ничего нет',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавь свой первый приём пищи,\nчтобы начать отслеживание',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumTileButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _PremiumTileButton({
    required this.icon,
    required this.color,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodAnalyzeDialog extends StatelessWidget {
  final File image;
  final String scenario;
  final Map<String, dynamic> analysis;
  final Function(Map<String, dynamic>) onSave;

  const FoodAnalyzeDialog({
    required this.image,
    required this.scenario,
    required this.analysis,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1D1E33),
              const Color(0xFF252B41),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  analysis['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (analysis['desc'] != null)
                  Text(
                    analysis['desc'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 24),
                _analyzeBar('Калории', analysis['calories'], 600, Colors.deepOrange),
                _analyzeBar('Белки', analysis['protein'], 40, Colors.pinkAccent),
                _analyzeBar('Жиры', analysis['fat'], 40, Colors.orange),
                _analyzeBar('Углеводы', analysis['carb'], 70, Colors.lightBlueAccent),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: const Color(0xFF0A0E21),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text(
                      'Добавить в историю',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    onPressed: () {
                      onSave(analysis);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _analyzeBar(String label, int value, int max, Color color) {
    double percent = (value / max).clamp(0, 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  height: 8,
                  width: percent * 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualInputModal extends StatefulWidget {
  final Function(String) onSubmit;

  const _ManualInputModal({required this.onSubmit});

  @override
  State<_ManualInputModal> createState() => _ManualInputModalState();
}

class _ManualInputModalState extends State<_ManualInputModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Что ты съел?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Например: Два яйца, тост с авокадо и латте',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF6C5CE7),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.smart_toy_rounded),
              label: const Text(
                'Обработать',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onSubmit(_controller.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
class FoodConfirmDialog extends StatelessWidget {
  final Map<String, dynamic> analysis;
  final Function(Map<String, dynamic>) onSave;

  const FoodConfirmDialog({
    required this.analysis,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1D1E33),
              Color(0xFF252B41),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка вместо изображения
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7),
                        const Color(0xFF6C5CE7).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      analysis['emoji'] ?? '🍽️',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  analysis['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (analysis['desc'] != null)
                  Text(
                    analysis['desc'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 24),
                _analyzeBar('Калории', analysis['calories'], 600, Colors.deepOrange),
                _analyzeBar('Белки', analysis['protein'], 40, Colors.pinkAccent),
                _analyzeBar('Жиры', analysis['fat'], 40, Colors.orange),
                _analyzeBar('Углеводы', analysis['carb'], 70, Colors.lightBlueAccent),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: const Color(0xFF0A0E21),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text(
                      'Добавить в историю',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    onPressed: () {
                      onSave(analysis);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _analyzeBar(String label, int value, int max, Color color) {
    double percent = (value / max).clamp(0, 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  height: 8,
                  width: percent * 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
