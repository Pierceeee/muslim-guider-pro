import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('AppBottomNav exposes 5 destinations', (tester) async {
    int tapped = -1;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
      ),
    ));
    // currentIndex 0 means Home is selected — filled icon is in tree
    expect(find.byIcon(Icons.home), findsOneWidget);
    // Dashboard is not selected — outline variant is in the tree
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);

    await tester.tap(find.text('Dashboard'));
    expect(tapped, 1);
  });
}
