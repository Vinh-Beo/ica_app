import 'package:flutter/material.dart';

class WHeaderText extends StatelessWidget {
  const WHeaderText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      )
    );
  }
}