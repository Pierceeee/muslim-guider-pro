import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_controller.dart';

void main() {
  test('initial state is all idle and not ready', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(goLiveControllerProvider);
    expect(state.mic, CheckStatus.idle);
    expect(state.network, CheckStatus.idle);
    expect(state.geofence, CheckStatus.idle);
    expect(state.allOk, isFalse);
  });

  test('runFakeChecks moves network and geofence to ok', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(goLiveControllerProvider.notifier).runFakeChecks();
    final state = container.read(goLiveControllerProvider);
    expect(state.network, CheckStatus.ok);
    expect(state.geofence, CheckStatus.ok);
  });
}
