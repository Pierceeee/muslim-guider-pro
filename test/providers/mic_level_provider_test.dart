import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';

void main() {
  test('Fallback sine emits values between 0 and 1', () async {
    final container = ProviderContainer(overrides: [
      useFallbackMicProvider.overrideWithValue(true),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen<AsyncValue<double>>(micLevelProvider, (p, n) {});

    final value = await container.read(micLevelProvider.future);
    expect(value, inInclusiveRange(0.0, 1.0));
    sub.close();
  });
}
