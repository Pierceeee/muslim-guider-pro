import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/audio_recorder_repository.dart';
import '../../../providers/audio_recorder_provider.dart';

class LiveTickState {
  const LiveTickState({required this.elapsed, required this.listenerCount});
  final Duration elapsed;
  final int listenerCount;
}

class LiveBroadcastController extends StateNotifier<LiveTickState> {
  LiveBroadcastController(this.startedAt, this._recorder)
      : super(LiveTickState(elapsed: Duration.zero, listenerCount: 0)) {
    _start();
  }

  final DateTime startedAt;
  final AudioRecorderRepository _recorder;
  final _rng = Random();
  Timer? _timer;
  int _count = 0;
  String? _recordingPath;

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = (_count + (_rng.nextInt(3) == 0 ? 1 : 0)).clamp(0, 80);
      _count = next;
      state = LiveTickState(
        elapsed: DateTime.now().difference(startedAt),
        listenerCount: next,
      );
    });

    // Kick off audio capture — fire-and-forget; errors are non-fatal.
    _startAudio();
  }

  Future<void> _startAudio() async {
    try {
      await _recorder.requestPermission();
      _recordingPath = await _recorder.startRecording(
        streamId: startedAt.millisecondsSinceEpoch.toString(),
      );
    } catch (_) {
      // Platform unavailable (e.g. web/desktop) — mic-level falls back to
      // the sine-wave via mic_level_provider.dart.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopAudio();
    super.dispose();
  }

  void _stopAudio() {
    // Fire-and-forget — the recording file path is available via _recordingPath
    // if needed by a future persistence layer (T31).
    _recorder.stopRecording().then((path) {
      if (path != null) _recordingPath = path;
    }).catchError((_) {});
  }

  // Expose the last-known recording path for downstream use (T31).
  String? get recordingPath => _recordingPath;
}

final liveBroadcastControllerProvider =
    StateNotifierProvider.autoDispose
        .family<LiveBroadcastController, LiveTickState, DateTime>(
  (ref, startedAt) {
    final recorder = ref.watch(audioRecorderRepositoryProvider);
    return LiveBroadcastController(startedAt, recorder);
  },
);
