import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  // Simule un appel Backend (ex: avec Dio ou Http)
  Future<Map<String, dynamic>> login(String login, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulation délai réseau

    // Ici tu feras : return await dio.post('/login', data: {...});
    if (password == "1234") {
      return {
        'login': login,
        'token': 'abc_123_xyz_token_secret',
      };
    } else {
      throw Exception("Identifiants invalides");
    }
  }

  Future<bool> verifyPassword(String login, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return password == '1234';
  }
}

// Provider pour accéder au repository
final authRepositoryProvider = Provider((ref) => AuthRepository());