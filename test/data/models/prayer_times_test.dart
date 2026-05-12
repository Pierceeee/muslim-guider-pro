import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/prayer_times.dart';

void main() {
  final date = DateTime(2026, 5, 13);
  final times = PrayerTimes(date: date, times: {
    Prayer.fajr:    DateTime(2026, 5, 13, 4, 30),
    Prayer.dhuhr:   DateTime(2026, 5, 13, 12, 30),
    Prayer.asr:     DateTime(2026, 5, 13, 16, 0),
    Prayer.maghrib: DateTime(2026, 5, 13, 19, 30),
    Prayer.isha:    DateTime(2026, 5, 13, 21, 0),
  });

  test('current returns latest passed prayer at 14:00', () {
    expect(times.currentAt(DateTime(2026, 5, 13, 14, 0)), Prayer.dhuhr);
  });

  test('next returns the next upcoming prayer at 14:00', () {
    expect(times.nextAt(DateTime(2026, 5, 13, 14, 0)), Prayer.asr);
  });

  test('toNext returns the duration from now to next prayer', () {
    final d = times.toNextAt(DateTime(2026, 5, 13, 14, 0));
    expect(d, const Duration(hours: 2));
  });
}
