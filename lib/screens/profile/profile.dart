import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/models/ProfileModel.dart';
import 'package:startap/providers/profile_provider.dart';
import 'package:startap/screens/auth/login_screen.dart';
import 'inventory_screen.dart';
import 'context_json_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _goal = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null && !provider.isLoading) {
        await provider.load();
        _syncFromProvider();
      } else {
        _syncFromProvider();
      }
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _goal.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _syncFromProvider() {
    final p = context.read<ProfileProvider>().profile;
    if (p == null) return;

    _firstName.text = p.firstName;
    _lastName.text = p.lastName;
    _email.text = p.email;
    _goal.text = p.goalText;
    _height.text = p.heightCm?.toStringAsFixed(0) ?? '';
    _weight.text = p.weightKg?.toStringAsFixed(1) ?? '';
    _birthDate = p.birthDate;

    if (mounted) setState(() {});
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 20, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00D9FF),
              onPrimary: Color(0xFF0A0E21),
              surface: Color(0xFF1D1E33),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  double? _tryParseDouble(String text) {
    final t = text.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<void> _save() async {
    final provider = context.read<ProfileProvider>();
    final p = provider.profile;
    if (p == null) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final next = p.copyWith(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      birthDate: _birthDate,
      goalText: _goal.text.trim(),
      heightCm: _tryParseDouble(_height.text),
      weightKg: _tryParseDouble(_weight.text),
    );

    await provider.save(next);

    if (!mounted) return;
    final err = provider.error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err == null ? '✅ Профиль обновлен' : '❌ Ошибка: $err'),
        backgroundColor: err == null ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.profile == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0E21),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF00D9FF)),
              ),
            ),
          );
        }

        final p = provider.profile;
        if (p == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E21),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1D1E33),
              title: const Text('Профиль'),
            ),
            body: Center(
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : () async => provider.load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  foregroundColor: const Color(0xFF0A0E21),
                ),
                child: const Text('Загрузить профиль'),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          body: CustomScrollView(
            slivers: [
              // ПРЕМИУМ APP BAR
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0A0E21),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6C5CE7),
                          const Color(0xFF00D9FF).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
                            ),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D9FF).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${p.firstName} ${p.lastName}'.trim().isEmpty
                              ? 'Мой профиль'
                              : '${p.firstName} ${p.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                actions: [
                                  IconButton(
                  tooltip: 'Выход',
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          // 1. Выполняем выход в провайдере
                          await provider.logout();
                          
                          if (!context.mounted) return;

                          // 2. 🔥 ПЕРЕХОД НА ЛОГИН С ОЧИСТКОЙ ИСТОРИИ
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false, // Это условие удаляет все предыдущие экраны
                          );
                        },
                  icon: const Icon(Icons.logout_rounded),
                ),

                ],
              ),

              // КОНТЕНТ
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ЛИЧНЫЕ ДАННЫЕ
                        _PremiumSectionTitle('👤 Личные данные'),
                        const SizedBox(height: 12),
                        _PremiumCard(
                          child: Column(
                            children: [
                              _PremiumTextField(
                                controller: _firstName,
                                label: 'Имя',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _PremiumTextField(
                                controller: _lastName,
                                label: 'Фамилия',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _PremiumTextField(
                                controller: _email,
                                label: 'Почта',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _pickBirthDate,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: const Color(0xFF00D9FF),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Дата рождения',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatDate(_birthDate).isEmpty
                                                  ? 'Не указана'
                                                  : _formatDate(_birthDate),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // АНТРОПОМЕТРИЯ
                        _PremiumSectionTitle('📏 Антропометрия'),
                        const SizedBox(height: 12),
                        _PremiumCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: _PremiumTextField(
                                  controller: _height,
                                  label: 'Рост (см)',
                                  icon: Icons.height_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _PremiumTextField(
                                  controller: _weight,
                                  label: 'Вес (кг)',
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ЦЕЛЬ
                        _PremiumSectionTitle('🎯 Цель'),
                        const SizedBox(height: 12),
                        _PremiumCard(
                          child: _PremiumTextField(
                            controller: _goal,
                            label: 'Например: Набрать 90 кг',
                            icon: Icons.flag_rounded,
                            maxLines: 2,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ОГРАНИЧЕНИЯ
                        _PremiumSectionTitle('🩺 Ограничения и травмы'),
                        const SizedBox(height: 12),
                        _PremiumCard(child: _InjuriesEditor()),

                        const SizedBox(height: 24),

                        // НАВИГАЦИОННЫЕ КАРТОЧКИ
                        _PremiumSectionTitle('⚙️ Настройки'),
                        const SizedBox(height: 12),
                        
                        _NavigationCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Мой инвентарь',
                          subtitle: 'Активный пресет: ${equipmentPresetTitle(p.preset)}',
                          trailing: '${p.equipmentEnabled.length} шт',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const InventoryScreen()),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _NavigationCard(
                          icon: Icons.code_rounded,
                          title: 'Контекст для AI',
                          subtitle: 'Редактор JSON',
                          trailing: '${p.aiContext.length} ключей',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ContextJsonScreen()),
                          ),
                        ),

                        const SizedBox(height: 12),
                        
                        _NavigationCard(
                          icon: Icons.star_rounded,
                          title: 'Подписка',
                          subtitle: 'Управление подпиской',
                          trailing: 'Pro',
                          onTap: provider.isLoading
                              ? null
                              : () async {
                                  await provider.api.updateSubscriptionStub();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Открыть paywall позже'),
                                      backgroundColor: Color(0xFF6C5CE7),
                                    ),
                                  );
                                },
                        ),

                        const SizedBox(height: 32),

                        // КНОПКА СОХРАНЕНИЯ
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9FF),
                              foregroundColor: const Color(0xFF0A0E21),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Color(0xFF0A0E21)),
                                    ),
                                  )
                                : const Text(
                                    'Обновить данные',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ПРЕМИУМ КОМПОНЕНТЫ

class _PremiumSectionTitle extends StatelessWidget {
  final String text;
  const _PremiumSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFF00D9FF), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2),
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF252B41).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D9FF).withOpacity(0.2),
                        const Color(0xFF6C5CE7).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFF00D9FF), size: 24),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trailing,
                        style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF00D9FF),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InjuriesEditor extends StatefulWidget {
  @override
  State<_InjuriesEditor> createState() => _InjuriesEditorState();
}

class _InjuriesEditorState extends State<_InjuriesEditor> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final p = provider.profile!;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Например: сломал ногу, астма',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final text = _ctrl.text;
                        _ctrl.clear();
                        await provider.addInjury(text);
                      },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (p.injuries.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Пока пусто',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < p.injuries.length; i++)
                Chip(
                  label: Text(p.injuries[i]),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: provider.isLoading ? null : () => provider.removeInjuryAt(i),
                  backgroundColor: Colors.red.withOpacity(0.15),
                  labelStyle: const TextStyle(color: Colors.red),
                  deleteIconColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
