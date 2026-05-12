import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/app.dart';

void main() {
  testWidgets('MuslimGuiderProApp boots without throwing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MuslimGuiderProApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
