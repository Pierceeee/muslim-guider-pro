import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/masjid.dart';
import 'current_user_provider.dart';
import 'repository_providers.dart';

final currentMasjidProvider = Provider<Masjid?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.masjidId == null) return null;
  return ref.watch(masjidRepositoryProvider).findById(user.masjidId!);
});
