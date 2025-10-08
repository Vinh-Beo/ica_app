import 'package:flutter/material.dart';

class WTextIcon extends StatelessWidget {
  const WTextIcon({super.key, required this.badge});
  
  final String badge;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(                
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        badge,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}