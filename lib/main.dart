import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/repositories/mock/mock_auth_repository.dart';
import 'data/repositories/mock/mock_broadcast_repository.dart';
import 'data/repositories/mock/mock_masjid_repository.dart';
import 'data/repositories/mock/mock_schedule_repository.dart';
import 'providers/repository_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
    ],
    child: const MuslimGuiderProApp(),
  ));
}
