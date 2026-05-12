import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Shared placeholder rendered by every listener screen until F4 fills in
/// the real layout that matches the corresponding `prototype/screens/<slug>.html`.
///
/// The widget shows the screen's identity (slug + category), an optional
/// context line (e.g. extracted path params), and a quick-jump list to every
/// other listener route — so the F0 build is a complete navigation harness
/// even before any real screen exists.
class ListenerPlaceholder extends StatelessWidget {
  const ListenerPlaceholder({
    required this.slug,
    required this.title,
    this.contextLabel,
    super.key,
  });

  /// Matches the prototype HTML filename (no `.html`).
  final String slug;

  /// Human title from `prototype/index.html`.
  final String title;

  /// Optional extra context line (e.g. extracted path params).
  final String? contextLabel;

  static const _allRoutes = <_RouteSummary>[
    _RouteSummary('Dashboard (Listener)', ListenerRoute.nameHomeListener),
    _RouteSummary('Prayer Widget Home', ListenerRoute.nameHomePrayerWidget),
    _RouteSummary('Nearby Masjids', ListenerRoute.nameNearbyMasjids),
    _RouteSummary('Search Results', ListenerRoute.nameSearchResults),
    _RouteSummary('Masjid Detail', ListenerRoute.nameMasjidDetail),
    _RouteSummary('Live Player', ListenerRoute.nameLivePlayer),
    _RouteSummary('Replay Player', ListenerRoute.nameReplayPlayer),
    _RouteSummary('Stream Ended', ListenerRoute.nameStreamEnded),
    _RouteSummary('Stream Reconnecting', ListenerRoute.nameStreamReconnecting),
    _RouteSummary('Prayer Schedule', ListenerRoute.namePrayerSchedule),
    _RouteSummary('Inbox', ListenerRoute.nameInbox),
    _RouteSummary('Profile', ListenerRoute.nameProfile),
    _RouteSummary('Settings', ListenerRoute.nameSettings),
    _RouteSummary('Smart TV Pairing', ListenerRoute.nameSmartTvPairing),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTypography.headlineMd),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.gutter,
            AppSpacing.containerMargin,
            AppSpacing.containerMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _MetaCard(slug: slug, contextLabel: contextLabel),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('JUMP TO', style: AppTypography.labelCaps),
              const SizedBox(height: AppSpacing.gutter * 0.75),
              Expanded(
                child: ListView.separated(
                  itemCount: _allRoutes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final route = _allRoutes[index];
                    final state = GoRouterState.of(context);
                    final isCurrent = route.routeName == (state.name ?? '');
                    return _RouteTile(
                      label: route.label,
                      isCurrent: isCurrent,
                      onTap: isCurrent
                          ? null
                          : () => _navigate(context, route.routeName),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String routeName) {
    final pathParams = switch (routeName) {
      ListenerRoute.nameMasjidDetail => const {'masjidId': 'masjid-al-abrar'},
      ListenerRoute.nameLivePlayer ||
      ListenerRoute.nameReplayPlayer => const {'streamId': 'demo-stream'},
      _ => const <String, String>{},
    };
    context.goNamed(routeName, pathParameters: pathParams);
  }
}

class _RouteSummary {
  const _RouteSummary(this.label, this.routeName);
  final String label;
  final String routeName;
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.slug, required this.contextLabel});
  final String slug;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'LISTENER',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'prototype/screens/$slug.html',
            style: AppTypography.bodySm.copyWith(
              fontFamily: 'monospace',
              color: AppColors.inkMuted,
            ),
          ),
          if (contextLabel != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              contextLabel!,
              style: AppTypography.bodySm.copyWith(
                fontFamily: 'monospace',
                color: AppColors.inkMuted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'F0 placeholder. Real screen lands in F4.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });
  final String label;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: isCurrent
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.surfaceCard,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.inkMuted.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    color: disabled ? AppColors.inkMuted : AppColors.onSurface,
                  ),
                ),
              ),
              if (!isCurrent)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.inkMuted.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

