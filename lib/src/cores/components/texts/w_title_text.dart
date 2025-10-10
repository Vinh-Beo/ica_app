import 'package:flutter/material.dart';

class WTitleText extends StatelessWidget {
  WTitleText({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      )
    );
  }
}
