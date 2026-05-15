import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NextBroadcastCard extends StatelessWidget {
  const NextBroadcastCard({
    super.key,
    required this.prayerName,
    required this.at,
  });

  final String prayerName;
  final DateTime at;

  String _countdownStr() {
    final diff = at.difference(DateTime.now());
    if (diff.isNegative) return 'starting soon';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0) return '$h hr ${m.abs()} min';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.goldHighlight],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT BROADCAST',
                  style: AppTextStyles.labelCaps(color: AppColors.onPrimaryFixed)
                      .copyWith(fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  prayerName,
                  style: AppTextStyles.headlineMd(color: AppColors.onPrimaryFixed)
                      .copyWith(fontSize: 22, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  'in ${_countdownStr()}',
                  style: AppTextStyles.bodyMd(
                    color: AppColors.onPrimaryFixed.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // CTA pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onPrimaryFixed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Go Live now',
                  style: AppTextStyles.labelCaps(color: Colors.white)
                      .copyWith(fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Symbols.chevron_right, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
