import 'package:flutter/widgets.dart';

Widget buildRowLeftRightText(String left, String right, {TextStyle? leftStyle, TextStyle? rightStyle, Widget? wRight}) {
  return Row(
    children: [
      Expanded(
          child: Text(
        left,
        style: leftStyle,
      )),
      wRight ??
          Text(
            right,
            style: rightStyle,
          )
    ],
  );}