import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/providers/prayer_times_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  test('prayerTimesProvider returns five-prayer schedule', () {
    final container = ProviderContainer(overrides: [
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
    ]);
    addTearDown(container.dispose);

    final times = container.read(
      prayerTimesProvider(PrayerTimesArg(
        date: DateTime(2026, 5, 13), masjidId: 'm_al_abrar',
      )),
    );
    expect(times.times.length, 5);
  });
}
