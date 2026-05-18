import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../models/prayer_times.dart' as model;

class PrayerTimeService {
  /// Computes prayer times for the given date + coordinates.
  ///
  /// Throws [StateError] if adhan_dart throws (e.g. invalid coordinates or
  /// polar-latitude edge cases where computation fails).
  model.PrayerTimes compute({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    try {
      final coords = adhan.Coordinates(latitude, longitude);
      // TODO(future): make calculation method + madhab per-masjid configurable.
      final params = adhan.CalculationMethodParameters.muslimWorldLeague();
      params.madhab = adhan.Madhab.shafi;
      final pt = adhan.PrayerTimes(
        date: DateTime(date.year, date.month, date.day),
        coordinates: coords,
        calculationParameters: params,
      );
      return model.PrayerTimes(
        date: DateTime(date.year, date.month, date.day),
        times: {
          model.Prayer.fajr: pt.fajr.toLocal(),
          model.Prayer.dhuhr: pt.dhuhr.toLocal(),
          model.Prayer.asr: pt.asr.toLocal(),
          model.Prayer.maghrib: pt.maghrib.toLocal(),
          model.Prayer.isha: pt.isha.toLocal(),
        },
      );
    } catch (e) {
      throw StateError(
          'adhan_dart failed for coords ($latitude, $longitude): $e');
    }
  }
}
