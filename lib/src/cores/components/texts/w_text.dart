import 'package:flutter/material.dart';

class WText extends StatelessWidget {
  const WText({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
        textAlign: TextAlign.start,
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
    );
  }
}