import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../audio_recorder_repository.dart';

class RealAudioRecorder implements AudioRecorderRepository {
  final _rec = AudioRecorder();

  @override
  Future<bool> hasPermission() => _rec.hasPermission();

  @override
  Future<void> requestPermission() async {
    await Permission.microphone.request();
  }

  @override
  Future<String> startRecording({required String streamId}) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/broadcast_$streamId.m4a';
    await _rec.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 22050,
      ),
      path: path,
    );
    return path;
  }

  @override
  Future<String?> stopRecording() => _rec.stop();

  @override
  Future<void> dispose() => _rec.dispose();

  @override
  Stream<double> get amplitudeStream =>
      _rec
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .map((a) => ((a.current + 60) / 60).clamp(0.0, 1.0));
}
