import 'package:flutter/material.dart';

class WImage extends StatelessWidget {
  const WImage({super.key, this.size, this.url});

  final double? size;
  final String? url;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(
            url ?? '',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}