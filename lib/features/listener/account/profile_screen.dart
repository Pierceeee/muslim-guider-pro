import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_stats.dart';
import '../../../data/providers/listener_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/profile.html` — the listener's account
/// landing surface.
///
/// Data: `ensureSignedInUserProvider` + `userStatsProvider`. The 7-pillar
/// ecosystem list reflects the build-plan reservation: only "Live Athan"
/// is Active; the rest are "Soon" placeholders until those pillars ship.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(ensureSignedInUserProvider).valueOrNull;
    final statsAsync = ref.watch(userStatsProvider);
    final displayName = user?.displayName ?? 'Welcome';
    final initial = displayName.isEmpty ? '?' : displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: <Widget>[
                _HeroBanner(onBack: () => _back(context)),
                Transform.translate(
                  offset: const Offset(0, -37),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerMargin,
                    ),
                    child: _IdentityHeader(
                      initial: initial,
                      // Prototype uses "Abdullah Rahman" — we have just
                      // "Abdullah" in the mock; show what we've got.
                      name: displayName,
                      isVerified: true,
                      roleLabel: 'Listener · Muadhin',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.sectionGap),
                      _QuickStats(asyncStats: statsAsync),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _EcosystemSection(
                        onComingSoon: (label) =>
                            _comingSoon(context, label),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _AccountSettingsButton(
                        onTap: () =>
                            context.goNamed(ListenerRoute.nameSettings),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.nameProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameHomeListener);
    }
  }

  void _comingSoon(BuildContext context, String pillarLabel) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            '$pillarLabel is in a later Mawaqit phase — '
            'your data is already reserved.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner (140px gradient + dome pattern + back button)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.purpleDeep,
                    AppColors.bgDeepNight,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 80,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            top: 8,
            left: AppSpacing.containerMargin,
            child: Material(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: AppRadii.fullAll,
              child: InkWell(
                onTap: onBack,
                borderRadius: AppRadii.fullAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.fullAll,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Symbols.arrow_back_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Back',
                        style: AppTypography.bodyMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity header — square gold avatar + name + chips
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.initial,
    required this.name,
    required this.isVerified,
    required this.roleLabel,
  });
  final String initial;
  final String name;
  final bool isVerified;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadii.heroAll,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.primary,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: AppTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    if (isVerified) const _VerifiedChip(),
                    _RoleChip(label: roleLabel),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2F1A),
        borderRadius: AppRadii.fullAll,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Symbols.shield_rounded,
            color: AppColors.primary,
            size: 12,
            fill: 1,
          ),
          const SizedBox(width: 4),
          Text(
            'VERIFIED',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: AppRadii.fullAll,
        border: Border.all(
          color: AppColors.inkPrimary.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps.copyWith(
          color: AppColors.inkMuted,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick stats grid
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.asyncStats});
  final AsyncValue<UserStats> asyncStats;

  @override
  Widget build(BuildContext context) {
    final s = asyncStats.valueOrNull;
    final tile = (String label, String value, {bool gold = false}) =>
        _StatTile(label: label, value: value, valueGold: gold);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: tile(
                'BROADCASTS HEARD',
                s == null ? '—' : '${s.broadcastsHeard}',
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: tile(
                'MASJIDS VERIFIED',
                s == null ? '—' : '${s.masjidsVerified}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gutter),
        Row(
          children: <Widget>[
            Expanded(
              child: _TazkiyaTile(score: s?.tazkiyaScore),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: tile(
                'MEMBER SINCE',
                s == null ? '—' : '${s.memberSinceYear}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.valueGold = false,
  });
  final String label;
  final String value;
  final bool valueGold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.inkMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              color: valueGold ? AppColors.primary : Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _TazkiyaTile extends StatelessWidget {
  const _TazkiyaTile({required this.score});
  final int? score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TAZKIYA SCORE',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.inkMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                score == null ? '—' : '$score',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
              if (score != null) ...<Widget>[
                const SizedBox(width: 4),
                Text(
                  '/100',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.inkMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ecosystem section (7-pillar reservation, 4 shown)
// ─────────────────────────────────────────────────────────────────────────────

class _EcosystemSection extends StatelessWidget {
  const _EcosystemSection({required this.onComingSoon});
  final void Function(String pillarLabel) onComingSoon;

  static const _pillars = <_PillarRow>[
    _PillarRow(
      icon: Symbols.podcasts_rounded,
      label: 'Live Athan',
      sub: 'Phase 1 · Active',
      status: _PillarStatus.linked,
    ),
    _PillarRow(
      icon: Symbols.verified_user_rounded,
      label: 'Tazkiya',
      sub: 'Trust scoring · Coming soon',
      status: _PillarStatus.soon,
    ),
    _PillarRow(
      icon: Symbols.account_tree_rounded,
      label: 'AnsApp',
      sub: 'Family tree · Coming soon',
      status: _PillarStatus.soon,
    ),
    _PillarRow(
      icon: Symbols.storefront_rounded,
      label: 'LocalMotion',
      sub: 'Business directory · Coming soon',
      status: _PillarStatus.soon,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Your ecosystem',
          style: AppTypography.headlineMd.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'One account across all 7 Mawaqit pillars.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.inkMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _pillars.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          _PillarTile(
            row: _pillars[i],
            onTap: () {
              if (_pillars[i].status == _PillarStatus.soon) {
                onComingSoon(_pillars[i].label);
              }
            },
          ),
        ],
      ],
    );
  }
}

enum _PillarStatus { linked, soon }

class _PillarRow {
  const _PillarRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.status,
  });
  final IconData icon;
  final String label;
  final String sub;
  final _PillarStatus status;
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({required this.row, required this.onTap});
  final _PillarRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLinked = row.status == _PillarStatus.linked;
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.heroAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.heroAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Opacity(
          opacity: isLinked ? 1 : 0.8,
          child: Container(
            padding: AppSpacing.cardInner,
            decoration: BoxDecoration(
              borderRadius: AppRadii.heroAll,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLinked
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceInset,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    row.icon,
                    color: isLinked
                        ? AppColors.primary
                        : AppColors.inkMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        row.label,
                        style: AppTypography.bodyLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.sub,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.inkMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLinked
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceInset,
                    borderRadius: AppRadii.fullAll,
                  ),
                  child: Text(
                    isLinked ? 'LINKED' : 'SOON',
                    style: AppTypography.labelCaps.copyWith(
                      color: isLinked
                          ? AppColors.primary
                          : AppColors.inkMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account settings button
// ─────────────────────────────────────────────────────────────────────────────

class _AccountSettingsButton extends StatelessWidget {
  const _AccountSettingsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Account settings',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
