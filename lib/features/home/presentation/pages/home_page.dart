import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routing/app_router.dart';
import '../../../../l10n/gen/app_localizations.dart';

import '../widgets/app_scaffold.dart';
import 'home_content.dart';
import '../../../history/presentation/pages/history_management_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    HistoryManagementPage(),
    ReportsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Gestion dynamique du titre via i18n
    String title = l10n.home_nav_dashboard;
    switch (_index) {
      case 1: title = l10n.home_nav_history; break;
      case 2: title = l10n.home_nav_reports; break;
      case 3: title = l10n.home_nav_profile; break;
    }

    return AppScaffold(
      title: title,
      currentIndex: _index,
      onNavTap: (i) => setState(() => _index = i),
      onFabTap: () => context.push(Routes.simActivation),
      showFab: true,
      body: _pages[_index],
    );
  }
}