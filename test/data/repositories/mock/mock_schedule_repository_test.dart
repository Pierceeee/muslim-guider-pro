import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/prayer_times.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';

void main() {
  test('forDate returns a five-prayer schedule', () {
    final repo = MockScheduleRepository();
    final times = repo.forDate(DateTime(2026, 5, 13), masjidId: 'm_al_abrar');
    expect(times.times.length, 5);
    expect(times.times[Prayer.fajr], isNotNull);
    expect(times.times[Prayer.isha], isNotNull);
  });
}
