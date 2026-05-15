import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'prayer_segments_painter.dart';

class PrayerWidget extends StatelessWidget {
  const PrayerWidget({
    super.key,
    this.size = 380,
    this.qiblaAngleDeg = 35,
    this.skyAsset = 'assets/svg/middle_circle/CLOUDY_SUNSET.svg',
  });

  final double size;
  final double qiblaAngleDeg;
  final String skyAsset;

  double _s(double n) => size * (n / 380);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // L1: outer ornate frame
          SvgPicture.asset('assets/svg/main_circle.svg', width: size),
          // L2: inner gold rim
          Opacity(
            opacity: 0.9,
            child: SvgPicture.asset('assets/svg/circle.svg', width: _s(370)),
          ),
          // L3: dark ring fill
          Container(
            width: _s(330),
            height: _s(330),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F1011)),
          ),
          // L4: colored segments + gold separators
          SizedBox.square(
            dimension: _s(330),
            child: const CustomPaint(painter: PrayerSegmentsPainter()),
          ),
          // L5: thin inner solid rim
          Opacity(
            opacity: 0.9,
            child: Container(
              width: _s(301),
              height: _s(301),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF111317)),
            ),
          ),
          // L6: sky scene + Qibla compass + gold dot
          ClipOval(
            child: SizedBox.square(
              dimension: _s(240),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(skyAsset, fit: BoxFit.cover),
                  Transform.rotate(
                    angle: qiblaAngleDeg * math.pi / 180,
                    child: SvgPicture.asset('assets/svg/qibla_direction.svg', width: _s(220)),
                  ),
                  Positioned(
                    left: _s(95),
                    top: _s(42.5),
                    child: SvgPicture.asset('assets/svg/gold.svg', width: 16, height: 16),
                  ),
                ],
              ),
            ),
          ),
          // L7a: floating adhan badge (bottom-left)
          Positioned(
            left: _s(15),
            bottom: _s(20),
            width: _s(110),
            height: _s(110),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset('assets/svg/prayer_call_button.svg'),
                Container(
                  width: _s(60),
                  height: _s(60),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE1B354), Color(0xFFC18C2F)],
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/adan.svg',
                      width: _s(28),
                      height: _s(28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // L7b: top Qibla pointer (Amendment 5 — _s() scaling + explicit left)
          Positioned(
            top: _s(8),
            left: size / 2 - _s(10),
            child: Transform.rotate(
              angle: math.pi,
              child: SvgPicture.asset('assets/svg/qibla_direction.svg', width: _s(20), height: _s(16)),
            ),
          ),
        ],
      ),
    );
  }
}
