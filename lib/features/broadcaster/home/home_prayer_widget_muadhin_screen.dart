import 'package:flutter/material.dart';

import '../shared/broadcaster_coming_soon.dart';

/// Recreates `prototype/screens/home-prayer-widget-muadhin.html`.
/// F5 placeholder; real implementation comes after listener side ships.
class HomePrayerWidgetMuadhinScreen extends StatelessWidget {
  const HomePrayerWidgetMuadhinScreen({super.key});

  @override
  Widget build(BuildContext context) => const BroadcasterComingSoon(
        slug: 'home-prayer-widget-muadhin',
        title: 'Home · Prayer Widget (Muadhin)',
        subFeature: 'home',
      );
}
