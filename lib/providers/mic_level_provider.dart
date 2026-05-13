import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_meter/noise_meter.dart';

final useFallbackMicProvider = Provider<bool>((_) {
  if (kIsWeb) return true;
  return !(Platform.isAndroid || Platform.isIOS);
});

final micLevelProvider = StreamProvider.autoDispose<double>((ref) {
  final useFallback = ref.watch(useFallbackMicProvider);
  if (useFallback) return _sineFallback();
  return _noiseMeterStream();
});

Stream<double> _sineFallback() async* {
  final start = DateTime.now();
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final t = DateTime.now().difference(start).inMilliseconds / 1000.0;
    yield ((math.sin(t * 2 * math.pi / 3) + 1) / 2).clamp(0.0, 1.0);
  }
}

Stream<double> _noiseMeterStream() async* {
  try {
    final meter = NoiseMeter();
    await for (final r in meter.noise) {
      const minDb = -60.0;
      const maxDb = 0.0;
      final norm = ((r.meanDecibel - minDb) / (maxDb - minDb)).clamp(0.0, 1.0);
      yield norm;
    }
  } catch (_) {
    yield* _sineFallback();
  }
}
