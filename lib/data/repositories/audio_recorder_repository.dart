abstract class AudioRecorderRepository {
  /// Quick check — returns true if mic permission is already granted.
  Future<bool> hasPermission();

  /// Triggers the OS permission prompt if needed.
  Future<void> requestPermission();

  /// Starts capturing audio into a stream-specific file. Returns the absolute
  /// path of the destination file (may not exist yet until stop() is called).
  Future<String> startRecording({required String streamId});

  /// Stops capture, finalizes the file, and returns its path. Returns null
  /// if nothing was being recorded.
  Future<String?> stopRecording();

  /// Live amplitude stream — values normalized to [0..1] from dBFS.
  Stream<double> get amplitudeStream;
}
