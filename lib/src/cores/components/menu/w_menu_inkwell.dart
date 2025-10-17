import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/components/texts/w_normal_text.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';

Widget wMenuInkwell(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? AppColors.colorRed : AppColors.colorPurple,
          ),
          const SizedBox(width: 12),
          Expanded(  // ✅ Thêm Expanded
            child: WNormalText(
              text: label, 
              color: isDestructive ? AppColors.colorRed : AppColors.colorIconLight
            ),
          ),

        ],
      ),
    ),
  );
}