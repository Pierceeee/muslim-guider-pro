import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user.dart';
import 'repository_providers.dart';

final currentUserProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchCurrentUser();
});
