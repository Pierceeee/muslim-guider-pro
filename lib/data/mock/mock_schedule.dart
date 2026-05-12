import '../models/prayer_times.dart';

/// Birmingham fixture schedule used by the v1 mock repository.
///
/// Computed against TODAY at every access so "next prayer" logic in the
/// dashboard always has live, comparable timestamps. Real geo-aware
/// computation lands in B5 (`adhan` package + user location).
PrayerTimes get mockBirminghamSchedule {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int hour, int minute) =>
      DateTime(now.year, now.month, now.day, hour, minute);

  return PrayerTimes(
    date: today,
    locationName: 'Birmingham, UK',
    method: CalculationMethod.mwl,
    fajr: at(5, 12),
    sunrise: at(6, 38),
    dhuhr: at(12, 45),
    asr: at(15, 47),
    maghrib: at(18, 12),
    isha: at(19, 34),
  );
}
