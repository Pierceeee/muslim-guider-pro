import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CheckStatus { idle, checking, ok, failed }

class GoLiveState {
  const GoLiveState({
    this.mic = CheckStatus.idle,
    this.network = CheckStatus.idle,
    this.geofence = CheckStatus.idle,
  });

  final CheckStatus mic;
  final CheckStatus network;
  final CheckStatus geofence;

  bool get allOk =>
      mic == CheckStatus.ok &&
      network == CheckStatus.ok &&
      geofence == CheckStatus.ok;

  GoLiveState copyWith({
    CheckStatus? mic,
    CheckStatus? network,
    CheckStatus? geofence,
  }) {
    return GoLiveState(
      mic: mic ?? this.mic,
      network: network ?? this.network,
      geofence: geofence ?? this.geofence,
    );
  }
}

class GoLiveController extends StateNotifier<GoLiveState> {
  GoLiveController() : super(const GoLiveState());

  void setMic(CheckStatus status) => state = state.copyWith(mic: status);

  Future<void> runFakeChecks() async {
    state = state.copyWith(
      network: CheckStatus.checking,
      geofence: CheckStatus.checking,
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(network: CheckStatus.ok, geofence: CheckStatus.ok);
  }
}

final goLiveControllerProvider =
    StateNotifierProvider<GoLiveController, GoLiveState>((ref) {
  return GoLiveController();
});
