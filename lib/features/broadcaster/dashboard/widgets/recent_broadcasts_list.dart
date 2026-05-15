import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/broadcast_stream.dart';

class RecentBroadcastsList extends StatelessWidget {
  const RecentBroadcastsList({super.key, required this.entries});
  final List<BroadcastStream> entries;

  /// Derive a single uppercase letter from the broadcast start hour.
  /// Maps to the closest canonical prayer name letter.
  String _prayerLetter(DateTime startedAt) {
    final h = startedAt.hour;
    if (h >= 4 && h < 7) return 'F';   // Fajr
    if (h >= 12 && h < 14) return 'D'; // Dhuhr
    if (h >= 15 && h < 18) return 'A'; // Asr
    if (h >= 18 && h < 21) return 'M'; // Maghrib
    if (h >= 21 || h < 2) return 'I';  // Isha
    return 'D'; // fallback
  }

  /// Format duration as mm:ss (used as the right-side badge value).
  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Format relative time label for the subtitle.
  String _formatRelativeTime(DateTime startedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(startedAt);
  }

  Widget _buildRow(BuildContext context, BroadcastStream e) {
    final letter = _prayerLetter(e.startedAt);
    final timeLabel = DateFormat('HH:mm').format(e.startedAt);
    final relDay = _formatRelativeTime(e.startedAt);
    final durationLabel = _formatDuration(e.duration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar: 44×44 circle with goldDeep→primary gradient + letter
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldDeep, AppColors.primary],
              ),
            ),
            child: Center(
              child: Text(
                letter,
                style: AppTextStyles.headlineMd(color: Colors.white)
                    .copyWith(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Middle column: time label + listener subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$relDay · $timeLabel',
                  style: AppTextStyles.bodyLg(color: AppColors.inkPrimary),
                ),
                Text(
                  '${e.peakListenerCount} listeners',
                  style: AppTextStyles.bodyMd(color: AppColors.inkMuted)
                      .copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Duration badge (right side)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              durationLabel,
              style: AppTextStyles.numeralTime(
                      fontSize: 12, color: AppColors.primary)
                  .copyWith(letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No recent broadcasts',
          style: AppTextStyles.bodyMd(color: AppColors.inkMuted),
        ),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _buildRow(context, entries[i]),
          if (i < entries.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
