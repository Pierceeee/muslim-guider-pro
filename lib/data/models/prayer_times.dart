/// Prayer-time calculation methods exposed by the on-device `adhan` package.
/// See `prototype/screens/settings.html` for the prototype's picker UI.
enum CalculationMethod {
  ummAlQura,
  isna,
  mwl,
  egyptian,
  karachi,
  moonsightingCommittee,
}

/// Daily prayer schedule for a given location.
///
/// Times are stored as wall-clock `DateTime`s (local to the user's `timezone`)
/// so the UI never has to do TZ math just to render `15:47`.
class PrayerTimes {
  const PrayerTimes({
    required this.date,
    required this.locationName,
    required this.method,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.jumuah,
  });

  final DateTime date;
  final String locationName;
  final CalculationMethod method;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Optional — non-null on Fridays when the masjid sets an overriding khutbah time.
  final DateTime? jumuah;
}
