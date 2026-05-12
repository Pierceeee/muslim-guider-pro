import '../models/prayer_times.dart';

PrayerTimes mockPrayerTimesFor(DateTime date) {
  final base = DateTime(date.year, date.month, date.day);
  return PrayerTimes(
    date: base,
    times: {
      Prayer.fajr:    base.add(const Duration(hours: 4,  minutes: 30)),
      Prayer.dhuhr:   base.add(const Duration(hours: 12, minutes: 30)),
      Prayer.asr:     base.add(const Duration(hours: 16, minutes: 0)),
      Prayer.maghrib: base.add(const Duration(hours: 19, minutes: 30)),
      Prayer.isha:    base.add(const Duration(hours: 21, minutes: 0)),
    },
  );
}
