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

      if (data['success'] != true) {
        throw Exception(data['message']?.toString() ?? 'Connexion échouée');
      }

      return data;

    } on DioException catch (e) {
      if (e.response != null && (e.response!.statusCode == 400 || e.response!.statusCode == 401)) {
        throw Exception('Bad Credentials');
      }
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

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/api/Login/refresh',
        options: Options(
          extra: {'requiresAuth': false}, 
        ),
        data: {
          'refreshToken': refreshToken,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic> || data['success'] != true) {
         throw Exception('Echec du rafraichissement du token');
      }
      return data;
      
    } catch (e) {
      throw Exception('Session expirée');
    }
  }

  Future<bool> verifyPassword(String login, String password) async {
    final savedPassword = await StorageService.instance.secureRead('user_password');
    if (savedPassword == null || savedPassword.isEmpty) return false;
    return savedPassword == password;
  }
  Future<Map<String, dynamic>> fetchUserStats() async {
    try {
      final response = await ApiClient.instance.dio.get('/api/Login/statistique');
      /*
      API Response format:
      {
        "nombre_Activation": 10,
        "nombre_Reactivation": 5,
        "nombre_Mise_A_Jour": 2
      }
      */
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Erreur lors de la récupération des statistiques');
    }
  }
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/api/Login/update',
        data: {'newPassWord': newPassword},
        options: Options(
          extra: {'requiresAuth': true}, // Token is required
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic> || data['success'] != true) {
         throw Exception(data['message']?.toString() ?? 'Echec de la mise à jour du mot de passe');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final msg = responseData['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          throw Exception(msg);
        }
      }
      throw Exception(e.message ?? 'Erreur réseau lors de la mise à jour du mot de passe');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await ApiClient.instance.dio.post(
        '/api/Login/logout',
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: {'requiresAuth': true}, 
        ),
      );
    } catch (_) {
      // On ignore les erreurs de déconnexion (token déjà invalide, réseau, etc.)
      // Le but est surtout de clear le local storage après.
    }
  }
}

// Provider pour accéder au repository
final authRepositoryProvider = Provider((ref) => AuthRepository());