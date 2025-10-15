import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/components/icons/w_icon.dart';
import 'package:ica_app/src/cores/components/texts/w_text.dart';

Widget debtCard({
     required String time,
    required int cusId,
    required String cusName,
    required String content,
    required String icon,
    required Color color,
    bool isSecondary = false,
  }) {
    return Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [Row(children: [WIcon(icon: icon),
                const SizedBox(width: 8),
                Expanded(child: WText(text: cusName)),
                const SizedBox(width: 8),
                //WText(text: debt_total)
                // Product Image
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.asset(
                      'assets/coffee.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],),
            const SizedBox(height: 8),
           WText(text: content)],));
  }

  Widget buildPartOfTicket(Widget child, {BorderRadiusGeometry? borderRadius, double spreadRadius = 8}) {
  return Container(
    margin: const EdgeInsets.only(left: 16, right: 16),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.2),
          spreadRadius: spreadRadius,
          blurRadius: 8,
          offset: const Offset(0, 8), // changes position of shadow
        ),
      ],
    ),
    child: child,
  );
}