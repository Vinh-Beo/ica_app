import 'package:flutter/material.dart';

class AppGradient {
  static const gradientPrimary = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF562D),
        Color(0xFFFF562D),
      ]);

  static const gradientAppBar = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF562D), Color(0xFFFF562D), Color(0xFFFF8061)]);

  static final gradientComponent = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white.withAlpha(0), const Color(0xFF5468E7)]);
}
