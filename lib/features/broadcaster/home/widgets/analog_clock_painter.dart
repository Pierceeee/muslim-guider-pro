import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AnalogClockPainter extends CustomPainter {
  AnalogClockPainter({required this.rotation});

  final double rotation; // 0..2π for slow gold-ring rotation

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.borderMedium;
    canvas.drawCircle(center, radius - 4, outerRing);

    final goldArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.primary;
    final arcRect = Rect.fromCircle(center: center, radius: radius - 12);
    canvas.drawArc(arcRect, rotation, math.pi / 4, false, goldArc);

    final tickPaint = Paint()..color = AppColors.inkMuted;
    for (var i = 0; i < 60; i++) {
      final angle = i * (math.pi * 2 / 60);
      final isHour = i % 5 == 0;
      final inner = radius - (isHour ? 18 : 12);
      final outer = radius - 6;
      final p1 = center + Offset(math.cos(angle), math.sin(angle)) * inner;
      final p2 = center + Offset(math.cos(angle), math.sin(angle)) * outer;
      canvas.drawLine(p1, p2, tickPaint..strokeWidth = isHour ? 2 : 1);
    }

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.primary, AppColors.bgDeepNight],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.25));
    canvas.drawCircle(center, radius * 0.22, corePaint);

    final planetAngle = rotation * 2;
    final planet = center +
        Offset(math.cos(planetAngle), math.sin(planetAngle)) * (radius * 0.18);
    canvas.drawCircle(planet, 4, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter old) =>
      old.rotation != rotation;
}
