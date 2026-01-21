import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_settings_provider.dart';
import '../l10n/gen/app_localizations.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch écoute le provider : si l'état change, MyApp se reconstruit
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'Mon Template Mobile',
      debugShowCheckedModeBanner: false,

      // Gestion dynamique de la langue
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Gestion dynamique du thème
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,

      routerConfig: AppRouter.router,
    );
  }
}