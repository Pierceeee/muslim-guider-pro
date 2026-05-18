import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/repositories/mock/mock_auth_repository.dart';
import 'data/repositories/mock/mock_masjid_repository.dart';
import 'data/repositories/mock/mock_schedule_repository.dart';
import 'data/repositories/real/real_audio_recorder.dart';
import 'data/repositories/real/real_broadcast_repository.dart';
import 'providers/audio_recorder_provider.dart';
import 'providers/repository_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final realBroadcastRepo = await RealBroadcastRepository.create();
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(realBroadcastRepo),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      audioRecorderRepositoryProvider.overrideWith((ref) {
        final recorder = RealAudioRecorder();
        ref.onDispose(() => recorder.dispose());
        return recorder;
      }),
    ],
    child: const MuslimGuiderProApp(),
  ));
}
