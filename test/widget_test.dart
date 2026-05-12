import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guider_pro/app.dart';

void main() {
  testWidgets('App boots and lands on the listener dashboard', (
    WidgetTester tester,
  ) async {
    // google_fonts may try to hit the network on first use; allow it to fall
    // back to system fonts silently.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(child: MuslimGuiderProApp()),
      );
    });
    // Pump several frames so go_router resolves the initial route and the
    // async providers (auth, schedule, preferredMasjid, broadcasts) settle.
    // We can't use `pumpAndSettle` because the pulsing live pill animation
    // runs forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    // Always-on copy.
    expect(find.text('Assalamu alaikum,'), findsOneWidget);

    // Dashboard structure — assert SHAPE not specific dynamic values.
    // "NEXT PRAYER · X" — X varies with the current clock, just check prefix.
    expect(find.textContaining('NEXT PRAYER · '), findsOneWidget);

    // User name from `ensureSignedInUserProvider` (mock listener fixture).
    // Appears in both the greeting and the avatar initial; assert at least
    // one of those is rendered.
    expect(find.text('Abdullah'), findsAtLeastNWidgets(1));

    // Preferred masjid card.
    expect(find.text('Masjid Al-Abrar'), findsOneWidget);

    // LISTEN button on the masjid card.
    expect(find.text('LISTEN'), findsOneWidget);

    // "Live broadcasts near you" section header.
    expect(find.text('Live broadcasts near you'), findsOneWidget);
  });
}
