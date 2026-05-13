import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/masjid.dart';
import '../../../data/providers/listener_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/nearby-masjids.html`.
///
/// Data: `nearbyMasjidsProvider` — Phase B will swap in `geoflutterfire_plus`
/// queries against Firestore; this screen never sees that.
///
/// The masjid tile icon + colour come from a deterministic palette keyed by
/// masjid id, so we don't need a presentation-layer field on the model. When
/// real hero photos are wired up (assets/images), tiles become photos and
/// the palette becomes a fallback.
class NearbyMasjidsScreen extends ConsumerStatefulWidget {
  const NearbyMasjidsScreen({super.key});

  @override
  ConsumerState<NearbyMasjidsScreen> createState() =>
      _NearbyMasjidsScreenState();
}

class _NearbyMasjidsScreenState extends ConsumerState<NearbyMasjidsScreen> {
  _ViewMode _mode = _ViewMode.list;

  @override
  Widget build(BuildContext context) {
    final nearbyAsync = ref.watch(nearbyMasjidsForDiscoveryProvider);
    final user = ref.watch(ensureSignedInUserProvider).valueOrNull;
    final initial = (user?.displayName.isNotEmpty ?? false)
        ? user!.displayName.substring(0, 1).toUpperCase()
        : '?';

    void goToMasjid(String id) => context.goNamed(
          ListenerRoute.nameMasjidDetail,
          pathParameters: <String, String>{'masjidId': id},
        );

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: <Widget>[
                _TopBar(
                  initial: initial,
                  onAvatarTap: () =>
                      context.goNamed(ListenerRoute.nameProfile),
                  onNotificationsTap: () =>
                      context.goNamed(ListenerRoute.nameInbox),
                ),
                _MapPanel(
                  pins: nearbyAsync.valueOrNull?.take(3).toList() ??
                      const <Masjid>[],
                  onSearchTap: () =>
                      context.goNamed(ListenerRoute.nameSearchResults),
                  onPinTap: goToMasjid,
                ),
                _ContentHeader(
                  count: nearbyAsync.valueOrNull?.length ?? 0,
                  mode: _mode,
                  loading: nearbyAsync.isLoading,
                  onModeChanged: (m) => setState(() => _mode = m),
                ),
                if (_mode == _ViewMode.list)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerMargin,
                    ),
                    child: nearbyAsync.when(
                      data: (list) => _MasjidList(
                        masjids: list,
                        onTap: goToMasjid,
                      ),
                      loading: () => const _MasjidListSkeleton(),
                      error: (err, _) => _ListError(message: err.toString()),
                    ),
                  )
                else
                  const _MapModeHint(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.nameNearbyMasjids,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile palette — deterministic per-masjid styling
// ─────────────────────────────────────────────────────────────────────────────

class _TileStyle {
  const _TileStyle({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}

const _palette = <_TileStyle>[
  _TileStyle(color: AppColors.purpleDeep, icon: Symbols.mosque_rounded),
  _TileStyle(
    color: AppColors.maghribOrange,
    icon: Symbols.temple_buddhist_rounded,
  ),
  _TileStyle(
    color: AppColors.successGreen,
    icon: Symbols.synagogue_rounded,
  ),
  _TileStyle(
    color: AppColors.infoBlue,
    icon: Symbols.account_balance_rounded,
  ),
];

_TileStyle _styleFor(Masjid m) {
  // Hash the id so the same masjid always gets the same colour even if the
  // list re-orders by distance.
  final i = m.id.hashCode.abs() % _palette.length;
  return _palette[i];
}

String _pinLabelFor(Masjid m) {
  // First non-prefix letter ("Masjid Al-Abrar" → "A"; "Al-Huda Mosque" → "A").
  // Strips a leading "Al-" / "Masjid " so the pin labels feel distinct.
  var name = m.name.trim();
  for (final prefix in <String>['Masjid ', 'Al-', 'al-']) {
    if (name.startsWith(prefix)) name = name.substring(prefix.length);
  }
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.initial,
    required this.onAvatarTap,
    required this.onNotificationsTap,
  });
  final String initial;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.gutter,
        AppSpacing.containerMargin,
        AppSpacing.gutter,
      ),
      child: Row(
        children: <Widget>[
          _CircleIconButton(
            onTap: onAvatarTap,
            child: Center(
              child: Text(
                initial,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Nearby',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            borderRadius: AppRadii.fullAll,
            child: InkWell(
              onTap: onNotificationsTap,
              borderRadius: AppRadii.fullAll,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Symbols.notifications_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map panel — stylized fake map with rotated roads, pulsing user dot, pins,
// and a floating search bar. Pin letters come from the masjid data.
// ─────────────────────────────────────────────────────────────────────────────

class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.pins,
    required this.onSearchTap,
    required this.onPinTap,
  });
  final List<Masjid> pins;
  final VoidCallback onSearchTap;
  final void Function(String masjidId) onPinTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          const Positioned.fill(
            child: ColoredBox(color: AppColors.bgElevated),
          ),
          const Positioned.fill(child: _DottedGrid()),
          Positioned(
            top: 40,
            left: 60,
            child: Transform.rotate(
              angle: -0.262,
              child: const _Road(width: 200),
            ),
          ),
          Positioned(
            top: 120,
            left: -50,
            child: Transform.rotate(
              angle: 0.175,
              child: const _Road(width: 400),
            ),
          ),
          Positioned(
            top: 220,
            left: 30,
            child: Transform.rotate(
              angle: -0.087,
              child: const _Road(width: 300),
            ),
          ),
          Positioned(
            top: 0,
            left: 220,
            child: Transform.rotate(
              angle: 0.087,
              child: const _Road(width: 16, height: 400, vertical: true),
            ),
          ),
          // Pins — positioned around the user dot, labelled from masjid names.
          if (pins.isNotEmpty)
            Positioned(
              top: 60,
              left: 110,
              child: _MapPin(
                label: _pinLabelFor(pins[0]),
                onTap: () => onPinTap(pins[0].id),
              ),
            ),
          if (pins.length >= 2)
            Positioned(
              top: 180,
              left: 250,
              child: _MapPin(
                label: _pinLabelFor(pins[1]),
                onTap: () => onPinTap(pins[1].id),
              ),
            ),
          if (pins.length >= 3)
            Positioned(
              top: 240,
              left: 80,
              child: _MapPin(
                label: _pinLabelFor(pins[2]),
                onTap: () => onPinTap(pins[2].id),
              ),
            ),
          const Positioned(top: 160, left: 160, child: _PulsingUserDot()),
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(child: _SearchBar(onTap: onSearchTap)),
          ),
        ],
      ),
    );
  }
}

class _Road extends StatelessWidget {
  const _Road({required this.width, this.height = 16, this.vertical = false});
  final double width;
  final double height;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vertical ? height : width,
      height: vertical ? width : height,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _DottedGrid extends StatelessWidget {
  const _DottedGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedGridPainter(
        color: AppColors.primary.withValues(alpha: 0.06),
      ),
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  _DottedGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 18.0;
    const radius = 0.8;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DottedGridPainter old) => old.color != color;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Symbols.location_on_rounded,
              color: AppColors.primary,
              size: 36,
              fill: 1,
              shadows: <Shadow>[
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            Positioned(
              top: 10,
              child: Text(
                label,
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.bgDeepNight,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingUserDot extends StatefulWidget {
  const _PulsingUserDot();

  @override
  State<_PulsingUserDot> createState() => _PulsingUserDotState();
}

class _PulsingUserDotState extends State<_PulsingUserDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final value = _pulse.value;
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 16 + (32 * value),
                height: 16 + (32 * value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: (1 - value) * 0.35,
                  ),
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.onPrimary, width: 2),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: AppColors.surfaceCard.withValues(alpha: 0.9),
          borderRadius: AppRadii.fullAll,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadii.fullAll,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadii.fullAll,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Symbols.search_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search for a masjid',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Hint shown below the toggle when MAP mode is active — list is hidden so the
// map panel above is the focus, and this nudge tells users where to look.
class _MapModeHint extends StatelessWidget {
  const _MapModeHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerMargin,
      ),
      child: Container(
        padding: AppSpacing.cardInner,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadii.heroAll,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Symbols.location_on_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tap a pin on the map above to open a masjid.',
                style:
                    AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content header
// ─────────────────────────────────────────────────────────────────────────────

enum _ViewMode { list, map }

class _ContentHeader extends StatelessWidget {
  const _ContentHeader({
    required this.count,
    required this.mode,
    required this.loading,
    required this.onModeChanged,
  });
  final int count;
  final _ViewMode mode;
  final bool loading;
  final ValueChanged<_ViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final title = loading
        ? 'Looking for masjids…'
        : '$count ${count == 1 ? "masjid" : "masjids"} nearby';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.sectionGap,
        AppSpacing.containerMargin,
        AppSpacing.gutter,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: AppRadii.fullAll,
              border: Border.all(color: AppColors.borderLow),
            ),
            child: Row(
              children: <Widget>[
                _ToggleButton(
                  label: 'LIST',
                  isActive: mode == _ViewMode.list,
                  onTap: () => onModeChanged(_ViewMode.list),
                ),
                _ToggleButton(
                  label: 'MAP',
                  isActive: mode == _ViewMode.map,
                  onTap: () => onModeChanged(_ViewMode.map),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: isActive ? AppColors.onPrimary : AppColors.inkMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Masjid list + tile
// ─────────────────────────────────────────────────────────────────────────────

class _MasjidList extends StatelessWidget {
  const _MasjidList({required this.masjids, required this.onTap});
  final List<Masjid> masjids;
  final void Function(String masjidId) onTap;

  @override
  Widget build(BuildContext context) {
    if (masjids.isEmpty) {
      return Container(
        padding: AppSpacing.cardInner,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadii.heroAll,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          "No masjids within your current radius.",
          style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
        ),
      );
    }
    return Column(
      children: <Widget>[
        for (var i = 0; i < masjids.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.gutter),
          _MasjidCard(
            masjid: masjids[i],
            onTap: () => onTap(masjids[i].id),
          ),
        ],
      ],
    );
  }
}

class _MasjidCard extends StatelessWidget {
  const _MasjidCard({required this.masjid, required this.onTap});
  final Masjid masjid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(masjid);
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.heroAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.heroAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: AppSpacing.cardInner,
          decoration: BoxDecoration(
            borderRadius: AppRadii.heroAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.2),
                  borderRadius: AppRadii.xlAll,
                ),
                child: Icon(
                  style.icon,
                  color: style.color,
                  size: 30,
                  fill: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      masjid.name,
                      style: AppTypography.bodyLg.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        if (masjid.distanceKm != null) ...<Widget>[
                          Text(
                            _formatDistance(masjid.distanceKm!),
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.inkSubtle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            masjid.openStatusLabel ?? masjid.city,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (masjid.isBroadcasting) const _LiveBadge(),
                  if (masjid.isBroadcasting && masjid.isVerified)
                    const SizedBox(height: 6),
                  if (masjid.isVerified) const _VerifiedBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    if (km < 1000) return '${km.toStringAsFixed(0)} km';
    return '${(km / 1000).toStringAsFixed(0)}k km';
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.liveRedBg,
        borderRadius: AppRadii.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.liveRed.withValues(
                  alpha: 0.5 + (_pulse.value * 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.liveRed,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningAmberBg,
        borderRadius: AppRadii.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Symbols.verified_rounded,
            color: AppColors.goldHighlight,
            size: 12,
            fill: 1,
          ),
          const SizedBox(width: 4),
          Text(
            'VERIFIED',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.goldHighlight,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading + error states
// ─────────────────────────────────────────────────────────────────────────────

class _MasjidListSkeleton extends StatelessWidget {
  const _MasjidListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        _MasjidCardSkeleton(),
        SizedBox(height: AppSpacing.gutter),
        _MasjidCardSkeleton(),
        SizedBox(height: AppSpacing.gutter),
        _MasjidCardSkeleton(),
      ],
    );
  }
}

class _MasjidCardSkeleton extends StatelessWidget {
  const _MasjidCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.6),
        borderRadius: AppRadii.heroAll,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: AppRadii.xlAll,
            ),
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 150,
                  height: 16,
                  color: AppColors.surfaceContainerHighest,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 100,
                  height: 12,
                  color: AppColors.surfaceContainerHighest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListError extends StatelessWidget {
  const _ListError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Symbols.error_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "Couldn't load nearby masjids: $message",
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
