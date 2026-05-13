import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';

class MockUserTile extends StatelessWidget {
  const MockUserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.busy = false,
  });

  final User user;
  final VoidCallback onTap;
  final bool busy;

  String _roleLabel() {
    switch (user.role) {
      case UserRole.muadhin:
        return user.masjidId != null
            ? 'Muadhin · ${user.masjidId}'
            : 'Muadhin';
      case UserRole.listener:
        return 'Listener';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: busy ? null : onTap,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceInset,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(user.displayName,
            style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(_roleLabel(),
            style: Theme.of(context).textTheme.bodyMedium),
        trailing: busy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right, color: AppColors.inkMuted),
      ),
    );
  }
}
