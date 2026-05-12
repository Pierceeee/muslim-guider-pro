import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';

void main() {
  test('duration uses endedAt when ended', () {
    final s = BroadcastStream(
      id: 's1', masjidId: 'm1', muadhinId: 'u1',
      startedAt: DateTime(2026, 5, 13, 5, 0),
      endedAt: DateTime(2026, 5, 13, 5, 3, 30),
      peakListenerCount: 42, currentListenerCount: 0,
      status: StreamStatus.ended, endReason: EndReason.normal,
    );
    expect(s.duration, const Duration(minutes: 3, seconds: 30));
  });

  test('duration uses now() when still live', () {
    final s = BroadcastStream(
      id: 's2', masjidId: 'm1', muadhinId: 'u1',
      startedAt: DateTime.now().subtract(const Duration(seconds: 10)),
      endedAt: null,
      peakListenerCount: 1, currentListenerCount: 1,
      status: StreamStatus.live,
    );
    expect(s.duration.inSeconds, greaterThanOrEqualTo(10));
  });
}
