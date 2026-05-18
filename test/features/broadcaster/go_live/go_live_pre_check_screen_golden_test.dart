// Golden / visual-regression test for GoLivePreCheckScreen.
//
// TODO(T34-goldens): pixel goldens are blocked by google_fonts offline behaviour.
// AppTextStyles calls GoogleFonts.instrumentSans / GoogleFonts.dmSans at build
// time.  When the font files are not in the asset bundle, google_fonts throws
// an uncaught async exception inside flutter_test's zone error handler that
// cannot be suppressed from flutter_test_config.dart.
//
// To unblock:
//   1. Download InstrumentSans and DMSans ttf files and place them under
//      assets/fonts/.
//   2. Declare them under the `fonts:` section of pubspec.yaml.
//   3. Remove this comment block and uncomment the testWidgets body below.
//
// Structural widget assertions are already covered by
//   test/features/broadcaster/go_live/go_live_pre_check_screen_test.dart
// which passes green today.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('go-live pre-check golden skipped — google_fonts offline; see TODO(T34-goldens)',
      () {}, skip: true);
}
