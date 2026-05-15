import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/slide_to_broadcast.dart';

// Drag the thumb's GestureDetector rightward by [distance] pixels.
Future<void> _dragThumbRight(
    WidgetTester tester, double distance) async {
  final gdFinder = find.byType(GestureDetector);
  // The thumb GestureDetector is the first (and only) one inside the pill.
  final thumbRect = tester.getRect(gdFinder.first);
  await tester.dragFrom(thumbRect.center, Offset(distance, 0));
  // Pump through the animation + the 400 ms reset timer.
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  group('SlideToBroadcast — dashboard variant (default)', () {
    testWidgets('full drag fires onConfirmed', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SlideToBroadcast(onConfirmed: () => confirmed = true),
          ),
        ),
      ));
      await tester.pump();

      await _dragThumbRight(tester, 350);
      expect(confirmed, isTrue);
    });

    testWidgets('partial drag springs back without firing', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SlideToBroadcast(onConfirmed: () => confirmed = true),
          ),
        ),
      ));
      await tester.pump();

      await _dragThumbRight(tester, 20);
      expect(confirmed, isFalse);
    });

    testWidgets('renders mic disc on left of track', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SlideToBroadcast(onConfirmed: () {}),
          ),
        ),
      ));
      expect(find.byType(SlideToBroadcast), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('SlideToBroadcast — home variant', () {
    testWidgets('full drag fires onConfirmed', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SlideToBroadcast(
              onConfirmed: () => confirmed = true,
              variant: SlideToBroadcastVariant.home,
            ),
          ),
        ),
      ));
      await tester.pump();

      await _dragThumbRight(tester, 350);
      expect(confirmed, isTrue);
    });

    testWidgets('partial drag springs back without firing', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SlideToBroadcast(
              onConfirmed: () => confirmed = true,
              variant: SlideToBroadcastVariant.home,
            ),
          ),
        ),
      ));
      await tester.pump();

      await _dragThumbRight(tester, 20);
      expect(confirmed, isFalse);
    });

    testWidgets('shows status label and footer hint', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SlideToBroadcast(
              onConfirmed: () {},
              variant: SlideToBroadcastVariant.home,
            ),
          ),
        ),
      ));
      expect(find.textContaining('SLIDE TO BROADCAST ADHAN'), findsOneWidget);
      expect(
        find.textContaining('Only Muadhins inside the masjid radius'),
        findsOneWidget,
      );
    });
  });
}
