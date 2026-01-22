import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_dashboard_data.dart';
import '../../data/repositories/home_repository.dart';

class HomeDashboardState {
  final HomeDashboardData? data;
  final bool isLoading;
  final String? error;

  const HomeDashboardState({
    required this.data,
    required this.isLoading,
    required this.error,
  });

  factory HomeDashboardState.initial() => const HomeDashboardState(
        data: null,
        isLoading: true,
        error: null,
      );

  HomeDashboardState copyWith({
    HomeDashboardData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HomeDashboardNotifier extends Notifier<HomeDashboardState> {
  @override
  HomeDashboardState build() {
    final initial = HomeDashboardState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final data = await repo.fetchDashboard();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

final homeDashboardProvider = NotifierProvider<HomeDashboardNotifier, HomeDashboardState>(() {
  return HomeDashboardNotifier();
});
