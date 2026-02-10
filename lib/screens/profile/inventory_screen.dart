import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/models/ProfileModel.dart';
import 'package:startap/providers/profile_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final p = provider.profile;
        if (p == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0E21),
            body: Center(
              child: Text(
                'Нет профиля',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1D1E33),
            title: const Text('🏋️ Мой инвентарь'),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ОПИСАНИЕ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D9FF).withOpacity(0.1),
                      const Color(0xFF6C5CE7).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00D9FF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF00D9FF),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Это определяет, какие упражнения AI будет предлагать.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ПРЕСЕТЫ
              const _PremiumBlockTitle('⚡ Пресеты (быстрый выбор)'),
              const SizedBox(height: 12),
              _premiumPresetTile(context, provider, EquipmentPreset.commercialGym),
              const SizedBox(height: 10),
              _premiumPresetTile(context, provider, EquipmentPreset.homeBasic),
              const SizedBox(height: 10),
              _premiumPresetTile(context, provider, EquipmentPreset.noEquipment),

              const SizedBox(height: 24),

              // КАСТОМНЫЕ ПРЕСЕТЫ
              const _PremiumBlockTitle('✨ Кастомные пресеты'),
              const SizedBox(height: 12),
              if (p.customPresets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Пока нет кастомных пресетов',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...p.customPresets.map((cp) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1D1E33),
                          const Color(0xFF252B41).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: provider.isLoading ? null : () => provider.applyCustomPreset(cp.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cp.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Оборудования: ${cp.equipmentEnabled.length}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Удалить',
                                onPressed: provider.isLoading
                                    ? null
                                    : () => provider.deleteCustomPreset(cp.id),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 12),

              // КНОПКА СОЗДАНИЯ
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async => _createCustomPresetDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Создать кастомный пресет'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D9FF),
                    side: const BorderSide(color: Color(0xFF00D9FF), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ЧЕК-ЛИСТ
              const _PremiumBlockTitle('📋 Чек-лист оборудования'),
              const SizedBox(height: 8),
              Text(
                'Можно точечно отключить, например, "Тренажер Смита", если он сломан.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1D1E33),
                      const Color(0xFF252B41).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  children: [
                    ...provider.equipmentCatalog.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final enabled = p.equipmentEnabled.contains(item);
                      final isLast = idx == provider.equipmentCatalog.length - 1;

                      return Column(
                        children: [
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            value: enabled,
                            activeColor: const Color(0xFF00D9FF),
                            onChanged: provider.isLoading
                                ? null
                                : (v) => provider.toggleEquipment(item, v),
                          ),
                          if (!isLast)
                            Divider(
                              color: Colors.white.withOpacity(0.05),
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ✅ КНОПКА ДОБАВИТЬ СВОЙ ИНВЕНТАРЬ
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _addCustomEquipmentDialog(context),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text('Добавить свой инвентарь'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6C5CE7),
                    side: BorderSide(
                      color: const Color(0xFF6C5CE7).withOpacity(0.5),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // СЧЕТЧИК
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D9FF).withOpacity(0.15),
                        const Color(0xFF6C5CE7).withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Активно: ${p.equipmentEnabled.length} / ${provider.equipmentCatalog.length}',
                    style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _premiumPresetTile(
    BuildContext context,
    ProfileProvider provider,
    EquipmentPreset preset,
  ) {
    final p = provider.profile!;
    final selected = p.preset == preset;

    return Container(
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1D1E33),
                  const Color(0xFF252B41).withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? const Color(0xFF00D9FF)
              : Colors.white.withOpacity(0.08),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: provider.isLoading ? null : () => provider.setPreset(preset),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: selected ? Colors.white : const Color(0xFF00D9FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipmentPresetTitle(preset),
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Оборудования: ${provider.presetEquipment(preset).length}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ДИАЛОГ ДОБАВЛЕНИЯ СВОЕГО ИНВЕНТАРЯ
  Future<void> _addCustomEquipmentDialog(BuildContext context) async {
  final provider = context.read<ProfileProvider>();

  await showDialog(
    context: context,
    builder: (ctx) {
      return _AddEquipmentDialog(provider: provider, parentContext: context);
    },
  );
}


  Future<void> _createCustomPresetDialog(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final p = provider.profile!;
    final nameCtrl = TextEditingController(text: 'Дом + штанга');
    final selected = Set<String>.from(p.equipmentEnabled);

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF1D1E33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Новый кастомный пресет',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Название',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Оборудование',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: provider.equipmentCatalog.map((item) {
                              final v = selected.contains(item);
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  item,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                value: v,
                                activeColor: const Color(0xFF00D9FF),
                                onChanged: (nv) {
                                  setState(() {
                                    if (nv == true) {
                                      selected.add(item);
                                    } else {
                                      selected.remove(item);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Отмена'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      await provider.createCustomPreset(
                                        name: nameCtrl.text.trim().isEmpty
                                            ? 'Custom preset'
                                            : nameCtrl.text.trim(),
                                        equipment: selected,
                                      );
                                      if (ctx.mounted) Navigator.of(ctx).pop();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D9FF),
                                foregroundColor: const Color(0xFF0A0E21),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Создать',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
  }
}

class _PremiumBlockTitle extends StatelessWidget {
  final String text;
  const _PremiumBlockTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}
class _AddEquipmentDialog extends StatefulWidget {
  final ProfileProvider provider;
  final BuildContext parentContext;

  const _AddEquipmentDialog({
    required this.provider,
    required this.parentContext,
  });

  @override
  State<_AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<_AddEquipmentDialog> {
  late final TextEditingController equipmentCtrl;

  @override
  void initState() {
    super.initState();
    equipmentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    equipmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Добавить инвентарь',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Введите название оборудования',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: equipmentCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Например: Гимнастические кольца',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00D9FF),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = equipmentCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('Введите название'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Закрываем диалог
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      // Добавляем оборудование
                      await widget.provider.addCustomEquipment(name);

                      // Показываем успешное уведомление с задержкой
                      await Future.delayed(const Duration(milliseconds: 150));
                      if (widget.parentContext.mounted) {
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          SnackBar(
                            content: Text('✅ "$name" добавлен'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: const Color(0xFF0A0E21),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Добавить',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
