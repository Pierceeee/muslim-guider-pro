import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MicLevelMeter extends StatelessWidget {
  const MicLevelMeter({
    super.key,
    required this.level0to1,
    this.barCount = 24,
    this.showDbReadout = true,
  });

  final double level0to1;
  final int barCount;
  final bool showDbReadout;

  double get _dbReadout {
    final clamped = level0to1.clamp(0.001, 1.0);
    // approximate linear-to-dB mapping for visualisation only
    return 20 * (1 - clamped) * -1;
  }

  @override
  Widget build(BuildContext context) {
    final lit = (level0to1.clamp(0, 1) * barCount).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MIC INPUT LEVEL',
                style: AppTextStyles.labelCaps(color: AppColors.inkMuted)),
            if (showDbReadout)
              Text('${_dbReadout.toStringAsFixed(0)} dB',
                  style: AppTextStyles.numeralTime(
                      fontSize: 12, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 16,
          child: Row(
            children: [
              for (var i = 0; i < barCount; i++) ...[
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: i < lit
                          ? (i < barCount * 0.75
                              ? AppColors.primary
                              : (i < barCount * 0.9
                                  ? AppColors.warningAmber
                                  : AppColors.liveRed))
                          : Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                if (i != barCount - 1) const SizedBox(width: 2),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
