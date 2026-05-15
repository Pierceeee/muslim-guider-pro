import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BgPattern extends StatelessWidget {
  const BgPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.04,
        child: SvgPicture.asset(
          'assets/svg/back_texture.svg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
