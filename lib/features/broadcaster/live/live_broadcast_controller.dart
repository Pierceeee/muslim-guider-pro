import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveTickState {
  const LiveTickState({required this.elapsed, required this.listenerCount});
  final Duration elapsed;
  final int listenerCount;
}

class LiveBroadcastController extends StateNotifier<LiveTickState> {
  LiveBroadcastController(this.startedAt)
      : super(LiveTickState(elapsed: Duration.zero, listenerCount: 0)) {
    _start();
  }

  final DateTime startedAt;
  final _rng = Random();
  Timer? _timer;
  int _count = 0;

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = (_count + (_rng.nextInt(3) == 0 ? 1 : 0)).clamp(0, 80);
      _count = next;
      state = LiveTickState(
        elapsed: DateTime.now().difference(startedAt),
        listenerCount: next,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final liveBroadcastControllerProvider =
    StateNotifierProvider.autoDispose.family<LiveBroadcastController, LiveTickState, DateTime>(
        (ref, startedAt) {
  return LiveBroadcastController(startedAt);
});
