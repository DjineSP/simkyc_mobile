import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';

class SimReactivationRepository {

  Future<Map<String, dynamic>> fetchActivationByPhone(String msisdn) async {
    try {
      final response = await ApiClient.instance.dio.get(
        '/api/Reactivation_Sim',
        queryParameters: {'numeroClient': msisdn},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Réponse backend invalide');
      }

      final dynamic result = data['succes'];
      final bool isOk = result is bool ? result : true;
      final String? message = data['message'].toString();

      if (!isOk) {
        throw Exception(message ?? 'Recherche activation échouée');
      }

      final dynamic payload = data['data'] ?? data['item'] ?? data['activation'] ?? data['resultData'];
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
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
      throw Exception(e.message ?? 'Erreur réseau');
    }
  }

  // Future<Map<String, dynamic>> fetchActivationByPhone(String msisdn) async {
  //   await Future.delayed(const Duration(milliseconds: 800));
  //   if (msisdn.trim().isEmpty) {
  //     throw Exception('Numéro de téléphone requis');
  //   }
  //   if (msisdn.endsWith('000')) {
  //     throw Exception('Activation introuvable');
  //   }
  //   return {
  //     'msisdn': msisdn,
  //     'serial': '8922410123456789012',
  //     'status': 'Suspendue (Perte)',
  //     'nom': 'DJINE',
  //     'prenom': 'SINTO PAFING',
  //     'dateNaissance': '22/05/2005',
  //     'lieuNaissance': 'Conakry',
  //     'sexe': 'Homme',
  //     'profession': 'Etudiant',
  //     'adresseGeo': 'Kipé, Rue KI-142, Conakry',
  //     'adressePostale': 'BP 1024 Conakry',
  //     'mail': 'djine.pafing@gmail.com',
  //     'idNaturePiece': 'CNI',
  //     'numeroPiece': 'GN-12345678-22',
  //     'dateValiditePiece': '14/11/2028',
  //   };
  // }

  // Future<Map<String, dynamic>> reactivateSim({
  //   required String newMsisdn,
  //   String? contactOne,
  //   String? contactTwo,
  //   String? contactThree,
  // }) async {
  //   try {
  //     final response = await ApiClient.instance.dio.post(
  //       _kReactivatePath,
  //       data: {
  //         'newMsisdn': newMsisdn,
  //         'contactOne': contactOne,
  //         'contactTwo': contactTwo,
  //         'contactThree': contactThree,
  //       },
  //     );

  //     final data = response.data;
  //     if (data is! Map<String, dynamic>) {
  //       throw Exception('Réponse backend invalide');
  //     }

  //     final dynamic result = data['result'] ?? data['success'] ?? data['ok'];
  //     final bool isOk = result is bool ? result : true;
  //     final String? message = (data['message'] ?? data['error'] ?? data['detail'])?.toString();

  //     if (!isOk) {
  //       throw Exception(message ?? 'Réactivation échouée');
  //     }

  //     return data;
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

  Future<Map<String, dynamic>> reactivateSim({
    required String newMsisdn,
    String? contactOne,
    String? contactTwo,
    String? contactThree,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (newMsisdn.trim().isEmpty) {
      throw Exception('Nouveau MSISDN requis');
    }
    return {
      'result': true,
      'message': 'Réactivation effectuée avec succès (simulation)',
      'data': {
        'newMsisdn': newMsisdn,
        'contactOne': contactOne,
        'contactTwo': contactTwo,
        'contactThree': contactThree,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    };
  }
}

final simReactivationRepositoryProvider = Provider<SimReactivationRepository>((ref) => SimReactivationRepository());
