import 'dart:async';

import '../models/profile_data.dart';

class ProfileRepository {
  Future<ProfileData> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return ProfileData(
      fullName: 'Pafing Tedy',
      agentId: 'AGT-00123',
      roleLabel: 'Back Office',
      lastLogin: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
    );
  }
}
