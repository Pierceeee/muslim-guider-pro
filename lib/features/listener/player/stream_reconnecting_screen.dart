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
import '../../../data/providers/listener_providers.dart';

/// Recreates `prototype/screens/stream-reconnecting-state.html`.
///
/// In Phase B the streaming layer transitions the live-player into this
/// state when the Chime audio session reports a disconnect. For F4 we
/// expose it as a directly-navigable route so the visual + interaction
/// pattern can be reviewed without a real network drop.
class StreamReconnectingScreen extends ConsumerStatefulWidget {
  const StreamReconnectingScreen({super.key});

  @override
  ConsumerState<StreamReconnectingScreen> createState() =>
      _StreamReconnectingScreenState();
}

class _StreamReconnectingScreenState
    extends ConsumerState<StreamReconnectingScreen>
    with TickerProviderStateMixin {
  bool _toastVisible = true;
  int _secondsReconnecting = 3;
  late final AnimationController _spin;
  late final AnimationController _pingRing;
  late final AnimationController _indeterminate;
  late final AnimationController _secondsTicker;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pingRing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _indeterminate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _secondsTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener(_onSecondTick);
    _secondsTicker.forward();
  }

  void _onSecondTick(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _secondsReconnecting++);
    _secondsTicker.forward(from: 0);
  }

  @override
  void dispose() {
    _spin.dispose();
    _pingRing.dispose();
    _indeterminate.dispose();
    _secondsTicker
      ..removeStatusListener(_onSecondTick)
      ..dispose();
    super.dispose();
  }

  void _retryNow() {
    final masjid = ref.read(preferredMasjidProvider).valueOrNull;
    final streamId = masjid?.currentStreamId;
    if (streamId == null) {
      _minimize();
      return;
    }
    context.goNamed(
      ListenerRoute.nameLivePlayer,
      pathParameters: <String, String>{'streamId': streamId},
    );
  }

  void _minimize() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameHomeListener);
    }
  }

  void _info(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final masjid = ref.watch(preferredMasjidProvider).valueOrNull;
    final masjidName = masjid?.name ?? 'Masjid';
    final muadhinName = masjid != null
        ? ref
                .watch(streamByIdProvider(masjid.currentStreamId ?? '_'))
                .valueOrNull
                ?.muadhinName ??
            'Muadhin'
        : 'Muadhin';
    final city = masjid?.city ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.purpleDeep,
              AppColors.bgDeepNight,
              AppColors.bgDeepNight,
            ],
            stops: <double>[0, 0.6, 1],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _DottedAura()),
            SafeArea(
              child: Column(
                children: <Widget>[
                  if (_toastVisible)
                    _NetworkChangedToast(
                      onClose: () => setState(() => _toastVisible = false),
                    ),
                  _TopBar(
                    secondsReconnecting: _secondsReconnecting,
                    onMinimize: _minimize,
                    spinController: _spin,
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.containerMargin,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _DimmedOrb(pingRing: _pingRing),
                            const SizedBox(height: 32),
                            _Info(
                              masjidName: masjidName,
                              muadhinName: muadhinName,
                              city: city,
                              indeterminate: _indeterminate,
                            ),
                          ],
                        ),
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
                    child: Column(
                      children: <Widget>[
                        const _FrozenWaveform(),
                        const SizedBox(height: 24),
                        _Controls(
                          onVolume: () => _info('Volume control lands in B4.'),
                          onRetry: _retryNow,
                          onShare: () =>
                              _info('Share sheet arrives in F4 polish.'),
                        ),
                        const SizedBox(height: 16),
                        const _SignalCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dotted aura background
// ─────────────────────────────────────────────────────────────────────────────

class _DottedAura extends StatelessWidget {
  const _DottedAura();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _DottedAuraPainter()),
    );
  }
}

class _DottedAuraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08);
    const spacing = 40.0;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DottedAuraPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Toast — "Network changed · Reconnecting from Wi-Fi to 4G"
// ─────────────────────────────────────────────────────────────────────────────

class _NetworkChangedToast extends StatelessWidget {
  const _NetworkChangedToast({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        16,
        AppSpacing.containerMargin,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warningAmberBg.withValues(alpha: 0.9),
          borderRadius: AppRadii.fullAll,
          border: Border.all(
            color: AppColors.warningAmber.withValues(alpha: 0.2),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Symbols.wifi_off_rounded,
              color: AppColors.warningAmber,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Network changed · Reconnecting from Wi-Fi to 4G',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.warningAmber,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Material(
              color: Colors.transparent,
              borderRadius: AppRadii.fullAll,
              child: InkWell(
                onTap: onClose,
                borderRadius: AppRadii.fullAll,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Symbols.close_rounded,
                    color: AppColors.warningAmber,
                    size: 18,
                  ),
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
// Top bar — Minimize + amber Reconnecting chip with spinner
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.secondsReconnecting,
    required this.onMinimize,
    required this.spinController,
  });
  final int secondsReconnecting;
  final VoidCallback onMinimize;
  final AnimationController spinController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        12,
        AppSpacing.containerMargin,
        16,
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
                      'MINIMIZE',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.inkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warningAmberBg,
              borderRadius: AppRadii.fullAll,
              border: Border.all(
                color: AppColors.warningAmber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedBuilder(
                  animation: spinController,
                  builder: (context, _) => Transform.rotate(
                    angle: spinController.value * 6.283,
                    child: const Icon(
                      Symbols.sync_rounded,
                      color: AppColors.warningAmber,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'RECONNECTING · ${secondsReconnecting}s',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.warningAmber,
                    fontWeight: FontWeight.w700,
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
// Dimmed orb with pulsing amber ping ring
// ─────────────────────────────────────────────────────────────────────────────

class _DimmedOrb extends StatelessWidget {
  const _DimmedOrb({required this.pingRing});
  final AnimationController pingRing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Pulsing amber ring (animate-ping equivalent)
          AnimatedBuilder(
            animation: pingRing,
            builder: (context, _) {
              final t = pingRing.value;
              return Container(
                width: 210 + (110 * t),
                height: 210 + (110 * t),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warningAmber.withValues(
                      alpha: (1 - t) * 0.4,
                    ),
                    width: 3,
                  ),
                ),
              );
            },
          ),
          // Steady outer amber ring
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warningAmber.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          // Rotated double octagonal frame
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.goldDeep.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.goldDeep.withValues(alpha: 0.4),
              ),
            ),
          ),
          // The dimmed 210 px orb
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.goldHighlight,
                  AppColors.primary,
                  AppColors.goldDeep,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Opacity(
              opacity: 0.5,
              child: CustomPaint(
                painter: _OrbStipplePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbStipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.2);
    const spacing = 8.0;
    final r = math.min(size.width, size.height) / 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy <= r * r) {
          canvas.drawCircle(Offset(x, y), 1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_OrbStipplePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Info block — Masjid name + status + indeterminate amber progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _Info extends StatelessWidget {
  const _Info({
    required this.masjidName,
    required this.muadhinName,
    required this.city,
    required this.indeterminate,
  });
  final String masjidName;
  final String muadhinName;
  final String city;
  final AnimationController indeterminate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          masjidName,
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.inkPrimary,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          city.isEmpty
              ? 'Muadhin: $muadhinName'
              : 'Muadhin: $muadhinName · $city',
          style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: 20),
        Text(
          'Connection unstable — retrying with exponential backoff',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.warningAmber.withValues(alpha: 0.9),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 200,
          height: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: <Widget>[
                Container(
                  color: AppColors.warningAmber.withValues(alpha: 0.2),
                ),
                AnimatedBuilder(
                  animation: indeterminate,
                  builder: (context, _) {
                    final t = indeterminate.value;
                    // Bar slides left-to-right, then loops.
                    final leftFrac = (t * 1.4) - 0.4;
                    return FractionalTranslation(
                      translation: Offset(leftFrac, 0),
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        alignment: Alignment.centerLeft,
                        child: Container(color: AppColors.warningAmber),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Frozen waveform (muted grey, no animation — audio is paused)
// ─────────────────────────────────────────────────────────────────────────────

class _FrozenWaveform extends StatelessWidget {
  const _FrozenWaveform();

  static const _heights = <double>[
    16, 12, 24, 16, 32, 20, 12, 28, 16, 24, 12, 20, 28,
    16, 32, 24, 12, 20, 16, 24, 8, 20, 28, 16,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (var i = 0; i < _heights.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 3),
            SizedBox(
              width: 1.5,
              child: Container(
                height: _heights[i],
                color: AppColors.inkMuted.withValues(alpha: 0.3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controls — Volume / Retry now / Share
// ─────────────────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({
    required this.onVolume,
    required this.onRetry,
    required this.onShare,
  });
  final VoidCallback onVolume;
  final VoidCallback onRetry;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _CircleButton(icon: Symbols.volume_up_rounded, onTap: onVolume),
        _RetryButton(onTap: onRetry),
        _CircleButton(icon: Symbols.share_rounded, onTap: onShare),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.inkMuted, size: 28),
        ),
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  const _RetryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Retry now',
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

// ─────────────────────────────────────────────────────────────────────────────
// Glass signal card
// ─────────────────────────────────────────────────────────────────────────────

class _SignalCard extends StatelessWidget {
  const _SignalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.5),
        borderRadius: AppRadii.heroAll,
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
              shape: BoxShape.circle,
              color: AppColors.warningAmberBg,
            ),
            child: const Icon(
              Symbols.warning_rounded,
              color: AppColors.warningAmber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'SIGNAL · WEBRTC',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.inkMuted,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '⚠ Switching to HLS fallback',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.warningAmber,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'LATENCY',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.inkMuted,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '-- ms',
                style: AppTypography.numeralTime.copyWith(
                  color: AppColors.inkPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
