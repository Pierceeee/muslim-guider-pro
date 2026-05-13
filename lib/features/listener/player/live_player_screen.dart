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

/// Recreates `prototype/screens/live-player-masjid-al-abrar.html` — the
/// full-screen "now playing" surface.
///
/// Data flow:
///   • [streamByIdProvider] resolves the [StreamRecord]
///   • [masjidByIdProvider] resolves the masjid context (name, city)
///   • Local UI state: play/pause, favorite, mock playback position
///
/// In Phase B (B4) the play/pause control will drive the AWS Chime SDK via
/// the streaming platform-channel layer; here it just toggles a flag and
/// the simulated position counter.
class LivePlayerScreen extends ConsumerStatefulWidget {
  const LivePlayerScreen({required this.streamId, super.key});
  final String streamId;

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen>
    with TickerProviderStateMixin {
  bool _playing = true;
  bool _favorited = false;
  late final AnimationController _orbGlow;
  late final AnimationController _waveform;

  @override
  void initState() {
    super.initState();
    _orbGlow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _waveform = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _orbGlow.dispose();
    _waveform.dispose();
    super.dispose();
  }

  void _minimize() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameHomeListener);
    }
  }

  void _togglePlay() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _waveform.repeat();
      } else {
        _waveform.stop();
      }
    });
  }

  void _toggleFavorite() {
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
                ? 'Added to favourites'
                : 'Removed from favourites',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  void _share() {
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
              // Edge case: user landed on /live/<ended-stream-id> (e.g. from
              // a stale notification or deep link). Send them to the replay
              // player on next frame — mirror of the inverse redirect in
              // `replay_player_screen.dart`.
              if (stream.status != StreamStatus.live) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.goNamed(
                      ListenerRoute.nameReplayPlayer,
                      pathParameters: <String, String>{'streamId': stream.id},
                    );
                  }
                });
                return const _PlayerLoading();
              }
              return _LoadedPlayer(
                stream: stream,
                ref: ref,
                playing: _playing,
                favorited: _favorited,
                orbGlow: _orbGlow,
                waveform: _waveform,
                onMinimize: _minimize,
                onTogglePlay: _togglePlay,
                onToggleFavorite: _toggleFavorite,
                onShare: _share,
              );
            },
            loading: () => const _PlayerLoading(),
            error: (err, _) =>
                _PlayerError(message: err.toString(), onMinimize: _minimize),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded body — composes every section once the stream resolves
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedPlayer extends StatelessWidget {
  const _LoadedPlayer({
    required this.stream,
    required this.ref,
    required this.playing,
    required this.favorited,
    required this.orbGlow,
    required this.waveform,
    required this.onMinimize,
    required this.onTogglePlay,
    required this.onToggleFavorite,
    required this.onShare,
  });

  final StreamRecord stream;
  final WidgetRef ref;
  final bool playing;
  final bool favorited;
  final AnimationController orbGlow;
  final AnimationController waveform;
  final VoidCallback onMinimize;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;

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

  @override
  Widget build(BuildContext context) {
    final masjidAsync = ref.watch(masjidByIdProvider(stream.masjidId));
    final masjid = masjidAsync.valueOrNull;
    final prayerLabel = _prayerLabels[stream.prayer] ?? 'LIVE';

    final isLive = stream.status == StreamStatus.live;

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: _ArabesqueOverlay()),
        Column(
          children: <Widget>[
            _TopBar(
              latencyMs: stream.latencyMs,
              isLive: isLive,
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
                    _OrbStack(glow: orbGlow),
                    const SizedBox(height: 36),
                    _StationInfo(
                      prayerLabel: prayerLabel,
                      isLive: isLive,
                      masjidName: masjid?.name ?? 'Loading…',
                      muadhinName: stream.muadhinName,
                      city: masjid?.city ?? '',
                    ),
                    const SizedBox(height: 28),
                    _Waveform(animation: waveform, active: playing),
                    const SizedBox(height: 28),
                    _ProgressRow(playing: playing),
                    const SizedBox(height: 32),
                    _Controls(
                      playing: playing,
                      favorited: favorited,
                      onTogglePlay: onTogglePlay,
                      onToggleFavorite: onToggleFavorite,
                      onShare: onShare,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                0,
                AppSpacing.containerMargin,
                24,
              ),
              child: const _SignalCard(
                bitrate: 64,
                stable: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / error
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerLoading extends StatelessWidget {
  const _PlayerLoading();

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

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.message, required this.onMinimize});
  final String message;
  final VoidCallback onMinimize;

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
              "Couldn't load this broadcast.",
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
              onPressed: onMinimize,
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
// Arabesque background — faint repeating gold dots in an 8-point pattern
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
      ..color = AppColors.goldHighlight.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    // Repeating 8-pointed micro-stars on a 64px lattice. Subtle texture
    // without overwhelming the orb visualizer.
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
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.latencyMs,
    required this.isLive,
    required this.onMinimize,
  });
  final int? latencyMs;
  final bool isLive;
  final VoidCallback onMinimize;

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
                      Symbols.expand_more_rounded,
                      color: AppColors.inkPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Minimize',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLive) _LiveLatencyPill(latencyMs: latencyMs ?? 0),
        ],
      ),
    );
  }
}

class _LiveLatencyPill extends StatefulWidget {
  const _LiveLatencyPill({required this.latencyMs});
  final int latencyMs;

  @override
  State<_LiveLatencyPill> createState() => _LiveLatencyPillState();
}

class _LiveLatencyPillState extends State<_LiveLatencyPill>
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.liveRedBg,
        borderRadius: AppRadii.fullAll,
        border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.2)),
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
          const SizedBox(width: 8),
          Text(
            'LIVE · ${widget.latencyMs} ms',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.liveRed,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orb stack — concentric rings + octagonal star + gold orb
// ─────────────────────────────────────────────────────────────────────────────

class _OrbStack extends StatelessWidget {
  const _OrbStack({required this.glow});
  final AnimationController glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Faint outermost ring
          Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldHighlight.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Inner ring
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldHighlight.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Octagonal star frame
          SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: _OctagonalStarFramePainter(
                color: AppColors.goldHighlight.withValues(alpha: 0.30),
              ),
            ),
          ),
          // The orb itself, with breathing glow.
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
                    radius: 0.6,
                    colors: <Color>[
                      AppColors.goldHighlight,
                      AppColors.primary,
                      AppColors.goldDeep,
                    ],
                    stops: <double>[0.0, 0.55, 1.0],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.goldHighlight.withValues(
                        alpha: 0.35 + (t * 0.20),
                      ),
                      blurRadius: 40 + (t * 20),
                      spreadRadius: 4 + (t * 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Inner highlight at 30% / 30%
                    Positioned(
                      left: 32,
                      top: 32,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.7,
                            colors: <Color>[
                              Colors.white.withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Symbols.mosque_rounded,
                      color: AppColors.onPrimary,
                      size: 56,
                      fill: 1,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OctagonalStarFramePainter extends CustomPainter {
  _OctagonalStarFramePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0.3 * w, 0)
      ..lineTo(0.7 * w, 0)
      ..lineTo(w, 0.3 * h)
      ..lineTo(w, 0.7 * h)
      ..lineTo(0.7 * w, h)
      ..lineTo(0.3 * w, h)
      ..lineTo(0, 0.7 * h)
      ..lineTo(0, 0.3 * h)
      ..close();
    final paintOuter = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final paintInner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, paintOuter);
    // Inset stroke for the double-line look from the prototype.
    final inset = path.shift(const Offset(0, 0));
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale(0.94);
    canvas.translate(-w / 2, -h / 2);
    canvas.drawPath(inset, paintInner);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OctagonalStarFramePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Station info
// ─────────────────────────────────────────────────────────────────────────────

class _StationInfo extends StatelessWidget {
  const _StationInfo({
    required this.prayerLabel,
    required this.isLive,
    required this.masjidName,
    required this.muadhinName,
    required this.city,
  });
  final String prayerLabel;
  final bool isLive;
  final String masjidName;
  final String muadhinName;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          '$prayerLabel · ${isLive ? "LIVE BROADCAST" : "ENDED"}',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.goldHighlight,
            fontWeight: FontWeight.w700,
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
            color: AppColors.inkPrimary.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated waveform — 44 bars driven by a phase-shifted sine.
// ─────────────────────────────────────────────────────────────────────────────

class _Waveform extends StatelessWidget {
  const _Waveform({required this.animation, required this.active});
  final AnimationController animation;
  final bool active;

  static const _barCount = 44;
  static const _barWidth = 2.0;
  static const _barGap = 2.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final phase = animation.value * math.pi * 2;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (var i = 0; i < _barCount; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: _barGap),
                _bar(i, phase),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int i, double phase) {
    final p = (i * 0.55) + phase;
    final wave = (math.sin(p) + 1) / 2;
    final wave2 = (math.sin(p * 2.3 + 0.6) + 1) / 2;
    final amplitude = active ? 1.0 : 0.15;
    final height = (10 + wave * 30 + wave2 * 14) * amplitude;
    final color = i.isEven ? AppColors.primary : AppColors.inkPrimary;
    return SizedBox(
      width: _barWidth,
      child: Container(
        height: height.clamp(3.0, 56.0),
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress row
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressRow extends StatefulWidget {
  const _ProgressRow({required this.playing});
  final bool playing;

  @override
  State<_ProgressRow> createState() => _ProgressRowState();
}

class _ProgressRowState extends State<_ProgressRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  int _seconds = 48;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.playing && mounted) {
          setState(() => _seconds++);
          _ticker.forward(from: 0);
        }
      });
    if (widget.playing) _ticker.forward();
  }

  @override
  void didUpdateWidget(covariant _ProgressRow old) {
    super.didUpdateWidget(old);
    if (widget.playing && !_ticker.isAnimating) {
      _ticker.forward();
    } else if (!widget.playing && _ticker.isAnimating) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Live broadcast has no fixed duration. The bar fills slowly while
    // playing as a "you've heard X amount" visual cue, capped at 95%.
    final progress = (_seconds / 600).clamp(0.0, 0.95);
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: Stack(
              children: <Widget>[
                Container(color: AppColors.surfaceInset),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.goldDeep,
                          AppColors.goldHighlight,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _fmt(_seconds),
              style: AppTypography.numeralTime.copyWith(
                color: AppColors.inkPrimary.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            Text(
              widget.playing ? 'Streaming…' : 'Paused',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.inkPrimary.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playback controls — favorite, play/pause (gold orb), share
// ─────────────────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({
    required this.playing,
    required this.favorited,
    required this.onTogglePlay,
    required this.onToggleFavorite,
    required this.onShare,
  });
  final bool playing;
  final bool favorited;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _IconButton(
            icon: Symbols.favorite_rounded,
            tint: AppColors.goldHighlight.withValues(alpha: 0.6),
            filled: favorited,
            onTap: onToggleFavorite,
          ),
          _PlayPauseButton(playing: playing, onTap: onTogglePlay),
          _IconButton(
            icon: Symbols.share_rounded,
            tint: AppColors.goldHighlight.withValues(alpha: 0.6),
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.tint,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: tint, size: 26, fill: filled ? 1 : 0),
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[AppColors.goldHighlight, AppColors.goldDeep],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.goldHighlight.withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            widget.playing
                ? Symbols.pause_rounded
                : Symbols.play_arrow_rounded,
            color: AppColors.onPrimary,
            size: 36,
            fill: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom signal card
// ─────────────────────────────────────────────────────────────────────────────

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.bitrate,
    required this.stable,
  });
  final int bitrate;
  final bool stable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.5),
        borderRadius: AppRadii.xlAll,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.goldHighlight.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(
                color: AppColors.goldHighlight.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'SIGNAL',
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.goldHighlight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // Latency lives in the top LIVE pill — signal card describes
              // the transport, not the live timing.
              'WebRTC · $bitrate kbps · ${stable ? "Stable" : "Reconnecting"}',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.inkPrimary.withValues(alpha: 0.8),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            stable
                ? Symbols.check_circle_rounded
                : Symbols.error_rounded,
            color: stable ? AppColors.successGreen : AppColors.warningAmber,
            size: 22,
            fill: 1,
          ),
        ],
      ),
    );
  }
}
