import 'package:flutter/material.dart';

import '../shared/broadcaster_coming_soon.dart';

/// Recreates `prototype/screens/broadcast-summary-masjid-al-abrar.html`.
/// Post-broadcast summary (duration, peak listeners, etc.). F5 placeholder.
class BroadcastSummaryScreen extends StatelessWidget {
  const BroadcastSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) => const BroadcasterComingSoon(
        slug: 'broadcast-summary-masjid-al-abrar',
        title: 'Broadcast Summary',
        subFeature: 'summary',
      );
}
