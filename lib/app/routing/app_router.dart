import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simkyc_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:simkyc_mobile/features/sim/presentation/pages/activation_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/history/presentation/pages/history_management_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/sim/presentation/pages/reactivation_page.dart';
import '../../features/sim/presentation/pages/update_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';

class Routes {
  // Routes Auth & Initial
  static const splash = '/';
  static const login = '/login';

  // Routes principales
  static const home = '/home';
  static const notification = '/notification';
  static const historyManagement = '/history-management';
  static const reports = '/reports';
  static const profile = '/profile';

  // Routes Sim
  static const simActivation = '/activation';
  static const simReactivation = '/reactivation';
  static const simUpdate = '/update';

  // Routes annexes
  static const notifications = '/notifications';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      // Splash & Auth
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Principales
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.notification,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: Routes.historyManagement,
        builder: (context, state) => const HistoryManagementPage(),
      ),
      GoRoute(
        path: Routes.reports,
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfilePage(),
      ),

      // Ajoute ici tes autres routes de la même manière...
      GoRoute(
        path: Routes.simActivation,
        builder: (context, state) => const SimActivationPage(),
      ),
      GoRoute(
        path: Routes.simReactivation,
        builder: (context, state) => const SimReactivationPage(),
      ),
      GoRoute(
        path: Routes.simUpdate,
        builder: (context, state) => const SimUpdatePage(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationPage(),
      ),
    ],
  );
}