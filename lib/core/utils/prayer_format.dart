import 'package:intl/intl.dart';

import '../../data/models/prayer_times.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// Formats a [Duration] as `HH:MM`. Zero durations return `--:--`.
String formatHHMM(Duration d) {
  if (d == Duration.zero) return '--:--';
  return '${_two(d.inHours)}:${_two(d.inMinutes.remainder(60))}';
}

/// Human-readable prayer name from a [Prayer] value.
String prayerLabel(Prayer p) {
  return switch (p) {
    Prayer.fajr => 'Fajr',
    Prayer.dhuhr => 'Dhuhr',
    Prayer.asr => 'Asr',
    Prayer.maghrib => 'Maghrib',
    Prayer.isha => 'Isha',
  };
}

/// Formats a [DateTime] as `HH:mm`. Returns `--:--` if [dt] is null.
String formatPrayerTime(DateTime? dt) {
  if (dt == null) return '--:--';
  return DateFormat('HH:mm').format(dt);
}
