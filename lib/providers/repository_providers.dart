import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/broadcast_repository.dart';
import '../data/repositories/masjid_repository.dart';
import '../data/repositories/schedule_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((_) {
  throw UnimplementedError('authRepositoryProvider not overridden');
});

final masjidRepositoryProvider = Provider<MasjidRepository>((_) {
  throw UnimplementedError('masjidRepositoryProvider not overridden');
});

final broadcastRepositoryProvider = Provider<BroadcastRepository>((_) {
  throw UnimplementedError('broadcastRepositoryProvider not overridden');
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((_) {
  throw UnimplementedError('scheduleRepositoryProvider not overridden');
});
