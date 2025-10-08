import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final VoidCallback onTap;
  //final Colors color;

  const Button({super.key, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
          color:  Color(0xFFFFEBEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Color(0xFFE57373),
          size: 20,
        ),
      ),
    );
  }
}