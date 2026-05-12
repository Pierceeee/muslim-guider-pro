import '../models/prayer_times.dart';

abstract class ScheduleRepository {
  PrayerTimes forDate(DateTime date, {required String masjidId});
}
