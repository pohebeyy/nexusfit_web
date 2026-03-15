import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/providers/profile_provider.dart';

class ContextJsonScreen extends StatefulWidget {
  const ContextJsonScreen({super.key});

  @override
  State<ContextJsonScreen> createState() => _ContextJsonScreenState();
}

class _ContextJsonScreenState extends State<ContextJsonScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>().profile;
      if (p != null) _ctrl.text = p.toPrettyJson();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final p = provider.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Основной фон приложения
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E), // Фон AppBar как в профиле
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Контекст (JSON)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4538), Color(0xFFFF6B35)], // Ваш фирменный градиент
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4538).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Сохранить',
              onPressed: provider.isLoading || p == null
                  ? null
                  : () async {
                      try {
                        await provider.updateAiContextFromJson(_ctrl.text);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Контекст сохранен',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: const Color(0xFF2C2C2E),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFFFF4538), width: 1),
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Ошибка JSON: $e',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: const Color(0xFF2C2C2E),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.red, width: 1),
                            ),
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E), // Фон карточек в вашем приложении
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _ctrl,
            maxLines: null,
            
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Color(0xFFFFFFFF), // Золотой/желтый цвет, который используется у вас для акцентов
              fontSize: 13,
              height: 1.5,
            ),
            decoration: InputDecoration(
              labelText: 'JSON Контекст для AI',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ),
    );
  }
}
