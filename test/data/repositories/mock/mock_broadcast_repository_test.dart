import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';

void main() {
  test('recentBroadcasts returns up to limit entries for the given masjid', () {
    final repo = MockBroadcastRepository();
    expect(repo.recentBroadcasts('m_al_abrar', limit: 3).length, 3);
    expect(repo.recentBroadcasts('m_al_abrar', limit: 1).length, 1);
    expect(repo.recentBroadcasts('m_unknown').length, 0);
  });

  test('startBroadcast creates a live stream and emits on the watcher', () async {
    final repo = MockBroadcastRepository();
    final emissions = <BroadcastStream?>[];
    final sub = repo.watchCurrentLiveStream('m_al_abrar').listen(emissions.add);

    final s = repo.startBroadcast(masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');
    expect(s.status, StreamStatus.live);
    expect(s.masjidId, 'm_al_abrar');

    await Future<void>.delayed(Duration.zero);
    expect(emissions.last?.id, s.id);
    await sub.cancel();
  });

  test('endBroadcast marks the stream ended and clears the live watcher', () async {
    final repo = MockBroadcastRepository();
    final started = repo.startBroadcast(masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');

    final ended = repo.endBroadcast(started.id, EndReason.normal);
    expect(ended.status, StreamStatus.ended);
    expect(ended.endReason, EndReason.normal);
    expect(ended.endedAt, isNotNull);

    final live = await repo.watchCurrentLiveStream('m_al_abrar').first;
    expect(live, isNull);
  });

  test('findById returns the freshest known stream', () {
    final repo = MockBroadcastRepository();
    final started = repo.startBroadcast(masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');
    final ended = repo.endBroadcast(started.id, EndReason.normal);
    expect(repo.findById(started.id)?.status, ended.status);
  });
}
