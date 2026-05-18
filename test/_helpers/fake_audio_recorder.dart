import 'package:muslim_guider_pro/data/repositories/audio_recorder_repository.dart';

/// A no-op [AudioRecorderRepository] for use in widget and integration tests.
/// Returns hardcoded permission=true, ignores start/stop, emits an empty
/// amplitude stream so that the infinite timer in [RealAudioRecorder] never
/// leaks across test teardown.
class FakeAudioRecorder implements AudioRecorderRepository {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<String> startRecording({required String streamId}) async =>
      '/tmp/broadcast_$streamId.m4a';

  @override
  Future<String?> stopRecording() async => null;

  @override
  Stream<double> get amplitudeStream => const Stream.empty();
}
