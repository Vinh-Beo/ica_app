import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/widgets/annotated_scaffold.dart';
import 'package:ica_app/src/onboarding/widgets/onboarding_body_widget.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedScaffold(child: OnBoardingBodyWidget());
  }
}
