import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mic_level_provider.dart';

/// Exposes a [Stream<double>] of mic amplitude values (0..1) for widgets
/// that require a raw stream (e.g. [AudioWaveform]).
///
/// Bridges the [StreamProvider]-based [micLevelProvider] to a plain
/// [Stream<double>] by listening to async updates via a [StreamController].
///
/// TODO(T30): When real microphone capture lands in mic_level_provider.dart
/// the stream source here will update automatically.
final micLevelStreamProvider = Provider.autoDispose<Stream<double>>((ref) {
  final controller = StreamController<double>.broadcast();

  // Listen to the StreamProvider's AsyncValue updates and forward doubles.
  final sub = ref.listen<AsyncValue<double>>(micLevelProvider, (_, next) {
    next.whenData(controller.add);
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});
