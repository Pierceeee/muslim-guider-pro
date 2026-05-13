import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StubScreen extends StatelessWidget {
  const StubScreen({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(label, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Coming soon',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
