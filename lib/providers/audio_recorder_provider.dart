import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/audio_recorder_repository.dart';

final audioRecorderRepositoryProvider = Provider<AudioRecorderRepository>(
  (ref) => throw UnimplementedError(
      'Override audioRecorderRepositoryProvider in main.dart'),
);
