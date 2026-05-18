import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/data/repositories/real/real_broadcast_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('persists and reloads a broadcast across instances', () async {
    final repo1 = await RealBroadcastRepository.create();
    final stream = repo1.startBroadcast(
      masjidId: 'masjid-1',
      muadhinId: 'muadhin-1',
    );
    repo1.endBroadcast(stream.id, EndReason.normal);

    final repo2 = await RealBroadcastRepository.create();
    final recent = repo2.recentBroadcasts('masjid-1');
    expect(recent, isNotEmpty);
    expect(recent.first.endedAt, isNotNull);
  });

  test('startBroadcast adds stream to cache', () async {
    final repo = await RealBroadcastRepository.create();
    final stream = repo.startBroadcast(
      masjidId: 'masjid-2',
      muadhinId: 'muadhin-2',
    );
    expect(stream.status, StreamStatus.live);
    expect(repo.findById(stream.id), equals(stream));
  });

  test('endBroadcast marks stream as ended', () async {
    final repo = await RealBroadcastRepository.create();
    final stream = repo.startBroadcast(
      masjidId: 'masjid-3',
      muadhinId: 'muadhin-3',
    );
    final ended = repo.endBroadcast(stream.id, EndReason.normal);
    expect(ended.status, StreamStatus.ended);
    expect(ended.endedAt, isNotNull);
    expect(ended.endReason, EndReason.normal);
  });

  test('recentBroadcasts only returns ended streams', () async {
    final repo = await RealBroadcastRepository.create();
    final stream = repo.startBroadcast(
      masjidId: 'masjid-4',
      muadhinId: 'muadhin-4',
    );
    // While live, recentBroadcasts should be empty
    expect(repo.recentBroadcasts('masjid-4'), isEmpty);
    repo.endBroadcast(stream.id, EndReason.normal);
    expect(repo.recentBroadcasts('masjid-4'), hasLength(1));
  });

  test('watchCurrentLiveStream emits initial null when no live stream', () async {
    final repo = await RealBroadcastRepository.create();
    const masjidId = 'masjid-5';
    final first = await repo.watchCurrentLiveStream(masjidId).first;
    expect(first, isNull);
  });

  test('watchCurrentLiveStream emits live stream after startBroadcast', () async {
    final repo = await RealBroadcastRepository.create();
    const masjidId = 'masjid-6';
    final events = <BroadcastStream?>[];
    final sub = repo.watchCurrentLiveStream(masjidId).listen(events.add);

    // Give the async* generator a microtask to subscribe to the broadcast ctrl
    await Future<void>.delayed(Duration.zero);

    repo.startBroadcast(masjidId: masjidId, muadhinId: 'muadhin-6');

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // events[0] = initial null; events[1] = live stream
    expect(events.length, greaterThanOrEqualTo(2));
    expect(events.last, isNotNull);
    expect(events.last!.status, StreamStatus.live);
  });

  test('BroadcastStream toJson/fromJson round-trips correctly', () {
    final original = BroadcastStream(
      id: 'test-id',
      masjidId: 'masjid-1',
      muadhinId: 'muadhin-1',
      startedAt: DateTime.utc(2026, 5, 19, 10, 0, 0),
      endedAt: DateTime.utc(2026, 5, 19, 10, 5, 0),
      peakListenerCount: 42,
      currentListenerCount: 0,
      status: StreamStatus.ended,
      endReason: EndReason.normal,
    );
    final json = original.toJson();
    final restored = BroadcastStream.fromJson(json);
    expect(restored, equals(original));
  });
}
