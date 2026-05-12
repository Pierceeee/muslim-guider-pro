import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/broadcast_repository.dart';
import '../repositories/masjid_repository.dart';
import '../repositories/mock/mock_auth_repository.dart';
import '../repositories/mock/mock_broadcast_repository.dart';
import '../repositories/mock/mock_masjid_repository.dart';
import '../repositories/mock/mock_schedule_repository.dart';
import '../repositories/schedule_repository.dart';

/// Repository bindings — the only file in the app that decides "mock vs real."
///
/// In Phase B (backend), each `Mock*Repository()` constructor swaps for the
/// real Firebase/AWS-backed implementation. Screen and feature code keep
/// watching the same provider — nothing else changes.
///
/// Tests override these via `ProviderScope(overrides: [...])`.

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final masjidRepositoryProvider = Provider<MasjidRepository>(
  (ref) => const MockMasjidRepository(),
);

final broadcastRepositoryProvider = Provider<BroadcastRepository>(
  (ref) => MockBroadcastRepository(),
);

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => MockScheduleRepository(),
);
