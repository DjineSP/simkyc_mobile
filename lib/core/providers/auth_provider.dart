import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../shared/models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthNotifier extends AsyncNotifier<UserModel> {
  static const _kUserPhoneKey = 'user_phone';

  @override
  Future<UserModel> build() async {
    final savedPhone = LocalStorageService.instance.read(_kUserPhoneKey) ?? '';
    return UserModel(
      phoneNumber: savedPhone,
      token: null,
      isAuthenticated: false,
    );
  }

  Future<void> signIn(String phone, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final data = await repo.login(phone, password);
      final user = UserModel.fromJson(data);

      await LocalStorageService.instance.write(_kUserPhoneKey, user.phoneNumber);
      return user;
    });
  }

  Future<void> logout() async {
    final currentPhone = state.asData?.value.phoneNumber ?? '';
    state = AsyncValue.data(
      UserModel(
        phoneNumber: currentPhone,
        token: null,
        isAuthenticated: false,
      ),
    );
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel>(AuthNotifier.new);