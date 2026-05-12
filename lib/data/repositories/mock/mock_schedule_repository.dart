import '../../mock/mock_schedule.dart';
import '../../models/prayer_times.dart';
import '../schedule_repository.dart';

class MockScheduleRepository implements ScheduleRepository {
  @override
  PrayerTimes forDate(DateTime date, {required String masjidId}) =>
      mockPrayerTimesFor(date);
}
