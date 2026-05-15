import 'dart:math' as math;
import 'package:flutter/material.dart';

class PrayerSegmentsPainter extends CustomPainter {
  const PrayerSegmentsPainter({this.rotation = 25 * math.pi / 180});
  final double rotation;

  static const _stops = [
    (start: 0.0,   end: 70.0,  color: Color(0xFF0F1011)),
    (start: 70.0,  end: 185.0, color: Color(0xFF434E52)),
    (start: 185.0, end: 315.0, color: Color(0xFF57D4E8)),
    (start: 315.0, end: 360.0, color: Color(0xFF35657D)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerR = size.width / 2;
    final innerR = outerR * (120 / 165);
    final ringRect = Rect.fromCircle(center: center, radius: outerR);
    final layerBounds = Rect.fromCircle(center: center, radius: outerR);

    // Layer 1: rotated colored segments with inner hole punched out.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.saveLayer(layerBounds, Paint());
    final segPaint = Paint()..style = PaintingStyle.fill;
    for (final s in _stops) {
      final startRad = (s.start - 90) * math.pi / 180;
      final sweepRad = (s.end - s.start) * math.pi / 180;
      segPaint.color = s.color;
      canvas.drawArc(ringRect, startRad, sweepRad, true, segPaint);
    }
    canvas.drawCircle(center, innerR, Paint()..blendMode = BlendMode.clear);
    canvas.restore(); // matches saveLayer
    canvas.restore(); // matches rotation save

    // Layer 2: gold separator bars at segment boundaries, on the un-rotated
    // root canvas — but with `rotation` added so they align with the rotated
    // segment edges.
    final goldPaint = Paint()..color = const Color(0xFFDAA03C);
    final scale = size.width / 330;
    final barW = 46.0 * scale;
    final barH = 6.0 * scale;
    for (final angle in [0.0, 70.0, 185.0, 315.0]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((angle * math.pi / 180) + rotation - math.pi / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(outerR - barW, -barH / 2, barW, barH),
          const Radius.circular(1.5),
        ),
        goldPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PrayerSegmentsPainter old) => old.rotation != rotation;
}
