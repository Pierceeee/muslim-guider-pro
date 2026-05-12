import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root MaterialApp.router — owns theme, locale, and routing wiring.
///
/// `main.dart` stays thin (it only starts the binding and runs the app); all
/// application-level configuration lives here so tests can wrap this widget
/// in their own `ProviderScope` overrides without touching `main`.
class MuslimGuiderProApp extends ConsumerWidget {
  const MuslimGuiderProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Muslim Guider Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('ar'),
      ],
      routerConfig: router,
    );
  }
}
