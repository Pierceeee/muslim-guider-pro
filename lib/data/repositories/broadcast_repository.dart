import '../models/stream_record.dart';

/// Read-side operations for live + replayable Athan broadcasts.
/// The write side (start/end broadcast) becomes the [BroadcasterRepository]
/// in F5/B4; this interface is listener-facing only.
abstract class BroadcastRepository {
  /// All currently-live streams, sorted by listener count desc.
  Stream<List<StreamRecord>> watchActiveStreams();

  /// Recent broadcasts (live + ended) for a single masjid.
  Future<List<StreamRecord>> getRecentByMasjid(
    String masjidId, {
    int limit,
  });

  /// Single stream by id (live or ended).
  Future<StreamRecord> getById(String streamId);

  /// Replay URL for a recorded stream, or null if no recording was captured.
  Future<String?> getReplayUrl(String streamId);
}
