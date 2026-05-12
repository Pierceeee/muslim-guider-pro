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

/// Recreates `prototype/screens/masjid-detail.html`.
///
/// All data flows through Riverpod providers — Phase B swaps the repository
/// bindings in `repository_providers.dart` and this screen keeps working
/// without modification.
class MasjidDetailScreen extends ConsumerStatefulWidget {
  const MasjidDetailScreen({required this.masjidId, super.key});
  final String masjidId;

  @override
  ConsumerState<MasjidDetailScreen> createState() =>
      _MasjidDetailScreenState();
}

class _MasjidDetailScreenState extends ConsumerState<MasjidDetailScreen> {
  bool _favorited = false;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameNearbyMasjids);
    }
  }

  void _listenToLive(String streamId) {
    context.goNamed(
      ListenerRoute.nameLivePlayer,
      pathParameters: <String, String>{'streamId': streamId},
    );
  }

  void _openReplay(String streamId) {
    context.goNamed(
      ListenerRoute.nameReplayPlayer,
      pathParameters: <String, String>{'streamId': streamId},
    );
  }

  void _toggleFavorite(String masjidName) {
    setState(() => _favorited = !_favorited);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _favorited
                ? 'Added $masjidName to favourites'
                : 'Removed $masjidName from favourites',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  void _scanQr() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'QR community verification arrives in F6.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final masjidAsync = ref.watch(masjidByIdProvider(widget.masjidId));
    final broadcastsAsync =
        ref.watch(masjidBroadcastsProvider(widget.masjidId));
    final scheduleAsync = ref.watch(todaysPrayerScheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: Stack(
        children: <Widget>[
          masjidAsync.when(
            data: (masjid) => _Loaded(
              masjid: masjid,
              schedule: scheduleAsync,
              broadcasts: broadcastsAsync,
              favorited: _favorited,
              onBack: _back,
              onFavorite: () => _toggleFavorite(masjid.name),
              onListen: _listenToLive,
              onReplay: _openReplay,
              onScanQr: _scanQr,
            ),
            loading: () => const _CenteredLoading(),
            error: (err, _) => _CenteredError(
              message: err.toString(),
              onBack: _back,
            ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded body — masjid is ready; schedule + broadcasts may still be loading
// ─────────────────────────────────────────────────────────────────────────────

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.masjid,
    required this.schedule,
    required this.broadcasts,
    required this.favorited,
    required this.onBack,
    required this.onFavorite,
    required this.onListen,
    required this.onReplay,
    required this.onScanQr,
  });

  final Masjid masjid;
  final AsyncValue<PrayerTimes> schedule;
  final AsyncValue<List<StreamRecord>> broadcasts;
  final bool favorited;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final void Function(String streamId) onListen;
  final void Function(String streamId) onReplay;
  final VoidCallback onScanQr;

  @override
  Widget build(BuildContext context) {
    final liveStream = broadcasts.maybeWhen(
      data: (list) =>
          list.where((s) => s.status == StreamStatus.live).firstOrNull,
      orElse: () => null,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: <Widget>[
        _HeroBanner(
          onBack: onBack,
          onFavorite: onFavorite,
          favorited: favorited,
        ),
        Transform.translate(
          offset: const Offset(0, -26),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.containerMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _SummaryCard(
                  masjid: masjid,
                  liveStream: liveStream,
                  onListen: liveStream == null
                      ? null
                      : () => onListen(liveStream.id),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                const _SectionHeading(label: "TODAY'S PRAYER TIMES"),
                const SizedBox(height: 12),
                schedule.when(
                  data: (s) => _PrayerTimesPanel(
                    schedule: s,
                    activePrayer: liveStream?.prayer,
                  ),
                  loading: () => const _SkeletonBlock(height: 96),
                  error: (e, _) =>
                      _InlineError(message: 'Could not load schedule.'),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                const _SectionHeading(label: "TODAY'S BROADCASTS"),
                const SizedBox(height: 12),
                broadcasts.when(
                  data: (list) => _BroadcastsList(
                    streams: list,
                    onLiveTap: onListen,
                    onReplayTap: onReplay,
                  ),
                  loading: () => const _SkeletonBlock(height: 200),
                  error: (e, _) =>
                      _InlineError(message: 'Could not load broadcasts.'),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Center(child: _QrCtaButton(onTap: onScanQr)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading + error states
// ─────────────────────────────────────────────────────────────────────────────

class _CenteredLoading extends StatelessWidget {
  const _CenteredLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _CenteredError extends StatelessWidget {
  const _CenteredError({required this.message, required this.onBack});
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerMargin,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Symbols.error_rounded,
              color: AppColors.error,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              "Couldn't load this masjid.",
              style: AppTypography.headlineMd.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.inkMuted,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onBack,
              child: Text(
                'Go back',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.5),
        borderRadius: AppRadii.heroAll,
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
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
              message,
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.onBack,
    required this.onFavorite,
    required this.favorited,
  });
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final bool favorited;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
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
            bottom: -40,
            left: 60,
            child: _Glow(
              size: 140,
              color: AppColors.primaryFixed.withValues(alpha: 0.20),
              blur: 60,
            ),
          ),
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            child: Center(
              child: _Glow(
                size: 220,
                color: AppColors.purpleDeep.withValues(alpha: 0.55),
                blur: 80,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                8,
                AppSpacing.containerMargin,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _GlassPill(
                    onTap: onBack,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Symbols.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _GlassPill(
                    onTap: onFavorite,
                    circular: true,
                    child: Icon(
                      Symbols.star_rounded,
                      color: AppColors.primary,
                      size: 22,
                      fill: favorited ? 1 : 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.size,
    required this.color,
    required this.blur,
  });
  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: <BoxShadow>[
            BoxShadow(color: color, blurRadius: blur, spreadRadius: blur / 4),
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.child,
    required this.onTap,
    this.circular = false,
  });
  final Widget child;
  final VoidCallback onTap;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard.withValues(alpha: 0.6),
      shape: circular
          ? const CircleBorder()
          : const RoundedRectangleBorder(borderRadius: AppRadii.fullAll),
      child: InkWell(
        onTap: onTap,
        customBorder: circular
            ? const CircleBorder()
            : const RoundedRectangleBorder(borderRadius: AppRadii.fullAll),
        child: Container(
          padding: circular
              ? const EdgeInsets.all(8)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            shape: circular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circular ? null : AppRadii.fullAll,
            border: Border.all(
              color: AppColors.inkPrimary.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.masjid,
    required this.liveStream,
    required this.onListen,
  });
  final Masjid masjid;
  final StreamRecord? liveStream;
  final VoidCallback? onListen;

  @override
  Widget build(BuildContext context) {
    final distance = masjid.distanceKm;
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (masjid.isVerified) ...<Widget>[
                const _VerifiedChip(),
                const SizedBox(width: 8),
              ],
              if (liveStream != null)
                _LiveChip(prayer: _prayerLabel(liveStream!.prayer)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            masjid.name,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.inkPrimary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(
                Symbols.location_on_rounded,
                color: AppColors.inkMuted,
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  distance == null
                      ? masjid.displayAddress
                      : '${masjid.displayAddress} · ${distance.toStringAsFixed(1)} km',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.inkMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.borderMedium.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          _ListenCta(
            label: liveStream == null
                ? 'No live broadcast right now'
                : 'Listen to live broadcast',
            enabled: liveStream != null,
            onTap: onListen,
          ),
        ],
      ),
    );
  }

  static String _prayerLabel(StreamPrayer? prayer) =>
      switch (prayer) {
        StreamPrayer.fajr => 'Fajr',
        StreamPrayer.dhuhr => 'Dhuhr',
        StreamPrayer.asr => 'Asr',
        StreamPrayer.maghrib => 'Maghrib',
        StreamPrayer.isha => 'Isha',
        StreamPrayer.jumuah => "Jumu'ah",
        StreamPrayer.khutbah => 'Khutbah',
        StreamPrayer.dhikr => 'Dhikr',
        null => 'Live',
      };
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            size: 14,
            fill: 1,
          ),
          const SizedBox(width: 4),
          Text(
            'VERIFIED',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.goldHighlight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveChip extends StatefulWidget {
  const _LiveChip({required this.prayer});
  final String prayer;

  @override
  State<_LiveChip> createState() => _LiveChipState();
}

class _LiveChipState extends State<_LiveChip>
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.liveRed.withValues(
                  alpha: 0.5 + (_pulse.value * 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE · ${widget.prayer.toUpperCase()}',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.liveRed,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListenCta extends StatefulWidget {
  const _ListenCta({
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_ListenCta> createState() => _ListenCtaState();
}

class _ListenCtaState extends State<_ListenCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerHighest,
            borderRadius: AppRadii.fullAll,
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color:
                          AppColors.primaryContainer.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Symbols.play_arrow_rounded,
                color: enabled ? AppColors.onPrimary : AppColors.inkMuted,
                size: 22,
                fill: 1,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.bodyLg.copyWith(
                  color: enabled ? AppColors.onPrimary : AppColors.inkMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section heading
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer times panel — computed from PrayerTimes model
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerTimesPanel extends StatelessWidget {
  const _PrayerTimesPanel({
    required this.schedule,
    required this.activePrayer,
  });
  final PrayerTimes schedule;
  final StreamPrayer? activePrayer;

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cells = <_PrayerCellData>[
      _PrayerCellData(
        label: 'FAJR',
        time: _fmt(schedule.fajr),
        isActive: activePrayer == StreamPrayer.fajr,
      ),
      _PrayerCellData(
        label: 'DHUHR',
        time: _fmt(schedule.dhuhr),
        isActive: activePrayer == StreamPrayer.dhuhr,
      ),
      _PrayerCellData(
        label: 'ASR',
        time: _fmt(schedule.asr),
        // If no live stream is in flight, fall back to ASR as the prototype's
        // visual hero pick. Real "current prayer" computation lives in B5.
        isActive: activePrayer == StreamPrayer.asr || activePrayer == null,
      ),
      _PrayerCellData(
        label: 'MAGHR',
        time: _fmt(schedule.maghrib),
        isActive: activePrayer == StreamPrayer.maghrib,
      ),
      _PrayerCellData(
        label: 'ISHA',
        time: _fmt(schedule.isha),
        isActive: activePrayer == StreamPrayer.isha,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: AppRadii.heroAll,
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < cells.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _PrayerCell(data: cells[i])),
          ],
        ],
      ),
    );
  }
}

class _PrayerCellData {
  const _PrayerCellData({
    required this.label,
    required this.time,
    this.isActive = false,
  });
  final String label;
  final String time;
  final bool isActive;
}

class _PrayerCell extends StatelessWidget {
  const _PrayerCell({required this.data});
  final _PrayerCellData data;

  @override
  Widget build(BuildContext context) {
    final isActive = data.isActive;
    return Column(
      children: <Widget>[
        Text(
          data.label,
          style: AppTypography.labelCaps.copyWith(
            color: isActive ? AppColors.primary : AppColors.inkMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.20)
                : AppColors.surfaceCard,
            borderRadius: AppRadii.xlAll,
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : AppColors.borderMedium,
            ),
            boxShadow: isActive
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              data.time,
              style: AppTypography.numeralTime.copyWith(
                color: isActive ? AppColors.primary : AppColors.inkPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Broadcasts list
// ─────────────────────────────────────────────────────────────────────────────

class _BroadcastsList extends StatelessWidget {
  const _BroadcastsList({
    required this.streams,
    required this.onLiveTap,
    required this.onReplayTap,
  });
  final List<StreamRecord> streams;
  final void Function(String streamId) onLiveTap;
  final void Function(String streamId) onReplayTap;

  @override
  Widget build(BuildContext context) {
    if (streams.isEmpty) {
      return Container(
        padding: AppSpacing.cardInner,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadii.xlAll,
          border: Border.all(
            color: AppColors.borderMedium.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          'No broadcasts from this masjid today.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
        ),
      );
    }
    // Live first, then most-recent-ended.
    final sorted = <StreamRecord>[
      ...streams.where((s) => s.status == StreamStatus.live),
      ...(streams.where((s) => s.status != StreamStatus.live).toList()
        ..sort((a, b) {
          final aEnd = a.endedAt ?? a.startedAt;
          final bEnd = b.endedAt ?? b.startedAt;
          return bEnd.compareTo(aEnd);
        })),
    ];
    return Column(
      children: <Widget>[
        for (var i = 0; i < sorted.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 10),
          _BroadcastRow(
            stream: sorted[i],
            onTap: sorted[i].status == StreamStatus.live
                ? () => onLiveTap(sorted[i].id)
                : () => onReplayTap(sorted[i].id),
          ),
        ],
      ],
    );
  }
}

class _BroadcastRow extends StatelessWidget {
  const _BroadcastRow({required this.stream, required this.onTap});
  final StreamRecord stream;
  final VoidCallback onTap;

  String _agoLabel(DateTime endedAt) {
    final diff = DateTime.now().difference(endedAt);
    // Mock fixtures are anchored to "today" in 2026 so real-clock diff can be
    // huge. Fall back to a sensible "Today" label rather than "23000 min ago".
    if (diff.isNegative || diff.inDays > 0) return 'Ended · Today';
    if (diff.inMinutes < 60) {
      return 'Ended · ${diff.inMinutes} min ago';
    }
    return 'Ended · ${diff.inHours} hr ago';
  }

  @override
  Widget build(BuildContext context) {
    final isLive = stream.status == StreamStatus.live;
    final subtitle = isLive
        ? '${stream.muadhinName} · Today'
        : _agoLabel(stream.endedAt ?? stream.startedAt);

    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.xlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.xlAll,
            border: Border.all(
              color: isLive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.borderMedium.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLive
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.borderMedium.withValues(alpha: 0.3),
                ),
                child: Icon(
                  isLive
                      ? Symbols.podcasts_rounded
                      : Symbols.history_rounded,
                  color: isLive ? AppColors.primary : AppColors.inkMuted,
                  size: 20,
                  fill: isLive ? 1 : 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      stream.title,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.inkPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.liveRedBg,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(
                    'LIVE NOW',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.liveRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: AppRadii.fullAll,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Symbols.replay_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'REPLAY',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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

// ─────────────────────────────────────────────────────────────────────────────
// QR scan CTA
// ─────────────────────────────────────────────────────────────────────────────

class _QrCtaButton extends StatelessWidget {
  const _QrCtaButton({required this.onTap});
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Symbols.qr_code_scanner_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Scan QR inside masjid to verify',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
