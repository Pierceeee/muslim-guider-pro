import 'package:flutter/material.dart';

import '../shared/broadcaster_coming_soon.dart';

/// Recreates `prototype/screens/masjid-dashboard-muadhin.html` — the
/// Muadhin's KPI dashboard with recent broadcasts and slide-to-broadcast
/// entry. F5 placeholder.
class MasjidDashboardScreen extends StatelessWidget {
  const MasjidDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const BroadcasterComingSoon(
        slug: 'masjid-dashboard-muadhin',
        title: 'Masjid Dashboard',
        subFeature: 'dashboard',
      );
}
