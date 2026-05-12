import '../models/prayer_times.dart';

/// Prayer-time queries. v1 computes locally with the `adhan` package
/// (no backend math needed). The repo abstraction exists so screens
/// don't depend on `adhan` directly — useful for tests and for swapping
/// to a server-authoritative schedule per masjid override later.
abstract class ScheduleRepository {
  /// Daily schedule at a given location.
  Future<PrayerTimes> getDailySchedule({
    required DateTime date,
    required double latitude,
    required double longitude,
    required CalculationMethod method,
  });

  /// The currently-active calculation method for the signed-in user.
  Future<CalculationMethod> getCurrentMethod();

  /// Persist the user's calculation-method choice.
  Future<void> setCurrentMethod(CalculationMethod method);
}
