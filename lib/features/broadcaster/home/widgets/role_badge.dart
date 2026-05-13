import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.masjidName});
  final String masjidName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cell_tower, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('MUADHIN', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: AppColors.inkMuted)),
          const SizedBox(width: 6),
          Text(masjidName,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}
