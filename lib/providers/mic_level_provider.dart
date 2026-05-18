import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_recorder_provider.dart';

/// True on web and on any platform where the record package is unavailable,
/// causing [micLevelProvider] to emit a sine-wave simulation instead of real
/// microphone amplitude.
final useFallbackMicProvider = Provider<bool>((_) => kIsWeb);

final micLevelProvider = StreamProvider.autoDispose<double>((ref) {
  final useFallback = ref.watch(useFallbackMicProvider);
  if (useFallback) return _sineFallback();
  // Use the real recorder's amplitude stream; any platform error falls back to
  // the sine-wave so the UI never breaks on unsupported platforms.
  try {
    final recorder = ref.watch(audioRecorderRepositoryProvider);
    return recorder.amplitudeStream.handleError((_) {});
  } catch (_) {
    return _sineFallback();
  }
});

Stream<double> _sineFallback() async* {
  final start = DateTime.now();
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final t = DateTime.now().difference(start).inMilliseconds / 1000.0;
    yield ((math.sin(t * 2 * math.pi / 3) + 1) / 2).clamp(0.0, 1.0);
  }
}
