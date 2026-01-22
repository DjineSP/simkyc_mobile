import 'dart:async';

import '../models/home_dashboard_data.dart';

class HomeRepository {
  Future<HomeDashboardData> fetchDashboard() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return const HomeDashboardData(
      displayName: 'Pafing Tedy',
      roleLabel: 'Administrateur',
      totalActivations: 12450,
      activeSims: 8230,
    );
  }
}
