import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GoldGlowCard extends StatelessWidget {
  const GoldGlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
