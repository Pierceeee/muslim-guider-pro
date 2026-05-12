import 'package:flutter/material.dart';

import '../shared/broadcaster_coming_soon.dart';

/// Recreates `prototype/screens/live-broadcast-masjid-al-abrar.html`.
/// Live broadcast UI with mic ambient meter. F5 placeholder.
class LiveBroadcastScreen extends StatelessWidget {
  const LiveBroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) => const BroadcasterComingSoon(
        slug: 'live-broadcast-masjid-al-abrar',
        title: 'Live Broadcast',
        subFeature: 'live',
      );
}
