import '../../mock/mock_schedule.dart';
import '../../models/prayer_times.dart';
import '../schedule_repository.dart';

/// In-memory implementation of [ScheduleRepository] backed by
/// `mock_schedule.dart`. Swapped for the real on-device `adhan` calculation
/// + Firestore custom-schedule overrides in B5.
class MockScheduleRepository implements ScheduleRepository {
  MockScheduleRepository();

  CalculationMethod _currentMethod = CalculationMethod.mwl;

  @override
  Future<PrayerTimes> getDailySchedule({
    required DateTime date,
    required double latitude,
    required double longitude,
    required CalculationMethod method,
  }) async {
    // Mock impl ignores coordinates and always returns Birmingham fixtures —
    // good enough for v1 UI work. B5 swaps in real adhan computation.
    return mockBirminghamSchedule;
  }

  @override
  Future<CalculationMethod> getCurrentMethod() async {
    return _currentMethod;
  }

  @override
  Future<void> setCurrentMethod(CalculationMethod method) async {
    _currentMethod = method;
  }
}
