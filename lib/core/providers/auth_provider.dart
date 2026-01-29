import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../shared/models/user_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/storage_service.dart';

class AuthNotifier extends AsyncNotifier<UserModel> {
  static const _kUserLoginKey = 'user_login';
  static const _kUserTokenKey = 'user_token';
  static const _kUserPasswordKey = 'user_password';
  static const _kRememberMeKey = 'remember_me';

  @override
  Future<UserModel> build() async {
    final savedLogin = StorageService.instance.read(_kUserLoginKey) ?? '';
    final savedToken = await StorageService.instance.secureRead(_kUserTokenKey);
    return UserModel(
      login: savedLogin,
      token: savedToken,
      isAuthenticated: (savedToken != null && savedToken.isNotEmpty),
    );
  }

  Future<void> signIn(String login, String password, {required bool rememberMe}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final data = await repo.login(login, password);
      final user = UserModel.fromJson(data);

      await StorageService.instance.write(_kUserLoginKey, user.login);
      await StorageService.instance.writeBool(_kRememberMeKey, rememberMe);
      if (user.token != null && user.token!.isNotEmpty) {
        await StorageService.instance.secureWrite(_kUserTokenKey, user.token!);
      }

      if (rememberMe) {
        await StorageService.instance.secureWrite(_kUserPasswordKey, password);
      } else {
        await StorageService.instance.secureRemove(_kUserPasswordKey);
      }
      return user;
    });
  }

  bool getRememberMe() => StorageService.instance.readBool(_kRememberMeKey);

  Future<void> logout() async {
    final currentLogin = state.asData?.value.login ?? '';
    await StorageService.instance.secureRemove(_kUserTokenKey);
    await StorageService.instance.secureRemove(_kUserPasswordKey);
    await ref.read(biometricEnabledProvider.notifier).setEnabled(false);
    state = AsyncValue.data(
      UserModel(
        login: currentLogin,
        token: null,
        isAuthenticated: false,
      ),
    );
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel>(AuthNotifier.new);