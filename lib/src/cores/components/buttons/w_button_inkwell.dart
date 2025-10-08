import 'package:flutter/material.dart';

class WButtonInkwell extends StatelessWidget {
  const WButtonInkwell(
      {Key? key,
      this.splashColor,
      this.onPressed,
      this.borderRadius,
      this.child})
      : super(key: key);

  final Color? splashColor;
  final Widget? child;
  final Function()? onPressed;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red,
      child: InkWell(
        highlightColor: splashColor,
        borderRadius: borderRadius,
        splashColor: splashColor,
        onTap: onPressed,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
