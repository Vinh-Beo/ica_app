import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ThemeState;
import '../constants.dart';

/// Compact pill toggle: ☀️ sáng / 🌙 tối / 🌗 theo máy
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeState>().mode;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.p.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeBtn(mode: ThemeMode.light, icon: Icons.light_mode_rounded, current: mode),
          _ThemeBtn(mode: ThemeMode.dark, icon: Icons.dark_mode_rounded, current: mode),
          _ThemeBtn(mode: ThemeMode.system, icon: Icons.brightness_auto_rounded, current: mode),
        ],
      ),
    );
  }
}

class _ThemeBtn extends StatelessWidget {
  final ThemeMode mode, current;
  final IconData icon;
  const _ThemeBtn({required this.mode, required this.icon, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = mode == current;
    return GestureDetector(
      onTap: () => context.read<ThemeState>().setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: active ? context.p.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
              : [],
        ),
        child: Icon(icon, size: 16, color: active ? context.p.navy : context.p.textMuted),
      ),
    );
  }
}
