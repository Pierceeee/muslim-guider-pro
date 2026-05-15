import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.masjidName, this.role = 'MUADHIN'});
  final String masjidName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.40)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.cell_tower, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$role · ${masjidName.toUpperCase()}',
            style: AppTextStyles.labelCaps(color: AppColors.primary).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
