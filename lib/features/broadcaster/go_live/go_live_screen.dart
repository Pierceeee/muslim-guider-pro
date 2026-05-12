import 'package:flutter/material.dart';

import '../shared/broadcaster_coming_soon.dart';

/// Recreates `prototype/screens/go-live-pre-broadcast-check.html`.
/// Pre-broadcast permission/network checks. F5 placeholder.
class GoLiveScreen extends StatelessWidget {
  const GoLiveScreen({super.key});

  @override
  Widget build(BuildContext context) => const BroadcasterComingSoon(
        slug: 'go-live-pre-broadcast-check',
        title: 'Go Live · Pre-Broadcast Check',
        subFeature: 'go_live',
      );
}
