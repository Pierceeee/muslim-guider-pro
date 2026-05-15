import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PreCheckItem {
  const PreCheckItem({required this.label, required this.statusLabel, this.passed = true});
  final String label;
  final String statusLabel;
  final bool passed;
}

class PreCheckList extends StatelessWidget {
  const PreCheckList({super.key, required this.items});
  final List<PreCheckItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final i in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  i.passed ? Symbols.check_circle_rounded : Symbols.cancel_rounded,
                  color: i.passed ? AppColors.primary : AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(i.label, style: AppTextStyles.bodyMd())),
                Text(
                  i.statusLabel,
                  style: AppTextStyles.bodyMd(color: AppColors.inkMuted).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
