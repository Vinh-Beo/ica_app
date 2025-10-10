import 'package:flutter/material.dart';

class WNormalText extends StatelessWidget {
  const WNormalText({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      )
    );
  }
}