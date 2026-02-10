import 'package:flutter/material.dart';

class AdaptationSheet extends StatefulWidget {
  const AdaptationSheet({super.key});

  @override
  State<AdaptationSheet> createState() => _AdaptationSheetState();
}

class _AdaptationSheetState extends State<AdaptationSheet> {
  final Map<String, bool> _options = {
    'Болит спина / шея': false,
    'Болит колено / голеностоп': false,
    'Болит плечо / рука': false,
    'Не выспался (мало сна)': false,
    'Вялость / низкая энергия': false,
    'Мало времени (у меня <30 мин)': false,
    'Нет инвентаря / оборудования': false,
    'Очень устал (переутомление)': false,
  };

  final TextEditingController _customController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInsets),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Какие у тебя обстоятельства?',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._options.keys.map((k) {
                        return CheckboxListTile(
                          value: _options[k],
                          onChanged: (v) => setState(() => _options[k] = v ?? false),
                          title: Text(k, style: const TextStyle(color: Colors.white)),
                          activeColor: const Color(0xFF6C5CE7),
                          checkColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Напиши свой вариант',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF111325),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isApplying)
                Row(
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Идёт адаптация плана под твои обстоятельства...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('ПРИМЕНИТЬ АДАПТАЦИЮ', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ОТМЕНИТЬ', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onApply() async {
    setState(() => _isApplying = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isApplying = false);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Адаптация применена', style: TextStyle(color: Colors.white)),
          content: const Text(
            'План тренировки обновлён. Карточки сна, питания и активности пересчитаны.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('ОК', style: TextStyle(color: Color(0xFF6C5CE7))),
            ),
          ],
        );
      },
    );
  }
}