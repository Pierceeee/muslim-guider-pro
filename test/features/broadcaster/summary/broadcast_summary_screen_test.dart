import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/bg_pattern.dart';
import 'package:muslim_guider_pro/core/widgets/retention_chart.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/kpi_tile.dart';
import 'package:muslim_guider_pro/features/broadcaster/summary/broadcast_summary_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Summary screen shows prototype re-skin widgets', (tester) async {
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
    await tester.pump();

    expect(find.byType(BgPattern), findsOneWidget);
    expect(find.byType(KpiTile), findsNWidgets(4));
    expect(find.byType(RetentionChart), findsOneWidget);
    expect(find.text('Broadcast complete ✓'), findsOneWidget);
    expect(find.text('Save & finish'), findsOneWidget);
    expect(find.text('Discard recording'), findsOneWidget);
  });
}
