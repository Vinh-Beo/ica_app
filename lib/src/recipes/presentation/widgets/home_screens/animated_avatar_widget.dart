// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ica_app/src/cores/constants/assets.dart';

class AnimatedAvatarWidget extends StatelessWidget {
  //final Duration avatarPlayDuration;
  //final Duration avatarWaitingDuration;
  const AnimatedAvatarWidget({
    Key? key,
    //required this.avatarPlayDuration,
    //required this.avatarWaitingDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return CircleAvatar(
    //   radius: 18,
    //   backgroundColor: Colors.blue.shade900,
    //   child: Image.asset(Assets.profileImage),
    // )
    //     .animate()
    //     .scaleXY(begin: 0, end: 2, duration: avatarPlayDuration, curve: Curves.easeInOutSine)
    //     .then(delay: avatarWaitingDuration)
    //     .scaleXY(begin: 3, end: 1)
    //     .slide(begin: const Offset(-3.5, 8), end: Offset.zero);
    return Container();
  }
}
