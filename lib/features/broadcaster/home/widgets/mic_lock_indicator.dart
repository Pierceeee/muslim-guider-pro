import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MicLockIndicator extends StatelessWidget {
  const MicLockIndicator({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colour = active ? AppColors.liveRed : AppColors.primary;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colour, width: 2),
        color: AppColors.surfaceInset,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? Icons.mic : Icons.mic_none, color: colour, size: 18),
          Text(active ? 'LIVE' : 'IDLE',
              style: TextStyle(color: colour, fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }
}
