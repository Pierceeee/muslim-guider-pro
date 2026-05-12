import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Shared placeholder rendered by every broadcaster screen until F5 fills in
/// the real layouts that match the corresponding prototype HTML files.
///
/// Shows the screen's identity (slug + sub-feature) and the in-progress
/// status so the app remains navigable even though broadcaster work is
/// deferred until after the listener side ships.
class BroadcasterComingSoon extends StatelessWidget {
  const BroadcasterComingSoon({
    required this.slug,
    required this.title,
    required this.subFeature,
    super.key,
  });

  /// Matches the prototype HTML filename (no `.html`).
  final String slug;

  /// Human title from `prototype/index.html`.
  final String title;

  /// Broadcaster sub-feature folder name (e.g. "dashboard", "live").
  final String subFeature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      appBar: AppBar(
        title: Text(title, style: AppTypography.headlineMd),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.sectionGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: AppSpacing.cardInner,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: AppRadii.heroAll,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Symbols.podcasts_rounded,
                          color: AppColors.primary,
                          size: 22,
                          fill: 1,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BROADCASTER · ${subFeature.toUpperCase()}',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'prototype/screens/$slug.html',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.inkMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'F5 placeholder — broadcaster flow is built after the '
                      'listener side ships. Per build plan §5.1.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
