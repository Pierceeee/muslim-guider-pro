import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ListenerCounter extends StatelessWidget {
  const ListenerCounter({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.headphones, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$count listening',
            style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
