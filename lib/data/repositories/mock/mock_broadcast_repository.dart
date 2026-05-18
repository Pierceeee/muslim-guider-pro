import 'dart:async';

import '../../mock/mock_streams.dart';
import '../../models/broadcast_stream.dart';
import '../broadcast_repository.dart';

class MockBroadcastRepository implements BroadcastRepository {
  MockBroadcastRepository();

  final Map<String, BroadcastStream> _streamsById = {
    for (final s in kMockRecentStreams) s.id: s,
  };
  final Map<String, BroadcastStream?> _liveByMasjid = {};
  final Map<String, StreamController<BroadcastStream?>> _watchers = {};

  StreamController<BroadcastStream?> _watcher(String masjidId) {
    return _watchers.putIfAbsent(
      masjidId,
      () => StreamController<BroadcastStream?>.broadcast(),
    );
  }

  @override
  Stream<BroadcastStream?> watchCurrentLiveStream(String masjidId) async* {
    yield _liveByMasjid[masjidId];
    yield* _watcher(masjidId).stream;
  }

  @override
  List<BroadcastStream> recentBroadcasts(String masjidId, {int limit = 3}) {
    final list = _streamsById.values
        .where((s) => s.masjidId == masjidId && s.status == StreamStatus.ended)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list.take(limit).toList();
  }

  @override
  BroadcastStream? findById(String id) => _streamsById[id];

  @override
  BroadcastStream startBroadcast({
    required String masjidId,
    required String muadhinId,
  }) {
    final now = DateTime.now();
    final stream = BroadcastStream(
      id: 's_${now.microsecondsSinceEpoch}',
      masjidId: masjidId,
      muadhinId: muadhinId,
      startedAt: now,
      peakListenerCount: 0,
      currentListenerCount: 0,
      status: StreamStatus.live,
    );
    _streamsById[stream.id] = stream;
    _liveByMasjid[masjidId] = stream;
    _watcher(masjidId).add(stream);
    return stream;
  }

  @override
  BroadcastStream endBroadcast(String streamId, EndReason reason) {
    final existing = _streamsById[streamId];
    if (existing == null) {
      throw StateError('Unknown stream id: $streamId');
    }
    final ended = existing.copyWith(
      status: StreamStatus.ended,
      endedAt: DateTime.now(),
      endReason: reason,
      currentListenerCount: 0,
    );
    _streamsById[streamId] = ended;
    _liveByMasjid[existing.masjidId] = null;
    _watcher(existing.masjidId).add(null);
    return ended;
  }

  @override
  Future<void> dispose() async {}
}

