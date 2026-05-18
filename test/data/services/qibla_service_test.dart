import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/services/qibla_service.dart';

void main() {
  test('great-circle bearing London → Mecca is ~119°', () {
    final b = QiblaService.greatCircleBearing(
      userLat: 51.5074, userLng: -0.1278,
      destLat: 21.4225, destLng: 39.8262,
    );
    expect(b, closeTo(118.99, 0.5));
  });

  test('great-circle bearing New York → Mecca is ~58°', () {
    final b = QiblaService.greatCircleBearing(
      userLat: 40.7128, userLng: -74.0060,
      destLat: 21.4225, destLng: 39.8262,
    );
    expect(b, closeTo(58.48, 0.5));
  });

  test('bearing from Mecca to itself is degenerate (~0 or ~360)', () {
    final b = QiblaService.greatCircleBearing(
      userLat: 21.4225, userLng: 39.8262,
      destLat: 21.4225, destLng: 39.8262,
    );
    // Either ~0 or ~360 depending on epsilon — both are correct degenerate values.
    expect(b < 1 || b > 359, isTrue);
  });
}
