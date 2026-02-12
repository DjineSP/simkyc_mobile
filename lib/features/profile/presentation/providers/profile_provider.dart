import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile_data.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileState {
  final ProfileData? data;
  final bool isLoading;
  final String? error;

  const ProfileState({
    required this.data,
    required this.isLoading,
    required this.error,
  });

  factory ProfileState.initial() => const ProfileState(
        data: null,
        isLoading: true,
        error: null,
      );

  ProfileState copyWith({
    ProfileData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final initial = ProfileState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final data = await repo.fetchProfile();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
