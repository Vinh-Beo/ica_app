import 'package:flutter/material.dart';

class WDescriptionText extends StatelessWidget {
  const WDescriptionText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      )
    );
  }
}