import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../shared/models/user_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/storage_service.dart';

class AuthNotifier extends AsyncNotifier<UserModel> {
  static const _kUserTokenKey = 'user_token';
  static const _kRefreshTokenKey = 'user_refresh_token'; // New
  static const _kUserDataKey = 'user_data'; // New
  static const _kUserPasswordKey = 'user_password';
  static const _kRememberMeKey = 'remember_me';

  @override
  Future<UserModel> build() async {
    final savedToken = await StorageService.instance.secureRead(_kUserTokenKey);
    final savedRefreshToken = await StorageService.instance.secureRead(_kRefreshTokenKey);
    final savedUserDataStr = StorageService.instance.read(_kUserDataKey);

    UserData? userData;
    if (savedUserDataStr != null) {
      try {
        userData = UserData.fromJson(jsonDecode(savedUserDataStr));
      } catch (_) {
        // Corrupted data
      }
    }

    if (savedToken != null && savedToken.isNotEmpty) {
      // Reconstruct UserModel from storage
       return UserModel(
        userData: userData,
        tokenData: TokenData(
          accessToken: savedToken,
          refreshToken: savedRefreshToken ?? '',
          accessTokenExpiresAt: '', // Not stored currently, could be added
          refreshTokenExpiresAt: '',
          tokenType: 'Bearer',
        ),
        isAuthenticated: true,
      );
    }

    return UserModel.empty();
  }

  Future<void> signIn(String login, String password, {required bool rememberMe}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final data = await repo.login(login, password);
      final user = UserModel.fromJson(data);

      await StorageService.instance.writeBool(_kRememberMeKey, rememberMe);
      
      if (user.tokenData != null) {
        await StorageService.instance.secureWrite(_kUserTokenKey, user.tokenData!.accessToken);
        await StorageService.instance.secureWrite(_kRefreshTokenKey, user.tokenData!.refreshToken);
      }

      if (user.userData != null) {
        await StorageService.instance.write(_kUserDataKey, jsonEncode(user.userData!.toJson()));
      }

      // On sauvegarde TOUJOURS le mot de passe de manière sécurisée pour les confirmations d'opérations sensibles
      await StorageService.instance.secureWrite(_kUserPasswordKey, password);
      
      return user;
    });
  }

  bool getRememberMe() => StorageService.instance.readBool(_kRememberMeKey);

  Future<void> logout() async {
    try {
      final refreshToken = await StorageService.instance.secureRead(_kRefreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final repo = ref.read(authRepositoryProvider);
        await repo.logout(refreshToken);
      }
    } catch (_) {
      // Continue local logout even if server fails
    }

    // Keep login if remember me? 
    // Usually logout clears everything session related.
    // But if remember me is on, we might want to keep the login field on the login page prefilled.
    // The previous implementation kept 'user_login' in storage (which I didn't see explicitly saved in the new signIn, but UserModel.login accessor retrieves it from UserData).
    
    // We should clear tokens.
    await StorageService.instance.secureRemove(_kUserTokenKey);
    await StorageService.instance.secureRemove(_kRefreshTokenKey);
    await StorageService.instance.secureRemove(_kUserPasswordKey);
    
    // Clear user data? Yes, session is over.
    await StorageService.instance.remove(_kUserDataKey);

    await ref.read(biometricEnabledProvider.notifier).setEnabled(false);
    
    state = AsyncValue.data(UserModel.empty());
  }

  /// Called by the Interceptor when a new token is received
  Future<void> updateToken(String newAccessToken, String newRefreshToken) async {
    await StorageService.instance.secureWrite(_kUserTokenKey, newAccessToken);
    await StorageService.instance.secureWrite(_kRefreshTokenKey, newRefreshToken);
    
    // Update state without triggering full rebuild if possible, or just rebuild
    // Since state is immutable, we create a new UserModel with updated tokens
    if (state.value != null) {
      final currentUser = state.value!;
      final newTokenData = TokenData(
        accessToken: newAccessToken, 
        refreshToken: newRefreshToken, 
        accessTokenExpiresAt: currentUser.tokenData?.accessTokenExpiresAt ?? '', 
        refreshTokenExpiresAt: currentUser.tokenData?.refreshTokenExpiresAt ?? '', 
        tokenType: 'Bearer'
      );
      
      state = AsyncValue.data(currentUser.copyWith(tokenData: newTokenData));
    }
  }

  Future<void> refreshUserStats() async {
    if (state.value == null || state.value!.userData == null) return;

    try {
      final repo = ref.read(authRepositoryProvider);
      final stats = await repo.fetchUserStats();

      final currentUser = state.value!;
      final currentData = currentUser.userData!;

      final newData = currentData.copyWith(
        nombreActivation: stats['nombre_Activation'] ?? currentData.nombreActivation,
        nombreReactivation: stats['nombre_Reactivation'] ?? currentData.nombreReactivation,
        nombreMiseAJour: stats['nombre_Mise_A_Jour'] ?? currentData.nombreMiseAJour,
      );

      // 1. Update State
      state = AsyncValue.data(currentUser.copyWith(userData: newData));

      // 2. Persist to Storage
      await StorageService.instance.write(_kUserDataKey, jsonEncode(newData.toJson()));
    } catch (e) {
      // Slient fail or log error
      print('Error refreshing stats: $e');
    }
  }
  Future<void> updatePassword(String newPassword) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.updatePassword(newPassword);
    
    // Update local password storage for future verification or re-login
    await StorageService.instance.secureWrite(_kUserPasswordKey, newPassword);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel>(AuthNotifier.new);