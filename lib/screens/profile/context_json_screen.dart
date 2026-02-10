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
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('💻 Контекст (JSON)'),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
              ),
              borderRadius: BorderRadius.circular(12),
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
                          const SnackBar(
                            content: Text('✅ Контекст сохранен'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Ошибка JSON: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.save_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
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
            ),
          ),
          child: TextField(
            controller: _ctrl,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Color(0xFF00D9FF),
              fontSize: 13,
            ),
            decoration: InputDecoration(
              labelText: 'JSON Контекст для AI',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
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
