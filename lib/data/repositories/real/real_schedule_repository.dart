import '../../models/prayer_times.dart';
import '../../repositories/masjid_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../services/prayer_time_service.dart';

class RealScheduleRepository implements ScheduleRepository {
  RealScheduleRepository(this._service, this._masjids);

  final PrayerTimeService _service;
  final MasjidRepository _masjids;

  @override
  PrayerTimes forDate(DateTime date, {required String masjidId}) {
    final masjid = _masjids.findById(masjidId);
    if (masjid == null) {
      throw StateError('RealScheduleRepository: unknown masjidId "$masjidId"');
    }
    return _service.compute(
      date: date,
      latitude: masjid.latitude,
      longitude: masjid.longitude,
    );
  }
}
