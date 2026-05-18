// flutter_test_config.dart — runs once before every test file in this suite.
//
// Currently a no-op pass-through.
//
// NOTE(T34-goldens): google_fonts font-load exceptions cannot be suppressed
// from here because flutter_test intercepts uncaught async errors in its own
// zone before testExecutable can handle them.  The golden tests that use
// AppTextStyles are therefore kept as skip:true placeholders until the fonts
// are bundled as local assets (see test/features/broadcaster/goldens/README.md).

import 'dart:async';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
}
