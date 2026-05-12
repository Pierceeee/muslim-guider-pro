import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Reusable "gold-bordered glass card" — the recurring container shape from
/// the prototype (rounded-[21px] cards on the dashboard, nearby list, masjid
/// detail, broadcaster dashboard, etc.).
///
/// Centralised here so visual tuning lives in one place — bump the gold
/// border opacity or the corner radius once and every card updates.
class GoldGlowCard extends StatelessWidget {
  const GoldGlowCard({
    required this.child,
    this.padding,
    this.borderOpacity = 0.10,
    this.color,
    this.onTap,
    this.borderRadius,
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Inner padding. Defaults to [AppSpacing.cardInner] (16 px all sides).
  final EdgeInsetsGeometry? padding;

  /// Border alpha as a fraction of [AppColors.primary] (0 to 1).
  /// Prototype values seen: 0.05 (subtle), 0.10 (default), 0.20 (emphasised).
  final double borderOpacity;

  /// Background color. Defaults to [AppColors.surfaceCard].
  final Color? color;

  /// Optional tap handler. When supplied, the card renders Material splash +
  /// ripple feedback over the existing decoration so tapping feels registered.
  final VoidCallback? onTap;

  /// Override the corner rounding. Defaults to the prototype's `rounded-[21px]`.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadii.heroAll;
    final bg = color ?? AppColors.surfaceCard;
    final decoration = BoxDecoration(
      color: bg,
      borderRadius: radius,
      border: Border.all(
        color: AppColors.primary.withValues(alpha: borderOpacity),
      ),
    );
    final inner = Container(
      padding: padding ?? AppSpacing.cardInner,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return inner;

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: padding ?? AppSpacing.cardInner,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: borderOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
