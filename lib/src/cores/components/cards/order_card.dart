// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ica_app/src/cores/components/buttons/w_round_button.dart';
import 'package:ica_app/src/cores/components/icons/w_icon.dart';
import 'package:ica_app/src/cores/components/icons/w_text_icon.dart';
import 'package:ica_app/src/cores/components/images/w_image.dart';
import 'package:ica_app/src/cores/components/texts/W_Text.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';
import 'package:ica_app/src/models/order_model.dart';

class OrderCard
{

  // Color getStatusColor() {
  //   switch (status) {
  //     case OrderStatus.delivered:
  //       return Colors.green;
  //     case OrderStatus.inProgress:
  //       return Colors.orange;
  //     case OrderStatus.cancelled:
  //       return Colors.red;
  //   }
  // }


  

  

  // String getStatusText() {
  //   switch (status) {
  //     case OrderStatus.delivered:
  //       return 'Delivered';
  //     case OrderStatus.inProgress:
  //       return 'In Progress';
  //     case OrderStatus.cancelled:
  //       return 'Cancelled';
  //   }
  // }
}

Widget orderCard({
    required String time,
    required int cusId,
    required String cusName,
    required String content,
    required String icon,
    required Color color,
    required String delivery_time,
    required OrderStatus status,
    bool isSecondary = false,
  }) {
   return Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Expanded(child: Column(children: [Row(
                  children: [
                    // Estate Image
                    const WImage(size: 60,url: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400'),
                    const SizedBox(width: 16),
                    // Estate Info
                    WText(text: cusName),
                    const SizedBox(width: 2),
                    // Edit Icon
                    WRoundButton(color: AppColors.colorLightGreen,name: 'deliveried')
                  ],
                ),
                const SizedBox(width: 16),
                WText(text: content),
                ],
              )),
            );
  }

  