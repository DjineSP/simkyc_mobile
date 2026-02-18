import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';

class SimActivationRepository {
  Future<List<Map<String, dynamic>>> fetchIdNatures() async {
    try {
      final response = await ApiClient.instance.dio.get('/api/Nature_Piece/all');
      
      final data = response.data;

      if (data is List) {
        // Transformation directe de la liste reçue vers le format souhaité
        return data.map((item) {
          return {
            'id': item['iD_Nature_Piece'],
            'libelle': item['libelle_Nature_Piece'],
          };
        }).toList();
      }

      throw Exception('Format de réponse invalide : Liste attendue');

    } on DioException catch (e) {
      // Récupération du message d'erreur simplifié
      final msg = (e.response?.data is Map) ? e.response?.data['message'] : null;
      if (msg != null) throw Exception(msg);
      
      if (e.response?.data is String) {
         final raw = e.response?.data as String;
         if (raw.isNotEmpty) throw Exception(raw);
      }
      
      
      final statusCode = e.response?.statusCode;
      if (statusCode == 500) throw Exception("Erreur serveur interne lors de la récupération des natures");
      if (statusCode == 404) throw Exception("Service des natures de pièces indisponible");
      
      throw Exception(e.message ?? 'Erreur lors de la récupération des natures');
    }
  }

  // Future<List<Map<String, dynamic>>> fetchIdNatures() async {
  //   await Future.delayed(const Duration(milliseconds: 500));
    // return [
    //   {'id': 1, 'libelle': 'CNI'},
    //   {'id': 2, 'libelle': 'Passeport'},
    //   {'id': 3, 'libelle': 'Carte de séjour'},
    //   {'id': 4, 'libelle': 'Récépissé'},
    //   {'id': 5, 'libelle': 'Permis de conduire'},
    // ];
  // }

  // Future<String> fetchMsisdnFromSerial(String serial) async {
  //   try {
  //     final response = await ApiClient.instance.dio.post(
  //       '/sim/msisdn',
  //       data: {'serial': serial},
  //     );

  //     final data = response.data;
  //     if (data is! Map<String, dynamic>) {
  //       throw Exception('Réponse backend invalide');
  //     }

  //     final dynamic result = data['result'] ?? data['success'] ?? data['ok'];
  //     final bool isOk = result is bool ? result : true;
  //     final String? message = (data['message'] ?? data['error'] ?? data['detail'])?.toString();
  //     final String? msisdn = data['msisdn']?.toString();

  //     if (!isOk) {
  //       throw Exception(message ?? 'Recherche MSISDN échouée');
  //     }
  //     if (msisdn == null || msisdn.isEmpty) {
  //       throw Exception(message ?? 'MSISDN introuvable');
  //     }

  //     return msisdn;
  //   } on DioException catch (e) {
  //     final responseData = e.response?.data;
  //     if (responseData is Map<String, dynamic>) {
  //       final msg = (responseData['message'] ?? responseData['error'] ?? responseData['detail'])?.toString();
  //       if (msg != null && msg.isNotEmpty) {
  //         throw Exception(msg);
  //       }
  //     }
  //     throw Exception(e.message ?? 'Erreur réseau');
  //   }
  // }

  Future<String> fetchMsisdnFromSerial(String serial) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (serial.trim().isEmpty) {
      throw Exception('Numéro de série invalide');
    }
    if (serial.endsWith('000')) {
      throw Exception('MSISDN introuvable');
    }
    final random = Random();
    // Génère 8 chiffres aléatoires
    String digits = '';
    for (int i = 0; i < 8; i++) {
      digits += random.nextInt(10).toString();
    }
    return '6$digits';
  }

  Future<Map<String, dynamic>> activateSim({
    required Map<String, dynamic> fields,
    required File idFront,
    required File idBack,
  }) async {
    try {
            
      final String base64Front = base64Encode(await idFront.readAsBytes());
      final String base64Back = base64Encode(await idBack.readAsBytes());

      final response = await ApiClient.instance.dio.post(
        '/api/Activation_Sim/Activer_Sim',
        data: {
          ...fields,
          'idFrontImage': base64Front,
          'idBackImage': base64Back,
          'savedByPos': true
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Réponse backend invalide');
      }

      final dynamic result = data['result'] ?? data['success'] ?? data['ok'];
      final bool isOk = result is bool ? result : true;
      final String? message = (data['message'] ?? data['error'] ?? data['detail'])?.toString();

      if (!isOk) {
        throw Exception(message ?? 'Activation échouée');
      }

      return data;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final msg = (responseData['message'] ?? responseData['error'] ?? responseData['detail'])?.toString();
        if (msg != null && msg.isNotEmpty) {
          throw Exception(msg);
        }
      }

      if (e.response?.data is String) {
         final raw = e.response?.data as String;
         if (raw.isNotEmpty) throw Exception(raw);
      }
      
      final statusCode = e.response?.statusCode;
      if (statusCode == 400) throw Exception("Données d'activation invalides");
      if (statusCode == 500) throw Exception("Erreur serveur lors de l'activation");
      
      throw Exception(e.message ?? 'Erreur réseau lors de l\'activation');
    }
  }

  // Future<Map<String, dynamic>> activateSim({
  //   required Map<String, dynamic> fields,
  //   required File idFront,
  //   required File idBack,
  // }) async {
  //   await Future.delayed(const Duration(seconds: 1));
  
  //   if (!fields.containsKey('msisdn') || (fields['msisdn']?.toString().isEmpty ?? true)) {
  //     throw Exception('MSISDN requis');
  //   }
  //   if (!idFront.existsSync() || !idBack.existsSync()) {
  //     throw Exception('Photos de la pièce requises');
  //   }
  
  //   return {
  //     'result': true,
  //     'message': 'Activation effectuée avec succès (simulation)',
  //     'data': {
  //       'activationId': 123456,
  //       'msisdn': fields['msisdn'],
  //       'serial': fields['serial'],
  //       'status': 'ACTIVATED',
  //       'date': DateTime.now().toIso8601String(),
  //     },
  //   };
  // }
}

final simActivationRepositoryProvider = Provider<SimActivationRepository>((ref) => SimActivationRepository());

final idNaturesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(simActivationRepositoryProvider);
  // Cache the data for the session
  ref.keepAlive();
  return repo.fetchIdNatures();
});
