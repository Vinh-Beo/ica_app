import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show LangState;
import '../constants.dart';

/// Compact flag toggle button: 🇻🇳 ↔ 🇬🇧
class LangSwitcher extends StatelessWidget {
  const LangSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LangState>();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.p.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangBtn(code: 'vi', flag: '🇻🇳', current: state.langCode),
          _LangBtn(code: 'en', flag: '🇬🇧', current: state.langCode),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String code, flag, current;
  const _LangBtn({required this.code, required this.flag, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = code == current;
    return GestureDetector(
      onTap: () => context.read<LangState>().setLocale(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? context.p.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
              : [],
        ),
        child: Text(flag, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
