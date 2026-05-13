import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class VolumeMeter extends StatelessWidget {
  const VolumeMeter({super.key, required this.level, this.barCount = 16});
  final double level;
  final int barCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barCount, (i) {
          final threshold = (i + 1) / barCount;
          final on = level >= threshold * 0.6;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: on ? 16 + level * 100 * (threshold + 0.2) : 8,
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.surfaceInset,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
