import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Smooth quadratic Bezier retention curve over [samples] (each 0..1).
/// Default samples produce the prototype's reference shape:
///   [1.0, 0.6, 0.4, 0.25, 0.15, 0.1, 0.05]
class RetentionChart extends StatelessWidget {
  const RetentionChart({
    super.key,
    this.samples = const [1.0, 0.6, 0.4, 0.25, 0.15, 0.1, 0.05],
    this.height = 128,
  });

  final List<double> samples;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _RetentionPainter(samples)),
    );
  }
}

class _RetentionPainter extends CustomPainter {
  _RetentionPainter(this.samples);
  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    // 3 horizontal grid lines at 25 / 50 / 75% of height
    final gridPaint = Paint()
      ..color = AppColors.inkMuted.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (final pct in [0.25, 0.5, 0.75]) {
      final y = size.height * pct;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Map each sample to an (x, y) point. y is inverted (1.0 = top, 0.0 = bottom).
    final points = <Offset>[];
    for (var i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      final y = (1.0 - samples[i].clamp(0.0, 1.0)) * size.height;
      points.add(Offset(x, y));
    }

    // Quadratic spline through midpoints (Catmull-Rom-ish smoothing using
    // quadraticBezierTo with the next point as the control point).
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;
      path.quadraticBezierTo(current.dx, current.dy, midX, midY);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Endpoint dots — small filled circles at start, middle, and end
    final dotPaint = Paint()..color = AppColors.primary;
    final dotIndices = [
      0,
      points.length ~/ 2,
      points.length - 1,
    ];
    for (final i in dotIndices) {
      canvas.drawCircle(points[i], 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RetentionPainter old) {
    if (old.samples.length != samples.length) return true;
    for (var i = 0; i < samples.length; i++) {
      if (old.samples[i] != samples[i]) return true;
    }
    return false;
  }
}
