import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/prayer_times.dart';
import 'repository_providers.dart';

@immutable
class PrayerTimesArg {
  const PrayerTimesArg({required this.date, required this.masjidId});
  final DateTime date;
  final String masjidId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerTimesArg &&
          other.date == date &&
          other.masjidId == masjidId);

  @override
  int get hashCode => Object.hash(date, masjidId);
}

final prayerTimesProvider =
    Provider.family<PrayerTimes, PrayerTimesArg>((ref, arg) {
  return ref
      .watch(scheduleRepositoryProvider)
      .forDate(arg.date, masjidId: arg.masjidId);
});
