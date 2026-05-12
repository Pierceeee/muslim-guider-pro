import 'dart:math' as math;

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

/// Recreates `prototype/screens/replay-player-masjid-al-abrar.html` — the
/// post-broadcast playback surface for ended streams.
///
/// Data:
///   • [streamByIdProvider] resolves the [StreamRecord]; we require
///     `status == ended` to have something to replay.
///   • Duration comes from `endedAt - startedAt`; position is local state
///     that the user can scrub.
///
/// In B6 (Phase B), the `replayUrl` on `StreamRecord` will feed a real
/// audio player (e.g. `just_audio`). For F4 we drive the position with a
/// simulated ticker so the UI is fully exercisable.
class ReplayPlayerScreen extends ConsumerStatefulWidget {
  const ReplayPlayerScreen({required this.streamId, super.key});
  final String streamId;

  @override
  ConsumerState<ReplayPlayerScreen> createState() =>
      _ReplayPlayerScreenState();
}

class _ReplayPlayerScreenState extends ConsumerState<ReplayPlayerScreen>
    with TickerProviderStateMixin {
  bool _playing = false;
  double _speed = 1.0; // 0.75, 1.0, 1.25
  Duration _position = Duration.zero;
  late final AnimationController _ticker;
  late final AnimationController _orbGlow;

  @override
  void initState() {
    super.initState();
    _orbGlow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener(_onTick);
  }

  @override
  void dispose() {
    _ticker
      ..removeStatusListener(_onTick)
      ..dispose();
    _orbGlow.dispose();
    super.dispose();
  }

  void _onTick(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    if (!_playing) return;
    setState(() {
      final stepMs = (1000 * _speed).round();
      _position = _position + Duration(milliseconds: stepMs);
    });
    _ticker.forward(from: 0);
  }

  void _minimize() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameHomeListener);
    }
  }

  void _togglePlay(Duration duration) {
    setState(() {
      if (_position >= duration) _position = Duration.zero;
      _playing = !_playing;
    });
    if (_playing) {
      _ticker.forward(from: 0);
    } else {
      _ticker.stop();
    }
  }

  void _cycleSpeed() {
    setState(() {
      _speed = switch (_speed) {
        < 0.9 => 1.0,
        > 1.1 => 0.75,
        _ => 1.25,
      };
    });
  }

  void _seekBy(Duration delta, Duration duration) {
    setState(() {
      var next = _position + delta;
      if (next < Duration.zero) next = Duration.zero;
      if (next > duration) next = duration;
      _position = next;
    });
  }

  void _seekToFraction(double fraction, Duration duration) {
    final clamped = fraction.clamp(0.0, 1.0);
    setState(() {
      _position = Duration(
        milliseconds: (duration.inMilliseconds * clamped).round(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final streamAsync = ref.watch(streamByIdProvider(widget.streamId));

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
          child: streamAsync.when(
            data: (stream) {
              if (stream.status == StreamStatus.live) {
                // Edge case: user landed on /replay/<live-stream-id>.
                // Redirect them to the live player on next frame.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.goNamed(
                      ListenerRoute.nameLivePlayer,
                      pathParameters: <String, String>{
                        'streamId': stream.id,
                      },
                    );
                  }
                });
                return const _CenteredSpinner();
              }
              return _LoadedReplay(
                stream: stream,
                ref: ref,
                playing: _playing,
                position: _position,
                speed: _speed,
                orbGlow: _orbGlow,
                onMinimize: _minimize,
                onTogglePlay: _togglePlay,
                onCycleSpeed: _cycleSpeed,
                onSeekBy: _seekBy,
                onSeekToFraction: _seekToFraction,
              );
            },
            loading: () => const _CenteredSpinner(),
            error: (err, _) => _ReplayError(
              message: err.toString(),
              onBack: _minimize,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded body
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedReplay extends StatelessWidget {
  const _LoadedReplay({
    required this.stream,
    required this.ref,
    required this.playing,
    required this.position,
    required this.speed,
    required this.orbGlow,
    required this.onMinimize,
    required this.onTogglePlay,
    required this.onCycleSpeed,
    required this.onSeekBy,
    required this.onSeekToFraction,
  });

  final StreamRecord stream;
  final WidgetRef ref;
  final bool playing;
  final Duration position;
  final double speed;
  final AnimationController orbGlow;
  final VoidCallback onMinimize;
  final void Function(Duration duration) onTogglePlay;
  final VoidCallback onCycleSpeed;
  final void Function(Duration delta, Duration duration) onSeekBy;
  final void Function(double fraction, Duration duration) onSeekToFraction;

  static const _prayerLabels = <StreamPrayer, String>{
    StreamPrayer.fajr: 'FAJR',
    StreamPrayer.dhuhr: 'DHUHR',
    StreamPrayer.asr: 'ASR',
    StreamPrayer.maghrib: 'MAGHRIB',
    StreamPrayer.isha: 'ISHA',
    StreamPrayer.jumuah: "JUMU'AH",
    StreamPrayer.khutbah: 'KHUTBAH',
    StreamPrayer.dhikr: 'DHIKR',
  };

  Duration get _duration {
    final ended = stream.endedAt;
    if (ended == null) {
      return const Duration(minutes: 4); // sane fallback
    }
    return ended.difference(stream.startedAt);
  }

  @override
  Widget build(BuildContext context) {
    final masjid =
        ref.watch(masjidByIdProvider(stream.masjidId)).valueOrNull;
    final prayerLabel = _prayerLabels[stream.prayer] ?? 'REPLAY';
    final duration = _duration;
    final hasRecording = stream.replayUrl != null;

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: _ArabesqueOverlay()),
        Column(
          children: <Widget>[
            _TopBar(
              endedAt: stream.endedAt,
              onMinimize: onMinimize,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _ReplayOrb(glow: orbGlow),
                    const SizedBox(height: 36),
                    _Metadata(
                      prayerLabel: prayerLabel,
                      masjidName: masjid?.name ?? 'Loading…',
                      muadhinName: stream.muadhinName,
                      city: masjid?.city ?? '',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
              ),
              child: Column(
                children: <Widget>[
                  _Seeker(
                    position: position,
                    duration: duration,
                    onSeekToFraction: (f) => onSeekToFraction(f, duration),
                  ),
                  const SizedBox(height: 28),
                  _Controls(
                    playing: playing,
                    speed: speed,
                    onTogglePlay: () => onTogglePlay(duration),
                    onCycleSpeed: onCycleSpeed,
                    onBack10: () => onSeekBy(
                      const Duration(seconds: -10),
                      duration,
                    ),
                    onForward10: () => onSeekBy(
                      const Duration(seconds: 10),
                      duration,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DownloadCard(
                    available: hasRecording,
                    sizeLabel: '2.1 MB',
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceCard,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              hasRecording
                                  ? 'Offline download arrives with the audio service in B6.'
                                  : 'No recording was captured for this broadcast.',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading + error
// ─────────────────────────────────────────────────────────────────────────────

class _CenteredSpinner extends StatelessWidget {
  const _CenteredSpinner();

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

class _ReplayError extends StatelessWidget {
  const _ReplayError({required this.message, required this.onBack});
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
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              "Couldn't load this replay.",
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
                'Back',
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

// ─────────────────────────────────────────────────────────────────────────────
// Arabesque background overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ArabesqueOverlay extends StatelessWidget {
  const _ArabesqueOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _ArabesquePainter()),
    );
  }
}

class _ArabesquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldHighlight.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    const spacing = 64.0;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        _drawStar(canvas, Offset(x, y), 6, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = (i * math.pi / 4) - math.pi / 2;
      final rr = i.isEven ? r : r * 0.45;
      final p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArabesquePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — "Minimize" + REPLAY pill
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.endedAt, required this.onMinimize});
  final DateTime? endedAt;
  final VoidCallback onMinimize;

  String _agoLabel(DateTime? ended) {
    if (ended == null) return 'Recorded today';
    final diff = DateTime.now().difference(ended);
    if (diff.isNegative || diff.inMinutes < 1) return 'Just recorded';
    if (diff.inMinutes < 60) return 'Recorded ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Recorded ${diff.inHours} hr ago';
    if (diff.inDays < 7) return 'Recorded ${diff.inDays} days ago';
    return 'Recorded ${(diff.inDays / 7).floor()} wk ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        16,
        AppSpacing.containerMargin,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            borderRadius: AppRadii.fullAll,
            child: InkWell(
              onTap: onMinimize,
              borderRadius: AppRadii.fullAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Symbols.keyboard_arrow_down_rounded,
                      color: AppColors.inkPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Minimize',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.inkPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warningAmberBg,
              borderRadius: AppRadii.fullAll,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'REPLAY',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _agoLabel(endedAt),
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orb — two concentric rings + gold gradient orb (no inner highlight,
// different from live-player which has the octagonal star frame)
// ─────────────────────────────────────────────────────────────────────────────

class _ReplayOrb extends StatelessWidget {
  const _ReplayOrb({required this.glow});
  final AnimationController glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
          ),
          Container(
            width: 232,
            height: 232,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: glow,
            builder: (context, _) {
              final t = glow.value;
              return Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment.center,
                    radius: 0.65,
                    colors: <Color>[
                      AppColors.goldHighlight,
                      AppColors.goldDeep,
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.goldHighlight.withValues(
                        alpha: 0.30 + (t * 0.15),
                      ),
                      blurRadius: 32 + (t * 16),
                      spreadRadius: 2 + (t * 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Symbols.mosque_rounded,
                  color: AppColors.bgDeepNight,
                  size: 84,
                  fill: 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metadata block
// ─────────────────────────────────────────────────────────────────────────────

class _Metadata extends StatelessWidget {
  const _Metadata({
    required this.prayerLabel,
    required this.masjidName,
    required this.muadhinName,
    required this.city,
  });
  final String prayerLabel;
  final String masjidName;
  final String muadhinName;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          '$prayerLabel · REPLAY',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          masjidName,
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.inkPrimary,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          city.isEmpty
              ? 'Muadhin: $muadhinName'
              : 'Muadhin: $muadhinName · $city',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.inkMuted.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seekable progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _Seeker extends StatelessWidget {
  const _Seeker({
    required this.position,
    required this.duration,
    required this.onSeekToFraction,
  });
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeekToFraction;

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final fraction = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0);

    return Column(
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              onTapDown: (d) => onSeekToFraction(d.localPosition.dx / width),
              onHorizontalDragUpdate: (d) =>
                  onSeekToFraction(d.localPosition.dx / width),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    // Track
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInset,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    // Fill
                    FractionallySizedBox(
                      widthFactor: fraction,
                      child: Container(
                        height: 6,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              AppColors.goldDeep,
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(99)),
                        ),
                      ),
                    ),
                    // Knob
                    Positioned(
                      left: (fraction * width).clamp(0, width) - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(
                            color: AppColors.bgDeepNight,
                            width: 3,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _fmt(position),
              style: AppTypography.numeralTime.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
            Text(
              _fmt(duration),
              style: AppTypography.numeralTime.copyWith(
                color: AppColors.inkMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controls — back10, speed pill, play/pause, speed pill (cycles), forward10
// ─────────────────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({
    required this.playing,
    required this.speed,
    required this.onTogglePlay,
    required this.onCycleSpeed,
    required this.onBack10,
    required this.onForward10,
  });
  final bool playing;
  final double speed;
  final VoidCallback onTogglePlay;
  final VoidCallback onCycleSpeed;
  final VoidCallback onBack10;
  final VoidCallback onForward10;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _IconButton(icon: Symbols.replay_10_rounded, onTap: onBack10),
        _SpeedPill(label: '×0.75', active: speed == 0.75, onTap: onCycleSpeed),
        _PlayPauseButton(playing: playing, onTap: onTogglePlay),
        _SpeedPill(label: '×1.25', active: speed == 1.25, onTap: onCycleSpeed),
        _IconButton(icon: Symbols.forward_10_rounded, onTap: onForward10),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }
}

class _SpeedPill extends StatelessWidget {
  const _SpeedPill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.1),
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({required this.playing, required this.onTap});
  final bool playing;
  final VoidCallback onTap;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
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
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.primaryFixed, AppColors.goldDeep],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.playing
                ? Symbols.pause_rounded
                : Symbols.play_arrow_rounded,
            color: AppColors.bgDeepNight,
            size: 40,
            fill: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Download card
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({
    required this.available,
    required this.sizeLabel,
    required this.onTap,
  });
  final bool available;
  final String sizeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgElevated.withValues(alpha: 0.5),
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
                  borderRadius: AppRadii.xlAll,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Symbols.download_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'DOWNLOAD',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      available
                          ? 'Available offline · $sizeLabel'
                          : 'Recording not captured for this stream',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkMuted,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Symbols.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
