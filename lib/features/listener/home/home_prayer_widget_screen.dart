import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/prayer_times.dart';
import '../../../data/providers/listener_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/home-prayer-widget.html` — the compass-style
/// "watch face" home variant.
///
/// The prototype composites a stack of bundled SVGs (gold rim, conic prayer
/// arcs, sky scene, qibla pointer, adhan badge) which aren't in our asset
/// bundle yet. We approximate the same composition procedurally via
/// `CustomPainter`s so the screen ships now and drops in real SVG assets
/// later without restructuring the layout.
///
/// Data:
///   • `todaysPrayerScheduleProvider` — drives all prayer windows + countdown
///   • A 1 Hz `Timer.periodic` rebuilds the time/date/countdown each second
class HomePrayerWidgetScreen extends ConsumerStatefulWidget {
  const HomePrayerWidgetScreen({super.key});

  @override
  ConsumerState<HomePrayerWidgetScreen> createState() =>
      _HomePrayerWidgetScreenState();
}

class _HomePrayerWidgetScreenState
    extends ConsumerState<HomePrayerWidgetScreen> {
  DateTime _now = DateTime.now();
  Timer? _ticker;

  static const _bg = Color(0xFF131B26);

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(todaysPrayerScheduleProvider);
    final schedule = scheduleAsync.valueOrNull;
    final active = schedule == null ? null : _activeWindow(schedule, _now);
    final next = schedule == null ? null : _nextPrayer(schedule, _now);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _BackgroundPattern()),
            ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: <Widget>[
                _TopBar(
                  onAvatarTap: () =>
                      context.goNamed(ListenerRoute.nameProfile),
                ),
                const SizedBox(height: 6),
                _TimeBlock(now: _now),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _CompassWithSideCard(
                    schedule: schedule,
                    active: active,
                    onAdhanTap: _openAdhan,
                  ),
                ),
                const SizedBox(height: 32),
                _Countdown(
                  next: next,
                  now: _now,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Icon(
                    Symbols.keyboard_double_arrow_up_rounded,
                    color: const Color(0xFFDFC16D).withValues(alpha: 0.8),
                    size: 26,
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.nameHomePrayerWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAdhan() {
    // Prefer the user's preferred masjid if it's currently broadcasting; fall
    // back to the nearby-masjids discovery surface so the tap is never a no-op.
    final masjid = ref.read(preferredMasjidProvider).valueOrNull;
    final streamId = masjid?.currentStreamId;
    if (streamId != null) {
      context.goNamed(
        ListenerRoute.nameLivePlayer,
        pathParameters: <String, String>{'streamId': streamId},
      );
      return;
    }
    context.goNamed(ListenerRoute.nameNearbyMasjids);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer-window derivation
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerWindow {
  const _PrayerWindow({
    required this.name,
    required this.from,
    required this.to,
  });
  final String name;
  final DateTime from;
  final DateTime to;
}

_PrayerWindow? _activeWindow(PrayerTimes s, DateTime now) {
  // Prayer windows used for display:
  //   Fajr     fajr → sunrise
  //   Dhuhr    dhuhr → asr
  //   Asr      asr → maghrib
  //   Maghrib  maghrib → isha
  //   Isha     isha → fajr(next-day)
  final tomorrowFajr = s.fajr.add(const Duration(days: 1));
  final windows = <_PrayerWindow>[
    _PrayerWindow(name: 'Fajr', from: s.fajr, to: s.sunrise),
    _PrayerWindow(name: 'Dhuhr', from: s.dhuhr, to: s.asr),
    _PrayerWindow(name: 'Asr', from: s.asr, to: s.maghrib),
    _PrayerWindow(name: 'Maghrib', from: s.maghrib, to: s.isha),
    _PrayerWindow(name: 'Isha', from: s.isha, to: tomorrowFajr),
  ];
  for (final w in windows) {
    if (!now.isBefore(w.from) && now.isBefore(w.to)) return w;
  }
  return null;
}

({String name, DateTime time}) _nextPrayer(PrayerTimes s, DateTime now) {
  final ordered = <(String, DateTime)>[
    ('Fajr', s.fajr),
    ('Dhuhr', s.dhuhr),
    ('Asr', s.asr),
    ('Maghrib', s.maghrib),
    ('Isha', s.isha),
  ];
  for (final entry in ordered) {
    if (entry.$2.isAfter(now)) {
      return (name: entry.$1, time: entry.$2);
    }
  }
  return (name: 'Fajr', time: s.fajr.add(const Duration(days: 1)));
}

// ─────────────────────────────────────────────────────────────────────────────
// Background pattern
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _BackgroundPainter()),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Faint repeating diamond pattern in gold/4%.
    final paint = Paint()
      ..color = const Color(0xFFDFC16D).withValues(alpha: 0.04);
    const spacing = 32.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — profile avatar (right)
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onAvatarTap});
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        12,
        AppSpacing.containerMargin,
        4,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: const Color(0xFF111724).withValues(alpha: 0.9),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onAvatarTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Symbols.person_rounded,
                color: AppColors.primary,
                size: 28,
                fill: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time + date stack
// ─────────────────────────────────────────────────────────────────────────────

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({required this.now});
  final DateTime now;

  static const _goldText = Color(0xFFDAC174);

  String _fmtTime(DateTime n) {
    var hour12 = n.hour % 12;
    if (hour12 == 0) hour12 = 12;
    return '${hour12.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  String _amPm(DateTime n) => n.hour < 12 ? 'AM' : 'PM';

  String _fmtDate(DateTime n) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${months[n.month - 1]} ${n.day}, ${n.year} - ${weekdays[n.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              _fmtTime(now),
              style: AppTypography.headlineXl.copyWith(
                color: _goldText,
                fontSize: 52,
                height: 1,
                shadows: <Shadow>[
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _amPm(now),
                style: AppTypography.headlineMd.copyWith(
                  color: _goldText,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _fmtDate(now),
          textAlign: TextAlign.center,
          style: AppTypography.bodyLg.copyWith(
            color: _goldText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            shadows: <Shadow>[
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compass widget + attached side card
// ─────────────────────────────────────────────────────────────────────────────

class _CompassWithSideCard extends StatelessWidget {
  const _CompassWithSideCard({
    required this.schedule,
    required this.active,
    required this.onAdhanTap,
  });
  final PrayerTimes? schedule;
  final _PrayerWindow? active;
  final VoidCallback onAdhanTap;

  String _fmt(DateTime t) {
    var hour12 = t.hour % 12;
    if (hour12 == 0) hour12 = 12;
    return '${hour12.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      height: 420,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Attached side card (left edge, top)
          if (active != null)
            Positioned(
              left: 0,
              top: 8,
              child: _SideCard(
                title: '${active!.name} Time',
                from: _fmt(active!.from),
                to: _fmt(active!.to),
              ),
            ),
          // Compass (centered, below the side card overhang)
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: _PrayerCompass(
                schedule: schedule,
                activeName: active?.name,
              ),
            ),
          ),
          // Adhan badge floating bottom-left of the compass
          Positioned(
            bottom: 20,
            left: 24,
            child: _AdhanBadge(onTap: onAdhanTap),
          ),
        ],
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.title,
    required this.from,
    required this.to,
  });
  final String title;
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF51768E),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF729DBB).withValues(alpha: 0.3),
          ),
          right: BorderSide(
            color: const Color(0xFF729DBB).withValues(alpha: 0.3),
          ),
          bottom: BorderSide(
            color: const Color(0xFF729DBB).withValues(alpha: 0.3),
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: AppTypography.labelCaps.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'From — $from',
            style: AppTypography.labelCaps.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'To — $to',
            style: AppTypography.labelCaps.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The compass itself (procedural)
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerCompass extends StatelessWidget {
  const _PrayerCompass({required this.schedule, required this.activeName});
  final PrayerTimes? schedule;
  final String? activeName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Procedural compass ring with prayer arcs
          CustomPaint(
            size: const Size(340, 340),
            painter: _CompassRingPainter(
              schedule: schedule,
              activeName: activeName,
            ),
          ),
          // Inner sky disc
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.1,
                colors: <Color>[
                  Color(0xFFE8763A),
                  Color(0xFF5B2C9F),
                  Color(0xFF181A1F),
                ],
                stops: <double>[0.0, 0.5, 1.0],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Gold sphere (sun/moon) — moves in real impl; static for v1
                Positioned(
                  top: 36,
                  left: 64,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: <Color>[
                          Color(0xFFFFE08A),
                          Color(0xFFD4A537),
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                // Centered mosque icon
                const Icon(
                  Symbols.mosque_rounded,
                  color: Color(0xFFEAD9A0),
                  size: 48,
                  fill: 1,
                ),
              ],
            ),
          ),
          // Qibla pointer at top
          Positioned(
            top: 4,
            child: CustomPaint(
              size: const Size(22, 18),
              painter: _QiblaArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  _CompassRingPainter({required this.schedule, required this.activeName});
  final PrayerTimes? schedule;
  final String? activeName;

  static const _activeColor = Color(0xFF57D4E8);
  static const _upcomingColor = Color(0xFF35657D);
  static const _pastColor = Color(0xFF434E52);
  static const _emptyColor = Color(0xFF0F1011);
  static const _goldColor = Color(0xFFDAA03C);
  static const _outerRimColor = Color(0xFFD4A537);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.62; // hole radius

    // Outer dark filling
    final fillPaint = Paint()..color = const Color(0xFF0F1011);
    canvas.drawCircle(Offset(cx, cy), outerR, fillPaint);

    // 5 prayer windows mapped to 5 arc segments (72° each starting at top).
    final names = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    const segmentAngle = math.pi * 2 / 5;
    for (var i = 0; i < names.length; i++) {
      final name = names[i];
      final startAngle = -math.pi / 2 + (segmentAngle * i);
      final color = _colorFor(name);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(rect, startAngle, segmentAngle, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Inner mask: punch out a circle so segments form a ring.
    canvas.drawCircle(Offset(cx, cy), innerR, fillPaint);

    // Outer rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _outerRimColor;
    canvas.drawCircle(Offset(cx, cy), outerR - 1, rimPaint);

    // Inner rim
    canvas.drawCircle(
      Offset(cx, cy),
      innerR + 1,
      rimPaint..color = _outerRimColor.withValues(alpha: 0.6),
    );

    // 5 gold separator lines between segments
    final sepPaint = Paint()
      ..color = _goldColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (segmentAngle * i);
      final sx = cx + math.cos(angle) * (innerR + 2);
      final sy = cy + math.sin(angle) * (innerR + 2);
      final ex = cx + math.cos(angle) * (outerR - 2);
      final ey = cy + math.sin(angle) * (outerR - 2);
      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), sepPaint);
    }

    // Tick marks every 30° outside the outer rim (subtle)
    final tickPaint = Paint()
      ..color = const Color(0xFFD4A537).withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 12; i++) {
      final a = (i * math.pi / 6) - math.pi / 2;
      final s = Offset(
        cx + math.cos(a) * (outerR + 2),
        cy + math.sin(a) * (outerR + 2),
      );
      final e = Offset(
        cx + math.cos(a) * (outerR + 8),
        cy + math.sin(a) * (outerR + 8),
      );
      canvas.drawLine(s, e, tickPaint);
    }
  }

  Color _colorFor(String name) {
    if (activeName == null) return _pastColor;
    final order = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final activeIdx = order.indexOf(activeName!);
    final mineIdx = order.indexOf(name);
    if (mineIdx == activeIdx) return _activeColor;
    if (mineIdx == (activeIdx + 1) % 5) return _upcomingColor;
    if (mineIdx == (activeIdx + 2) % 5) return _emptyColor;
    return _pastColor;
  }

  @override
  bool shouldRepaint(_CompassRingPainter old) =>
      old.activeName != activeName || old.schedule != schedule;
}

class _QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDFC16D)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_QiblaArrowPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Adhan badge — floating circular button
// ─────────────────────────────────────────────────────────────────────────────

class _AdhanBadge extends StatelessWidget {
  const _AdhanBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF111724),
            border: Border.all(
              color: const Color(0xFFD4A537).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFE1B354), Color(0xFFC18C2F)],
                ),
                border: Border.all(color: const Color(0xFFB5832A)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Icon(
                Symbols.campaign_rounded,
                color: Color(0xFF402D00),
                size: 30,
                fill: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Countdown to next prayer
// ─────────────────────────────────────────────────────────────────────────────

class _Countdown extends StatelessWidget {
  const _Countdown({required this.next, required this.now});
  final ({String name, DateTime time})? next;
  final DateTime now;

  String _fmtRemaining(Duration d) {
    if (d.isNegative) return '00:00';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (next == null) {
      return Column(
        children: <Widget>[
          Container(
            width: 100,
            height: 18,
            color: const Color(0xFFDFC16D).withValues(alpha: 0.15),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading prayer schedule…',
            style: AppTypography.bodyMd.copyWith(
              color: const Color(0xFFA79462),
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    final remaining = next!.time.difference(now);
    return Column(
      children: <Widget>[
        Text(
          _fmtRemaining(remaining),
          style: AppTypography.numeralTime.copyWith(
            color: const Color(0xFFDFC16D),
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Time Remaining for Prayer: ',
              style: AppTypography.bodyMd.copyWith(
                color: const Color(0xFFA79462),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              next!.name,
              style: AppTypography.bodyMd.copyWith(
                color: const Color(0xFFDFC16D),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
