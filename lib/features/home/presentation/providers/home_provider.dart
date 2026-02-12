import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../data/models/home_dashboard_data.dart';
import '../../../../features/sim/data/repositories/sim_activation_repository.dart';


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
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    final userData = user?.userData;

    if (userData != null) {
      // Pre-fetch identity natures to cache them for later use (Sim Activation/Update)
      // This avoids waiting when opening those screens.
      ref.read(idNaturesProvider.future).catchError((_) => <Map<String, dynamic>>[]);

      return HomeDashboardState(
        data: HomeDashboardData(
          displayName: userData.username,
          roleLabel: 'Agent', // Placeholder or add to UserData if available
          totalActivations: userData.nombreActivation,
          totalReactivations: userData.nombreReactivation,
          totalUpdates: userData.nombreMiseAJour,
        ),
        isLoading: false,
        error: null,
      );
    }
    
    return HomeDashboardState.initial();
  }

  Future<void> refresh() async {
    // Si on veut rafraichir les données, on pourrait appeler une API dédiée
    // ou simplement recharger le profil utilisateur.
    // Pour l'instant, on se base sur les données de l'auth.
    
    // Exemple : si on avait un endpoint pour rafraichir le user
    // await ref.read(authProvider.notifier).refreshUser();
  }
}

final homeDashboardProvider = NotifierProvider<HomeDashboardNotifier, HomeDashboardState>(() {
  return HomeDashboardNotifier();
});
