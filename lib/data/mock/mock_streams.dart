import '../models/broadcast_stream.dart';

DateTime _today(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

DateTime _daysAgo(int days, int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - days, hour, minute);
}

final kMockRecentStreams = <BroadcastStream>[
  BroadcastStream(
    id: 's_today_fajr',
    masjidId: 'm_al_abrar',
    muadhinId: 'u_imam_yusuf',
    startedAt: _today(4, 30),
    endedAt: _today(4, 33),
    peakListenerCount: 47,
    currentListenerCount: 0,
    status: StreamStatus.ended,
    endReason: EndReason.normal,
  ),
  BroadcastStream(
    id: 's_yesterday_isha',
    masjidId: 'm_al_abrar',
    muadhinId: 'u_imam_yusuf',
    startedAt: _daysAgo(1, 21, 0),
    endedAt: _daysAgo(1, 21, 4),
    peakListenerCount: 52,
    currentListenerCount: 0,
    status: StreamStatus.ended,
    endReason: EndReason.normal,
  ),
  BroadcastStream(
    id: 's_yesterday_maghrib',
    masjidId: 'm_al_abrar',
    muadhinId: 'u_imam_yusuf',
    startedAt: _daysAgo(1, 19, 30),
    endedAt: _daysAgo(1, 19, 33),
    peakListenerCount: 38,
    currentListenerCount: 0,
    status: StreamStatus.ended,
    endReason: EndReason.normal,
  ),
];
