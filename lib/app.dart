import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class MuslimGuiderProApp extends StatelessWidget {
  const MuslimGuiderProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Guider Pro',
      theme: AppTheme.dark,
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: const Scaffold(body: Center(child: Text('Booting…'))),
    );
  }
}
