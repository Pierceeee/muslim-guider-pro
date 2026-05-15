import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.trailingIcon,
    this.trailingIconColor,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;
  final Color? trailingIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelCaps(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.headlineMd(color: AppColors.inkPrimary)
                      .copyWith(fontSize: 18, height: 1.2),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  size: 16,
                  color: trailingIconColor ?? AppColors.inkPrimary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
