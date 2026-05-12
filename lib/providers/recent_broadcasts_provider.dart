import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/broadcast_stream.dart';
import 'repository_providers.dart';

final recentBroadcastsProvider =
    Provider.family<List<BroadcastStream>, String>((ref, masjidId) {
  return ref.watch(broadcastRepositoryProvider).recentBroadcasts(masjidId);
});
