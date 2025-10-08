import 'package:flutter/material.dart';

class WIcon extends StatelessWidget {

  final String icon; 
  const WIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Text(
      icon,
      style: const TextStyle(fontSize: 24),
    ));
  }
}