import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/floating_pill_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('FloatingPillNav shows 5 tabs', (tester) async {
    int? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: const SizedBox.shrink(),
        bottomNavigationBar: FloatingPillNav(
          currentIndex: 1,
          onTap: (i) => tapped = i,
        ),
      ),
    ));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    await tester.tap(find.text('Nearby'));
    expect(tapped, 2);
  });
}
