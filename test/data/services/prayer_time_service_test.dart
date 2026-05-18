import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/prayer_times.dart';
import 'package:muslim_guider_pro/data/services/prayer_time_service.dart';

void main() {
  final service = PrayerTimeService();
  const meccaLat = 21.4225;
  const meccaLng = 39.8262;
  final testDate = DateTime(2026, 5, 16);

  group('PrayerTimeService.compute (Mecca)', () {
    late PrayerTimes result;

    setUpAll(() {
      result = service.compute(
        date: testDate,
        latitude: meccaLat,
        longitude: meccaLng,
      );
    });

    test('returns times for all five prayers', () {
      expect(result.times.length, 5);
      for (final prayer in Prayer.values) {
        expect(result.times.containsKey(prayer), isTrue,
            reason: '${prayer.name} should be present');
      }
    });

    test('prayer times are in the correct order (Fajr < Dhuhr < Asr < Maghrib < Isha)', () {
      final fajr    = result.times[Prayer.fajr]!;
      final dhuhr   = result.times[Prayer.dhuhr]!;
      final asr     = result.times[Prayer.asr]!;
      final maghrib = result.times[Prayer.maghrib]!;
      final isha    = result.times[Prayer.isha]!;

      expect(fajr.isBefore(dhuhr),   isTrue, reason: 'Fajr must be before Dhuhr');
      expect(dhuhr.isBefore(asr),    isTrue, reason: 'Dhuhr must be before Asr');
      expect(asr.isBefore(maghrib),  isTrue, reason: 'Asr must be before Maghrib');
      expect(maghrib.isBefore(isha), isTrue, reason: 'Maghrib must be before Isha');
    });

    test('all times fall within a 24-hour window', () {
      final dayStart = DateTime(testDate.year, testDate.month, testDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      for (final entry in result.times.entries) {
        final t = entry.value;
        expect(
          t.isAfter(dayStart.subtract(const Duration(hours: 12))) &&
              t.isBefore(dayEnd.add(const Duration(hours: 12))),
          isTrue,
          reason: '${entry.key.name} time $t is outside expected range',
        );
      }
    });

    test('date on result matches requested date', () {
      expect(result.date.year,  testDate.year);
      expect(result.date.month, testDate.month);
      expect(result.date.day,   testDate.day);
    });
  });

  test('compute throws StateError for out-of-range coordinates', () {
    // adhan_dart asserts latitude in [-90, 90] and longitude in [-180, 180];
    // passing values outside these bounds should produce a StateError.
    expect(
      () => service.compute(date: testDate, latitude: 91.0, longitude: 0.0),
      throwsA(isA<StateError>()),
    );
  });
}
