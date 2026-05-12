import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/stream_record.dart';
import '../../../data/providers/listener_providers.dart';

/// Recreates `prototype/screens/stream-ended-state.html`.
///
/// Reached automatically by the live-player when `stream.status` transitions
/// to `ended` (in B-phase), or directly via the `/stream/ended` route.
/// We read the user's preferred masjid + its most recent ended broadcast so
/// "Listen to replay" routes to a real `replayUrl`.
class StreamEndedScreen extends ConsumerWidget {
  const StreamEndedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjid = ref.watch(preferredMasjidProvider).valueOrNull;
    final broadcasts = masjid == null
        ? const <StreamRecord>[]
        : ref.watch(masjidBroadcastsProvider(masjid.id)).valueOrNull ??
            const <StreamRecord>[];
    final lastEnded = broadcasts
        .where((s) => s.status == StreamStatus.ended)
        .toList()
      ..sort((a, b) =>
          (b.endedAt ?? b.startedAt).compareTo(a.endedAt ?? a.startedAt));
    final replayStream = lastEnded.isEmpty ? null : lastEnded.first;

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.purpleDeep, AppColors.bgDeepNight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _TopBar(
                prayerLabel:
                    _prayerLabel(replayStream?.prayer) ?? 'BROADCAST',
                onClose: () => _close(context),
                onShare: () => _share(context),
              ),
              _Ribbon(
                masjidName: masjid?.name ?? 'Masjid',
                endedAgo: _agoLabel(replayStream?.endedAt),
              ),
              Expanded(
                child: _Center(
                  masjidName: masjid?.name ?? 'this masjid',
                  prayerLabel:
                      _prayerLabel(replayStream?.prayer)?.toLowerCase() ??
                          'broadcast',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerMargin,
                  0,
                  AppSpacing.containerMargin,
                  24,
                ),
                child: _Actions(
                  canReplay: replayStream != null,
                  onReplay: replayStream == null
                      ? null
                      : () => context.goNamed(
                            ListenerRoute.nameReplayPlayer,
                            pathParameters: <String, String>{
                              'streamId': replayStream.id,
                            },
                          ),
                  onFindAnother: () =>
                      context.goNamed(ListenerRoute.nameNearbyMasjids),
                  onClose: () => _close(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameHomeListener);
    }
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Share sheet arrives with the system Share intent in F4 polish.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  String? _prayerLabel(StreamPrayer? p) => switch (p) {
        StreamPrayer.fajr => 'FAJR PRAYER',
        StreamPrayer.dhuhr => 'DHUHR PRAYER',
        StreamPrayer.asr => 'ASR PRAYER',
        StreamPrayer.maghrib => 'MAGHRIB PRAYER',
        StreamPrayer.isha => 'ISHA PRAYER',
        StreamPrayer.jumuah => "JUMU'AH",
        StreamPrayer.khutbah => 'KHUTBAH',
        StreamPrayer.dhikr => 'DHIKR',
        null => null,
      };

  String _agoLabel(DateTime? endedAt) {
    if (endedAt == null) return 'ended recently';
    final diff = DateTime.now().difference(endedAt);
    if (diff.isNegative || diff.inSeconds < 5) return 'ended just now';
    if (diff.inMinutes < 1) return 'ended ${diff.inSeconds}s ago';
    if (diff.inHours < 1) return 'ended ${diff.inMinutes} min ago';
    if (diff.inDays < 1) return 'ended ${diff.inHours}h ago';
    return 'ended ${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — Close ▼ · "ASR PRAYER" · Share
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.prayerLabel,
    required this.onClose,
    required this.onShare,
  });
  final String prayerLabel;
  final VoidCallback onClose;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        16,
        AppSpacing.containerMargin,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _CircleGlassButton(
            icon: Symbols.keyboard_arrow_down_rounded,
            onTap: onClose,
          ),
          Text(
            prayerLabel,
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
            ),
          ),
          _CircleGlassButton(
            icon: Symbols.share_rounded,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _CircleGlassButton extends StatelessWidget {
  const _CircleGlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.inkPrimary, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ribbon — "Broadcast ended" pill + masjid name + "ended X ago"
// ─────────────────────────────────────────────────────────────────────────────

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.masjidName, required this.endedAgo});
  final String masjidName;
  final String endedAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.18),
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: AppRadii.fullAll,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Broadcast ended',
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            masjidName,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            endedAgo,
            style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Center — dim orb + copy
// ─────────────────────────────────────────────────────────────────────────────

class _Center extends StatelessWidget {
  const _Center({required this.masjidName, required this.prayerLabel});
  final String masjidName;
  final String prayerLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.rotate(
                angle: 0.785, // 45°
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              Container(
                width: 248,
                height: 248,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgDeepNight,
                  border: Border.all(
                    color: AppColors.inkPrimary.withValues(alpha: 0.05),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Symbols.mic_off_rounded,
                  color: AppColors.inkMuted.withValues(alpha: 0.5),
                  size: 56,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          child: Column(
            children: <Widget>[
              Text(
                'That broadcast has ended.',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: 12),
              Text(
                "$masjidName's $prayerLabel broadcast finished. "
                'Would you like to listen to the replay or find another '
                'live broadcast nearby?',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three action buttons
// ─────────────────────────────────────────────────────────────────────────────

class _Actions extends StatelessWidget {
  const _Actions({
    required this.canReplay,
    required this.onReplay,
    required this.onFindAnother,
    required this.onClose,
  });
  final bool canReplay;
  final VoidCallback? onReplay;
  final VoidCallback onFindAnother;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _PrimaryButton(
          icon: Symbols.replay_rounded,
          label: 'Listen to replay',
          enabled: canReplay,
          onTap: onReplay,
        ),
        const SizedBox(height: 12),
        _SecondaryButton(
          icon: Symbols.explore_rounded,
          label: 'Find another live broadcast',
          onTap: onFindAnother,
        ),
        const SizedBox(height: 8),
        _TertiaryButton(label: 'Close', onTap: onClose),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary
                : AppColors.surfaceContainerHighest,
            borderRadius: AppRadii.fullAll,
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                widget.icon,
                color: enabled ? AppColors.onPrimary : AppColors.inkMuted,
                size: 22,
                fill: 1,
              ),
              const SizedBox(width: 10),
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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            border: Border.all(
              color: AppColors.purpleDeep.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTypography.bodyLg.copyWith(
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

class _TertiaryButton extends StatelessWidget {
  const _TertiaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: AppTypography.labelCaps.copyWith(
          color: AppColors.inkMuted,
        ),
      ),
    );
  }
}
