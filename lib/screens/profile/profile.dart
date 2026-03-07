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


  Future<void> _editGoal() async {
    if (!mounted) return;
    final provider = context.read<ProfileProvider>();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        title: 'Цель',
        initialValue: _goal.text,
        hint: 'Например: Набрать 90 кг',
      ),
    );
    
    if (!mounted || result == null || result.isEmpty) return;
    
    _goal.text = result;
    final p = provider.profile!;
    await provider.save(p.copyWith(goalText: result));
  }



  Future<void> _editHeight() async {
    if (!mounted) return;
    final provider = context.read<ProfileProvider>();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        title: 'Рост (см)',
        initialValue: _height.text,
        hint: 'Например: 180',
        keyboardType: TextInputType.number,
      ),
    );
    
    if (!mounted || result == null || result.isEmpty) return;
    
    _height.text = result;
    final p = provider.profile!;
    await provider.save(p.copyWith(heightCm: double.tryParse(result)));
  }


  Future<void> _editWeight() async {
    if (!mounted) return;
    final provider = context.read<ProfileProvider>();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        title: 'Вес (кг)',
        initialValue: _weight.text,
        hint: 'Например: 75.5',
        keyboardType: TextInputType.number,
      ),
    );
    
    if (!mounted || result == null || result.isEmpty) return;
    
    _weight.text = result;
    final p = provider.profile!;
    await provider.save(p.copyWith(weightKg: double.tryParse(result.replaceAll(',', '.'))));
  }

  Future<void> _editInjuries() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _InjuriesScreen(),
      ),
    );
  }


  


  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.profile == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF1C1C1E),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700)),
              ),
            ),
          );
        }


        final p = provider.profile;
        if (p == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1C1C1E),
            appBar: AppBar(
              backgroundColor: const Color(0xFF2C2C2E),
              title: const Text('Профиль'),
            ),
            body: Center(
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : () async => provider.load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF1C1C1E),
                ),
                child: const Text('Загрузить профиль'),
              ),
            ),
          );
        }


        return Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          body: CustomScrollView(
            slivers: [
              // КОМПАКТНЫЙ APP BAR
              SliverAppBar(
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1C1C1E),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'Профиль',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            await provider.logout();
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
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
                        // ПРОФИЛЬ КАРТОЧКА
                        _ProfileCard(
                          firstName: p.firstName.isEmpty ? 'Александр' : p.firstName,
                          lastName: p.lastName.isEmpty ? '' : p.lastName,
                          subtitle: '💎 PRO SUBSCRIBER',
                          onEdit: () {},
                        ),


                        const SizedBox(height: 16),


                        // БЫСТРЫЕ ДЕЙСТВИЯ
                        _SectionTitle('ОБСЛЕДОВАНИЕ + ПЛАН'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.home_rounded,
                                label: 'ДОМ',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.fitness_center_rounded,
                                label: 'ЗАЛ',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.water_drop_rounded,
                                label: 'ДИЕТА',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.add_rounded,
                                label: 'CUSTOM',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 24),


                        // ИНВЕНТАРЬ
                        _SectionTitle('ТЕЛО И ЦЕЛИ'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.fitness_center_rounded,
                          title: 'ДОСТУПНЫЙ ПРЕСЕТ',
                          subtitle: equipmentPresetTitle(p.preset),
                          trailing: '',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const InventoryScreen()),
                          ),
                        ),


                        const SizedBox(height: 24),


                        // АНТРОПОМЕТРИЯ
                        _SectionTitle('АНТРОПОМЕТРИЯ'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.flag_rounded,
                          title: 'Цель',
                          trailing: p.goalText.isEmpty ? 'Не указана' : p.goalText,
                          onTap: _editGoal,
                        ),
                        const SizedBox(height: 8),
                        _MenuItem(
                          icon: Icons.height_rounded,
                          title: 'Рост',
                          trailing: p.heightCm == null ? 'Не указан' : '${p.heightCm!.toInt()} см',
                          onTap: _editHeight,
                        ),
                        const SizedBox(height: 8),
                        _MenuItem(
                          icon: Icons.monitor_weight_outlined,
                          title: 'Вес',
                          trailing: p.weightKg == null ? 'Не указан' : '${p.weightKg!.toStringAsFixed(1)} кг',
                          onTap: _editWeight,
                        ),


                        const SizedBox(height: 24),


                        // ТРАВМЫ И ОГРАНИЧЕНИЯ
                        _SectionTitle('ТРАВМЫ И ОГРАНИЧЕНИЯ'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.warning_rounded,
                          iconColor: const Color(0xFFFF4538),
                          title: 'Травмы и Ограничения',
                          trailing: p.injuries.isEmpty ? 'ОПИСАТЬ' : '${p.injuries.length} шт',
                          trailingColor: const Color(0xFFFF4538),
                          onTap: _editInjuries,
                        ),


                        const SizedBox(height: 24),


                        // AI КОНТЕКСТ
                        _SectionTitle('AI CONTEXT'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.memory_rounded,
                          title: 'AI Context',
                          trailing: 'Digital Twin',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ContextJsonScreen()),
                          ),
                        ),


                        const SizedBox(height: 24),


                        // НАСТРОЙКИ
                        _SectionTitle('НАСТРОЙКИ'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.shopping_bag_rounded,
                          title: 'Подписка',
                          trailing: 'Актив',
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Уведомления',
                          trailing: '',
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        _MenuItem(
                          icon: Icons.language_rounded,
                          title: 'Язык',
                          trailing: 'Русский',
                          onTap: () {},
                        ),


                        const SizedBox(height: 32),


                        // КНОПКА ВЫХОДА
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    await provider.logout();
                                    if (!context.mounted) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFFF4538), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '🔥 ВЫЙТИ ИЗ АККАУНТА',
                              style: TextStyle(
                                color: Color(0xFFFF4538),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),


                        const SizedBox(height: 16),


                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'УДАЛИТЬ БАЗУ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
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


// КОМПОНЕНТЫ


class _ProfileCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String subtitle;
  final VoidCallback onEdit;


  const _ProfileCard({
    required this.firstName,
    required this.lastName,
    required this.subtitle,
    required this.onEdit,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName'.trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);


  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}


class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;


  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String trailing;
  final Color? trailingColor;
  final VoidCallback onTap;


  const _MenuItem({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.trailingColor,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailing,
                  style: TextStyle(
                    color: trailingColor ?? Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


class _EditDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String hint;
  final TextInputType? keyboardType;


  const _EditDialog({
    required this.title,
    required this.initialValue,
    required this.hint,
    this.keyboardType,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
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
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Отмена',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}



// ЭКРАН РЕДАКТИРОВАНИЯ ТРАВМ
class _InjuriesScreen extends StatefulWidget {
  const _InjuriesScreen();


  @override
  State<_InjuriesScreen> createState() => _InjuriesScreenState();
}


class _InjuriesScreenState extends State<_InjuriesScreen> {
  final _ctrl = TextEditingController();


  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final p = provider.profile!;
        
        return Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2C2C2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Травмы и Ограничения',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Например: сломал ногу, астма',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final text = _ctrl.text.trim();
                                if (text.isEmpty) return;
                                _ctrl.clear();
                                await provider.addInjury(text);
                              },
                        icon: const Icon(Icons.add_rounded, color: Color(0xFF1C1C1E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (p.injuries.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Пока пусто',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: p.injuries.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_rounded, color: Color(0xFFFF4538), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p.injuries[i],
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ),
                              IconButton(
                                onPressed: provider.isLoading ? null : () => provider.removeInjuryAt(i),
                                icon: const Icon(Icons.close_rounded, color: Color(0xFFFF4538), size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
