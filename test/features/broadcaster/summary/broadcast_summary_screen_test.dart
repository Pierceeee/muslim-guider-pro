import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/summary/broadcast_summary_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Summary screen shows stats and a Done button', (tester) async {
    final broadcast = MockBroadcastRepository();
    final started = broadcast.startBroadcast(
        masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');
    broadcast.endBroadcast(started.id, EndReason.normal);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        broadcastRepositoryProvider.overrideWithValue(broadcast),
      ],
      child: MaterialApp(home: BroadcastSummaryScreen(streamId: started.id)),
    ));
    expect(find.text('Broadcast Ended'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
