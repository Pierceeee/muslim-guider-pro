import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/broadcast_stream.dart';
import 'repository_providers.dart';

final liveStreamProvider =
    StreamProvider.family<BroadcastStream?, String>((ref, masjidId) {
  return ref.watch(broadcastRepositoryProvider).watchCurrentLiveStream(masjidId);
});
