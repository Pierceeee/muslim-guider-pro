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
import '../../../data/models/prayer_times.dart';
import '../../../data/models/stream_record.dart';
import '../../../data/providers/listener_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/home-listener.html` — the listener dashboard.
///
/// All data flows through Riverpod providers (`ensureSignedInUserProvider`,
/// `todaysPrayerScheduleProvider`, `preferredMasjidProvider`,
/// `nearbyLiveBroadcastsProvider`). Hardcoded strings only survive for
/// things that ARE static design choices (e.g. the "Assalamu alaikum,"
/// greeting prefix).
class HomeListenerScreen extends ConsumerWidget {
  const HomeListenerScreen({super.key});

  void _goLivePlayer(BuildContext context, String streamId) {
    context.goNamed(
      ListenerRoute.nameLivePlayer,
      pathParameters: <String, String>{'streamId': streamId},
    );
  }

  void _goMasjid(BuildContext context, String masjidId) {
    context.goNamed(
      ListenerRoute.nameMasjidDetail,
      pathParameters: <String, String>{'masjidId': masjidId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(ensureSignedInUserProvider);
    final scheduleAsync = ref.watch(todaysPrayerScheduleProvider);
    final preferredMasjidAsync = ref.watch(preferredMasjidProvider);
    final liveBroadcastsAsync = ref.watch(nearbyLiveBroadcastsProvider);

    final user = userAsync.valueOrNull;
    final schedule = scheduleAsync.valueOrNull;
    final preferredMasjid = preferredMasjidAsync.valueOrNull;
    final liveBroadcasts =
        liveBroadcastsAsync.valueOrNull ?? const <LiveBroadcastView>[];
    final activePrayer = schedule == null ? null : _nextPrayer(schedule);

    // Live stream of the preferred masjid drives the LISTEN button + live pill.
    final preferredStreamId = preferredMasjid?.currentStreamId;
    final preferredStream = preferredStreamId == null
        ? null
        : ref.watch(streamByIdProvider(preferredStreamId)).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                0,
                AppSpacing.containerMargin,
                140,
              ),
              children: <Widget>[
                const SizedBox(height: AppSpacing.gutter),
                _TopBar(
                  greeting: 'Assalamu alaikum,',
                  displayName: user?.displayName ?? 'Welcome',
                  onAvatarTap: () =>
                      context.goNamed(ListenerRoute.nameProfile),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _PressableScale(
                  onTap: () =>
                      context.goNamed(ListenerRoute.namePrayerSchedule),
                  child: _NextPrayerHero(
                    prayerName: activePrayer?.shortName ?? '—',
                    time: activePrayer == null
                        ? '--:--'
                        : _fmtTime(activePrayer.time),
                    dateLine:
                        _fmtDateLine(schedule?.date ?? DateTime.now()),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _PrayerGrid(
                  schedule: schedule,
                  activeIndex: activePrayer?.index ?? 2,
                  onTap: () =>
                      context.goNamed(ListenerRoute.namePrayerSchedule),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                if (preferredMasjid != null)
                  _MasjidCard(
                    masjid: preferredMasjid,
                    liveStream: preferredStream,
                    onCardTap: () => _goMasjid(context, preferredMasjid.id),
                    onListenTap: preferredStream == null
                        ? null
                        : () =>
                            _goLivePlayer(context, preferredStream.id),
                  )
                else
                  const _MasjidCardSkeleton(),
                const SizedBox(height: AppSpacing.sectionGap),
                _SectionHeader(
                  title: 'Live broadcasts near you',
                  actionLabel: 'SEE ALL',
                  onActionTap: () =>
                      context.goNamed(ListenerRoute.nameNearbyMasjids),
                ),
                const SizedBox(height: AppSpacing.gutter),
                _BroadcastsList(
                  broadcasts: liveBroadcasts,
                  loading: liveBroadcastsAsync.isLoading,
                  onTap: (streamId) => _goLivePlayer(context, streamId),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.nameHomeListener,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Next prayer" derivation
// ─────────────────────────────────────────────────────────────────────────────

class _ActivePrayer {
  const _ActivePrayer({
    required this.shortName,
    required this.time,
    required this.index,
  });
  final String shortName;
  final DateTime time;

  /// 0 = Fajr, 1 = Dhuhr, 2 = Asr, 3 = Maghrib, 4 = Isha.
  final int index;
}

_ActivePrayer _nextPrayer(PrayerTimes schedule) {
  final now = DateTime.now();
  final ordered = <(String, DateTime, int)>[
    ('FAJR', schedule.fajr, 0),
    ('DHUHR', schedule.dhuhr, 1),
    ('ASR', schedule.asr, 2),
    ('MAGHRIB', schedule.maghrib, 3),
    ('ISHA', schedule.isha, 4),
  ];
  for (final entry in ordered) {
    final name = entry.$1;
    final time = entry.$2;
    final idx = entry.$3;
    if (time.isAfter(now)) {
      return _ActivePrayer(shortName: name, time: time, index: idx);
    }
  }
  // Past Isha — wrap to tomorrow's Fajr.
  return _ActivePrayer(
    shortName: 'FAJR',
    time: schedule.fajr.add(const Duration(days: 1)),
    index: 0,
  );
}

String _fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _fmtDateLine(DateTime d) {
  const weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Press-scale wrapper — taps shrink the child to 97% then bounce back.
// ─────────────────────────────────────────────────────────────────────────────

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.greeting,
    required this.displayName,
    required this.onAvatarTap,
  });
  final String greeting;
  final String displayName;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              greeting,
              style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 2),
            Text(displayName, style: AppTypography.headlineMd),
          ],
        ),
        _PressableScale(
          onTap: onAvatarTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: AppColors.surfaceContainerHighest,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              displayName.isEmpty ? '?' : displayName.substring(0, 1),
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Next-prayer hero
// ─────────────────────────────────────────────────────────────────────────────

class _NextPrayerHero extends StatelessWidget {
  const _NextPrayerHero({
    required this.prayerName,
    required this.time,
    required this.dateLine,
  });
  final String prayerName;
  final String time;
  final String dateLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: AppRadii.heroAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.purpleDeep, AppColors.bgDeepNight],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 60,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'NEXT PRAYER · $prayerName',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: AppTypography.headlineXl.copyWith(
                  fontSize: 64,
                  height: 1,
                  color: AppColors.primary,
                  shadows: <Shadow>[
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dateLine,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.inkPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer grid
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerGrid extends StatelessWidget {
  const _PrayerGrid({
    required this.schedule,
    required this.activeIndex,
    required this.onTap,
  });
  final PrayerTimes? schedule;
  final int activeIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cells = schedule == null
        ? const <(String, String)>[
            ('FAJR', '--:--'),
            ('DHUHR', '--:--'),
            ('ASR', '--:--'),
            ('MAGHRIB', '--:--'),
            ('ISHA', '--:--'),
          ]
        : <(String, String)>[
            ('FAJR', _fmtTime(schedule!.fajr)),
            ('DHUHR', _fmtTime(schedule!.dhuhr)),
            ('ASR', _fmtTime(schedule!.asr)),
            ('MAGHRIB', _fmtTime(schedule!.maghrib)),
            ('ISHA', _fmtTime(schedule!.isha)),
          ];

    return _PressableScale(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < cells.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _PrayerCellTile(
                label: cells[i].$1,
                time: cells[i].$2,
                isActive: i == activeIndex,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerCellTile extends StatelessWidget {
  const _PrayerCellTile({
    required this.label,
    required this.time,
    required this.isActive,
  });
  final String label;
  final String time;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.bgElevated,
        borderRadius: AppRadii.xlAll,
        boxShadow: isActive
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              fontSize: 10,
              color: isActive ? AppColors.onPrimary : AppColors.inkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTypography.numeralTime.copyWith(
              color: isActive ? AppColors.onPrimary : AppColors.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Masjid card (preferred masjid hero)
// ─────────────────────────────────────────────────────────────────────────────

class _MasjidCard extends StatelessWidget {
  const _MasjidCard({
    required this.masjid,
    required this.liveStream,
    required this.onCardTap,
    required this.onListenTap,
  });
  final Masjid masjid;
  final StreamRecord? liveStream;
  final VoidCallback onCardTap;
  final VoidCallback? onListenTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.heroAll,
      child: InkWell(
        onTap: onCardTap,
        borderRadius: AppRadii.heroAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: AppSpacing.cardInner,
          decoration: BoxDecoration(
            borderRadius: AppRadii.heroAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Symbols.mosque_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      masjid.name,
                      style:
                          AppTypography.headlineMd.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        if (masjid.distanceKm != null)
                          Flexible(
                            child: Text(
                              '${masjid.distanceKm!.toStringAsFixed(1)} km away',
                              style:
                                  AppTypography.bodySm.copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (liveStream != null) ...<Widget>[
                          const SizedBox(width: 8),
                          _LivePill(
                            label: 'Live now · ${liveStream!.title}',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ListenButton(onTap: onListenTap),
            ],
          ),
        ),
      ),
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
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 16,
                  width: 160,
                  color: AppColors.surfaceContainerHighest,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 100,
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

class _LivePill extends StatefulWidget {
  const _LivePill({required this.label});
  final String label;

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
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
        border: Border.all(
          color: AppColors.liveRed.withValues(alpha: 0.3),
        ),
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
          Flexible(
            child: Text(
              widget.label.toUpperCase(),
              style: AppTypography.labelCaps.copyWith(
                fontSize: 9,
                color: AppColors.liveRed,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return _PressableScale(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.surfaceContainerHighest,
          borderRadius: AppRadii.fullAll,
          boxShadow: enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          'LISTEN',
          style: AppTypography.labelCaps.copyWith(
            color: enabled ? AppColors.onPrimary : AppColors.inkMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: AppTypography.headlineMd.copyWith(fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: InkWell(
            onTap: onActionTap,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              child: Text(
                actionLabel,
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live broadcasts list
// ─────────────────────────────────────────────────────────────────────────────

class _BroadcastsList extends StatelessWidget {
  const _BroadcastsList({
    required this.broadcasts,
    required this.loading,
    required this.onTap,
  });
  final List<LiveBroadcastView> broadcasts;
  final bool loading;
  final void Function(String streamId) onTap;

  @override
  Widget build(BuildContext context) {
    if (broadcasts.isEmpty) {
      if (loading) {
        return Column(
          children: const <Widget>[
            _BroadcastTileSkeleton(),
            SizedBox(height: 12),
            _BroadcastTileSkeleton(),
          ],
        );
      }
      return Container(
        padding: AppSpacing.cardInner,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: AppRadii.xlAll,
          border: Border.all(
            color: AppColors.inkPrimary.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          'No live broadcasts near you right now.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
        ),
      );
    }
    final top = broadcasts.take(3).toList();
    return Column(
      children: <Widget>[
        for (var i = 0; i < top.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          _BroadcastTile(
            view: top[i],
            onTap: () => onTap(top[i].stream.id),
          ),
        ],
      ],
    );
  }
}

class _BroadcastTile extends StatelessWidget {
  const _BroadcastTile({required this.view, required this.onTap});
  final LiveBroadcastView view;
  final VoidCallback onTap;

  String _formatListenerCount(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      final s = k.toStringAsFixed(k >= 10 ? 0 : 1);
      return '${s}k';
    }
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final stream = view.stream;
    final masjid = view.masjid;
    final subtitle = '${stream.title}  •  '
        '${_formatListenerCount(stream.listenerCountCurrent)} listening';
    return Material(
      color: AppColors.bgElevated,
      borderRadius: AppRadii.xlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.xlAll,
            border: Border.all(
              color: AppColors.inkPrimary.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.lgAll,
                  color: AppColors.surfaceContainerHighest,
                ),
                child: const Icon(
                  Symbols.mosque_rounded,
                  color: AppColors.inkMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      masjid.name,
                      style: AppTypography.bodyLg,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySm.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Symbols.equalizer_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BroadcastTileSkeleton extends StatelessWidget {
  const _BroadcastTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: AppRadii.xlAll,
        color: AppColors.bgElevated.withValues(alpha: 0.6),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              color: AppColors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 140,
                  height: 14,
                  color: AppColors.surfaceContainerHighest,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 90,
                  height: 10,
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
