import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/nutrition_provider.dart';
import 'package:startap/widgets/appnar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:startap/services/photo_service.dart';


class NutritionDashboard extends StatefulWidget {
  const NutritionDashboard({Key? key}) : super(key: key);

  @override
  State<NutritionDashboard> createState() => _NutritionDashboardState();
}

class _NutritionDashboardState extends State<NutritionDashboard> {
  bool _isInitialized = false;

  int caloriesMax = 2400;
  int proteinMax = 153;
  int fatMax = 68;
  int carbMax = 205;

  int waterGoal = 2000;
  int waterCurrent = 0;

  final Map<String, List<Map<String, dynamic>>> _mealGroups = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
  };

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
void initState() {
  super.initState();
  _isInitialized = true;
  _loadFromCache();
}
  Future<void> _loadFromCache() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().split('T')[0];
  final cachedDate = prefs.getString('nutrition_date') ?? '';

  if (cachedDate != today) {
    // Новый день — чистим
    await prefs.remove('nutrition_meals');
    await prefs.remove('nutrition_water');
    await prefs.setString('nutrition_date', today);
    setState(() {
      _mealGroups['breakfast'] = [];
      _mealGroups['lunch'] = [];
      _mealGroups['dinner'] = [];
      waterCurrent = 0;
    });
    return;
  }

  final mealsRaw = prefs.getString('nutrition_meals');
  final water = prefs.getInt('nutrition_water') ?? 0;

  if (mealsRaw != null) {
    try {
      final decoded = jsonDecode(mealsRaw) as Map<String, dynamic>;
      setState(() {
        _mealGroups['breakfast'] = (decoded['breakfast'] as List)
            .cast<Map<String, dynamic>>();
        _mealGroups['lunch'] = (decoded['lunch'] as List)
            .cast<Map<String, dynamic>>();
        _mealGroups['dinner'] = (decoded['dinner'] as List)
            .cast<Map<String, dynamic>>();
        waterCurrent = water;
      });
    } catch (_) {}
  }
}

Future<void> _saveToCache() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().split('T')[0];
  await prefs.setString('nutrition_date', today);
  await prefs.setString('nutrition_meals', jsonEncode(_mealGroups));
  await prefs.setInt('nutrition_water', waterCurrent);
}
  List<Map<String, dynamic>> get _allMeals =>
      [..._mealGroups['breakfast']!, ..._mealGroups['lunch']!, ..._mealGroups['dinner']!];

  int get _totalCalories =>
      _allMeals.fold(0, (s, m) => s + ((m['calories'] as num?)?.toInt() ?? 0));
  int get _totalProtein =>
      _allMeals.fold(0, (s, m) => s + ((m['protein'] as num?)?.toInt() ?? 0));
  int get _totalFat =>
      _allMeals.fold(0, (s, m) => s + ((m['fat'] as num?)?.toInt() ?? 0));
  int get _totalCarb =>
      _allMeals.fold(0, (s, m) => s + ((m['carb'] as num?)?.toInt() ?? 0));
  int get _caloriesLeft => (caloriesMax - _totalCalories).clamp(0, caloriesMax);

  void _addWater(int ml) {
  setState(() {
    waterCurrent = (waterCurrent + ml).clamp(0, waterGoal * 3);
  });
  _saveToCache(); // ← сохраняем
}

  void _changeWaterGoal() {
    final c = TextEditingController(text: waterGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💧 Установить цель по воде',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
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
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Отмена',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      final v = int.tryParse(c.text) ?? waterGoal;
                      setState(() => waterGoal = v.clamp(500, 6000));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Сохранить',
                        style: TextStyle(color: Color(0xFF0A0E21), fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _addToMeal(String mealType, Map<String, dynamic> entry) {
  setState(() {
    _mealGroups[mealType]!.insert(0, Map<String, dynamic>.from(entry));
  });
  _saveToCache(); // ← сохраняем
}

  String _getMealTypeByTime(TimeOfDay t) {
    if (t.hour >= 5 && t.hour < 12) return 'breakfast';
    if (t.hour >= 12 && t.hour < 17) return 'lunch';
    return 'dinner';
  }

  void _addManual({required String mealType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: _ManualInputModal(
            onSubmit: (text) async {
              Navigator.pop(ctx);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFF4538)),
                  ),
                ),
              );

              final provider = context.read<NutritionProvider>();
              final result = await provider.analyzeFood(text);

              if (context.mounted) Navigator.pop(context);

              if (result != null && context.mounted) {
                final now = TimeOfDay.now();
                final entry = {
                  'name':     result['meal_name'] ?? text,
                  'desc':     result['ai_message'] ?? '',
                  'calories': (result['calories'] as num?)?.toInt() ?? 0,
                  'protein':  double.tryParse(result['protein']?.toString() ?? '0')?.toInt() ?? 0,
                  'fat':      double.tryParse(result['fats']?.toString() ?? '0')?.toInt() ?? 0,
                  'carb':     double.tryParse(result['carbs']?.toString() ?? '0')?.toInt() ?? 0,
                  'dt': '${now.hour}:${now.minute.toString().padLeft(2, '0')}', // ← строка вместо объекта
                  'emoji':    '🍽️',
                  'mealType': mealType,
                };


                await showDialog(
                  context: context,
                  builder: (dialogCtx) => FoodConfirmDialog(
                    analysis: entry,
                    onSave: (e) {
                      _addToMeal(mealType, e);
                      provider.addMeal(result);
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handlePhoto(ImageSource src, {required String mealType}) async {
  final image = await _picker.pickImage(
    source: src,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 70,
  );
  if (image == null) return;

  final imageFile = File(image.path);
  setState(() => _selectedImage = imageFile);

  // Показать загрузку
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFFFF4538)),
      ),
    ),
  );

  // Отправить фото на API
  final result = await PhotoService.analyzePhoto(imageFile);

  if (context.mounted) Navigator.pop(context); // убрать загрузку

  if (result != null && context.mounted) {
    final now = TimeOfDay.now();
    final entry = {
      'name': result['meal_name'] ?? 'Блюдо',
      'desc': result['ai_message'] ?? '',
      'calories': (result['calories'] as num?)?.toInt() ?? 0,
      'protein': (result['protein'] as num?)?.toInt() ?? 0,
      'fat': (result['fats'] as num?)?.toInt() ?? 0,
      'carb': (result['carbs'] as num?)?.toInt() ?? 0,
      'dt': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'emoji': '📸',
      'mealType': mealType,
    };

    await showDialog(
      context: context,
      builder: (dialogCtx) => FoodConfirmDialog(
        analysis: entry,
        image: imageFile,
        onSave: (e) {
          _addToMeal(mealType, e);
          final provider = context.read<NutritionProvider>();
          provider.addMeal(result);
        },
      ),
    );
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Не удалось распознать блюдо. Попробуйте ещё раз.'),
        backgroundColor: Color(0xFFFF4538),
      ),
    );
  }

  setState(() => _selectedImage = null);
}


  Future<void> _showAddForMeal(String mealType) async {
    final input = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              _PremiumTileButton(
                icon: Icons.edit_rounded,
                color: Colors.amber,
                label: 'Ввести вручную',
                subtitle: 'AI посчитает калории по тексту',
                onTap: () => Navigator.pop(ctx, 'manual'),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (input == 'manual') _addManual(mealType: mealType);
    if (input == 'camera') await _handlePhoto(ImageSource.camera, mealType: mealType);
    if (input == 'gallery') await _handlePhoto(ImageSource.gallery, mealType: mealType);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1C1E),
        body: Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFFF4538)))),
      );
    }

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
                  const SizedBox(height: 20),
                  _MainCard(
                    caloriesLeft: _caloriesLeft,
                    caloriesMax: caloriesMax,
                    protein: _totalProtein,
                    proteinMax: proteinMax,
                    fat: _totalFat,
                    fatMax: fatMax,
                    carb: _totalCarb,
                    carbMax: carbMax,
                    waterGoal: waterGoal,
                    waterCurrent: waterCurrent,
                    onAddWater: _addWater,
                    onChangeGoal: _changeWaterGoal,
                  ),
                  const SizedBox(height: 16),
                  _WaterIntakeCard(
                    waterCurrent: waterCurrent,
                    waterGoal: waterGoal,
                    onAddWater: () => showWaterDialog(context, _addWater),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Дневник питания',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5)),
                        Text('${_allMeals.length} блюд',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5), fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _MealSection(
                    mealType: 'breakfast',
                    label: 'Завтрак',
                    emoji: '🍳',
                    items: _mealGroups['breakfast']!,
                    onAdd: () => _showAddForMeal('breakfast'),
                  ),
                  const SizedBox(height: 12),
                  _MealSection(
                    mealType: 'lunch',
                    label: 'Обед',
                    emoji: '🍽️',
                    items: _mealGroups['lunch']!,
                    onAdd: () => _showAddForMeal('lunch'),
                  ),
                  const SizedBox(height: 12),
                  _MealSection(
                    mealType: 'dinner',
                    label: 'Ужин',
                    emoji: '🍴',
                    items: _mealGroups['dinner']!,
                    onAdd: () => _showAddForMeal('dinner'),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String mealType;
  final String label;
  final String emoji;
  final List<Map<String, dynamic>> items;
  final VoidCallback onAdd;

  const _MealSection({
    required this.mealType,
    required this.label,
    required this.emoji,
    required this.items,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories =
        items.fold<int>(0, (s, m) => s + ((m['calories'] as num?)?.toInt() ?? 0));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
                if (items.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4538).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFF4538).withOpacity(0.3)),
                    ),
                    child: Text('$totalCalories ккал',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 8),
                
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4538),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      color: Colors.white.withOpacity(0.25), size: 16),
                  const SizedBox(width: 8),
                  Text('Нажмите + чтобы добавить',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            )
          else
            ...items.map((item) => _MealItemTile(item: item)),

          if (items.isNotEmpty) const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MealItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MealItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item['emoji'] ?? '🍽️',
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if ((item['desc'] ?? '').toString().isNotEmpty)
                  Text(item['desc'],
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item['calories'] ?? 0}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text('ккал',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

void showWaterDialog(BuildContext context, void Function(int) onAdd) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Добавить воду',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WaterButton(ml: 100, onTap: () { Navigator.pop(ctx); onAdd(100); }),
              _WaterButton(ml: 200, onTap: () { Navigator.pop(ctx); onAdd(200); }),
              _WaterButton(ml: 300, onTap: () { Navigator.pop(ctx); onAdd(300); }),
              _WaterButton(ml: 500, onTap: () { Navigator.pop(ctx); onAdd(500); }),
            ],
          ),
          const SizedBox(height: 8),
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
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF0A84FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0A84FF).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$ml',
                style: const TextStyle(
                    color: Color(0xFF0A84FF),
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const Text('мл',
                style: TextStyle(
                    color: Color(0xFF0A84FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
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
    final liters = (waterCurrent / 1000).toStringAsFixed(1);
    final litersGoal = (waterGoal / 1000).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop, color: Color(0xFF0A84FF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$liters л из $litersGoal л',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Text('$waterCurrent мл',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddWater,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                  color: Color(0xFF0A84FF), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) {
              return Column(
                children: [
                  SizedBox(
                    width: 110, height: 110,
                    child: CircularProgressIndicator(
                      value: val * calProgress,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF64D2FF)),
                      strokeWidth: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('${caloriesMax - caloriesLeft}/$caloriesMax',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('осталось $caloriesLeft',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PremiumMacroBar(label: 'Белки', value: protein, max: proteinMax,
                    color: const Color(0xFF30D158)),
                const SizedBox(height: 12),
                _PremiumMacroBar(label: 'Жиры', value: fat, max: fatMax,
                    color: const Color(0xFFFF9F0A)),
                const SizedBox(height: 12),
                _PremiumMacroBar(label: 'Углеводы', value: carb, max: carbMax,
                    color: const Color(0xFF64D2FF)),
              ],
            ),
          ),
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

  const _PremiumMacroBar(
      {required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    final percent = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
          Text('$value г',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Stack(children: [
          Container(
              height: 6,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            height: 6,
            width: 110 * percent,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
            ),
          ),
        ]),
      ],
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w700, fontSize: 15)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodConfirmDialog extends StatelessWidget {
  final Map<String, dynamic> analysis;
  final Function(Map<String, dynamic>) onSave;
  final File? image;

  const FoodConfirmDialog({
    required this.analysis,
    required this.onSave,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Фото или эмодзи
                if (image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(image!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4538).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(analysis['emoji'] ?? '🍽️',
                          style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(analysis['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: -0.5)),
                if ((analysis['desc'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(analysis['desc'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.5)),
                ],
                const SizedBox(height: 20),
                _analyzeBar(
                    'Калории', analysis['calories'] ?? 0, 600, Colors.deepOrange),
                _analyzeBar(
                    'Белки', analysis['protein'] ?? 0, 40, Colors.pinkAccent),
                _analyzeBar('Жиры', analysis['fat'] ?? 0, 40, Colors.orange),
                _analyzeBar(
                    'Углеводы', analysis['carb'] ?? 0, 70, Colors.lightBlueAccent),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4538),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon:
                        const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text('Добавить',
                        style:
                            TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
    final percent = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 76,
              child: Text(label,
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(
            child: Stack(children: [
              Container(
                  height: 7,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12))),
              Container(
                height: 7,
                width: percent * 120,
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [color, color.withOpacity(0.5)]),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Text('$value',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
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
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(image, height: 140, width: double.infinity,
                      fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Text(analysis['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.white)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4538),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text('Добавить в историю',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('Что ты съел?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Например: Два яйца, тост с авокадо',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFFFF4538), width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4538),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.smart_toy_rounded),
              label: const Text('Обработать',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
