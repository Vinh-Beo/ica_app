import 'package:flutter/material.dart';

class WRoundButton extends StatelessWidget {
      WRoundButton(
      {Key? key, this.color,this.name})
      : super(key: key);

  final Color? color;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {}, // Also use the passed onPressed
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
        ),
        child: Text( // ✅ Remove 'const'
          name ?? '', // Add null safety handling
          style: const TextStyle( // TextStyle can still be const
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      );
  }
}