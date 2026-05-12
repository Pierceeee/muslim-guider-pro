import 'dart:async';

import '../../mock/mock_streams.dart';
import '../../models/stream_record.dart';
import '../broadcast_repository.dart';

/// In-memory implementation of [BroadcastRepository] backed by
/// `mock_streams.dart`. Swapped for `ChimeBroadcastRepository` (Firestore
/// stream metadata + AWS Chime audio) in B4.
class MockBroadcastRepository implements BroadcastRepository {
  MockBroadcastRepository();

  final _activeController = StreamController<List<StreamRecord>>.broadcast();

  @override
  Stream<List<StreamRecord>> watchActiveStreams() async* {
    final live = mockStreams
        .where((s) => s.status == StreamStatus.live)
        .toList()
      ..sort(
        (a, b) => b.listenerCountCurrent.compareTo(a.listenerCountCurrent),
      );
    yield live;
    yield* _activeController.stream;
  }

  @override
  Future<List<StreamRecord>> getRecentByMasjid(
    String masjidId, {
    int limit = 10,
  }) async {
    final list = mockStreams
        .where((s) => s.masjidId == masjidId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list.take(limit).toList();
  }

  @override
  Future<StreamRecord> getById(String streamId) async {
    return mockStreams.firstWhere(
      (s) => s.id == streamId,
      orElse: () =>
          throw StateError('No mock stream with id "$streamId"'),
    );
  }

  @override
  Future<String?> getReplayUrl(String streamId) async {
    final stream = await getById(streamId);
    return stream.replayUrl;
  }
}
