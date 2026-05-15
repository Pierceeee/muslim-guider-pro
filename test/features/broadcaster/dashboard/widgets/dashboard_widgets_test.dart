import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/kpi_tile.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/next_broadcast_card.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/recent_broadcasts_list.dart';

void main() {
  testWidgets('KpiTile shows value and label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: KpiTile(label: "Today's Broadcasts", value: '3')),
    ));
    expect(find.text('3'), findsOneWidget);
    expect(find.text("TODAY'S BROADCASTS"), findsOneWidget);
  });

  testWidgets('NextBroadcastCard shows prayer name and time', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NextBroadcastCard(
        prayerName: 'Maghrib',
        at: DateTime(2026, 5, 13, 19, 30),
      )),
    ));
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('19:30'), findsOneWidget);
  });

  testWidgets('RecentBroadcastsList renders one row per entry', (tester) async {
    final entries = [
      BroadcastStream(
        id: 's1', masjidId: 'm1', muadhinId: 'u1',
        startedAt: DateTime(2026, 5, 13, 4, 30),
        endedAt: DateTime(2026, 5, 13, 4, 33),
        peakListenerCount: 47, currentListenerCount: 0,
        status: StreamStatus.ended, endReason: EndReason.normal,
      ),
      BroadcastStream(
        id: 's2', masjidId: 'm1', muadhinId: 'u1',
        startedAt: DateTime(2026, 5, 12, 21, 0),
        endedAt: DateTime(2026, 5, 12, 21, 4),
        peakListenerCount: 52, currentListenerCount: 0,
        status: StreamStatus.ended, endReason: EndReason.normal,
      ),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RecentBroadcastsList(entries: entries)),
    ));
    expect(find.textContaining('47'), findsOneWidget);
    expect(find.textContaining('52'), findsOneWidget);
  });
}
