import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';

class QiblaService {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  /// Qibla bearing relative to device heading, in [0..360).
  /// Returns an empty stream on platforms without a magnetometer.
  Stream<double> bearingFor({required double userLat, required double userLng}) {
    final events = FlutterCompass.events;
    if (events == null) return const Stream<double>.empty();
    final qiblaFromNorth = greatCircleBearing(
      userLat: userLat, userLng: userLng,
      destLat: _kaabaLat, destLng: _kaabaLng,
    );
    return events.map((e) {
      final heading = e.heading ?? 0;
      return (qiblaFromNorth - heading + 360) % 360;
    });
  }

  /// Great-circle initial bearing from user→dest, degrees clockwise from true North.
  static double greatCircleBearing({
    required double userLat,
    required double userLng,
    required double destLat,
    required double destLng,
  }) {
    final phi1 = userLat * math.pi / 180;
    final phi2 = destLat * math.pi / 180;
    final dLambda = (destLng - userLng) * math.pi / 180;
    final y = math.sin(dLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLambda);
    return ((math.atan2(y, x) * 180 / math.pi) + 360) % 360;
  }
}
