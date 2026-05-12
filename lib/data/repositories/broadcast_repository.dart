import '../models/broadcast_stream.dart';

abstract class BroadcastRepository {
  Stream<BroadcastStream?> watchCurrentLiveStream(String masjidId);
  List<BroadcastStream> recentBroadcasts(String masjidId, {int limit = 3});
  BroadcastStream? findById(String id);
  BroadcastStream startBroadcast({
    required String masjidId,
    required String muadhinId,
  });
  BroadcastStream endBroadcast(String streamId, EndReason reason);
}
