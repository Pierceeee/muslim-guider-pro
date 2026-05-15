import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MuslimGuiderProApp extends ConsumerStatefulWidget {
  const MuslimGuiderProApp({super.key});

  @override
  ConsumerState<MuslimGuiderProApp> createState() => _MuslimGuiderProAppState();
}

class _MuslimGuiderProAppState extends ConsumerState<MuslimGuiderProApp> {
  late final _router = buildAppRouter(ProviderScope.containerOf(context));

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Muslim Guider Pro',
      theme: AppTheme.dark(),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
