import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepository {

  // // Simule un appel Backend (ex: avec Dio ou Http)
  // Future<Map<String, dynamic>> login(String login, String password) async {
  //   await Future.delayed(const Duration(seconds: 2)); // Simulation délai réseau

  //   // Ici tu feras : return await dio.post('/login', data: {...});
  //   if (password == "1234") {
  //     return {
  //       'login': login,
  //       'token': 'abc_123_xyz_token_secret',
  //     };
  //   } else {
  //     throw Exception("Identifiants invalides");
  //   }
  // }

  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/api/Login/login',
        options: Options(
          extra: {'requiresAuth': false},
        ),
        data: {
          'username': login,
          'password': password,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Réponse backend invalide');
      }

      final bool isOk = data['succes'] == true; 
      final String? message = data['message']?.toString();
      final String? token = data['token']?.toString();

      if (!isOk) {
        throw Exception(message ?? 'Connexion échouée');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Erreur : Token non reçu du serveur');
      }

      return {
        'login': login,
        'token': token,
        'message': message,
      };

    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final msg = responseData['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          throw Exception(msg);
        }
      }
      throw Exception(e.message ?? 'Erreur réseau');
    }
  }

  Future<bool> verifyPassword(String login, String password) async {
    final savedPassword = await StorageService.instance.secureRead('user_password');
    if (savedPassword == null || savedPassword.isEmpty) return false;
    return savedPassword == password;
  }
}

// Provider pour accéder au repository
final authRepositoryProvider = Provider((ref) => AuthRepository());