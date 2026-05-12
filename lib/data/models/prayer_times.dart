enum Prayer { fajr, dhuhr, asr, maghrib, isha }

class PrayerTimes {
  const PrayerTimes({required this.date, required this.times});

  final DateTime date;
  final Map<Prayer, DateTime> times;

  Prayer currentAt(DateTime now) {
    Prayer current = Prayer.isha;
    for (final p in Prayer.values) {
      final t = times[p];
      if (t != null && !now.isBefore(t)) current = p;
    }
    return current;
  }

  Prayer nextAt(DateTime now) {
    for (final p in Prayer.values) {
      final t = times[p];
      if (t != null && now.isBefore(t)) return p;
    }
    return Prayer.fajr;
  }

  Duration toNextAt(DateTime now) {
    final next = nextAt(now);
    final t = times[next]!;
    return t.isAfter(now)
        ? t.difference(now)
        : t.add(const Duration(days: 1)).difference(now);
  }

  Prayer get current => currentAt(DateTime.now());
  Prayer get next => nextAt(DateTime.now());
  Duration get toNext => toNextAt(DateTime.now());
}
