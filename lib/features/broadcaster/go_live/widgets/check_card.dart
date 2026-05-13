import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gold_glow_card.dart';
import '../go_live_controller.dart';

class CheckCard extends StatelessWidget {
  const CheckCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    this.onRetry,
  });

  final String title;
  final String subtitle;
  final CheckStatus status;
  final IconData icon;
  final VoidCallback? onRetry;

  Color _statusColor() {
    switch (status) {
      case CheckStatus.idle:
        return AppColors.inkSubtle;
      case CheckStatus.checking:
        return AppColors.warningAmber;
      case CheckStatus.ok:
        return AppColors.successGreen;
      case CheckStatus.failed:
        return AppColors.liveRed;
    }
  }

  Widget _trailing() {
    switch (status) {
      case CheckStatus.checking:
        return const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case CheckStatus.ok:
        return const Icon(Icons.check_circle, color: AppColors.successGreen);
      case CheckStatus.failed:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error, color: AppColors.liveRed),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]);
      case CheckStatus.idle:
        return const Icon(
          Icons.radio_button_unchecked,
          color: AppColors.inkSubtle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoldGlowCard(
      child: Row(
        children: [
          Icon(icon, color: _statusColor()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          _trailing(),
        ],
      ),
    );
  }
}
