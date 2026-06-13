import 'package:flutter/material.dart';

/// Colored icon in a rounded container — replaces emoji throughout the app.
class AppIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? bg;
  final double size;
  final double iconSize;
  final double? radius;

  const AppIcon({
    super.key,
    required this.icon,
    required this.color,
    this.bg,
    this.size = 42,
    this.iconSize = 20,
    this.radius,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: bg ?? color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius ?? size * 0.30),
    ),
    child: Center(child: Icon(icon, color: color, size: iconSize)),
  );
}
