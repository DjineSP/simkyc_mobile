import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';

class SimUpdateRepository {
  static const String _kLookupPath = '/sim/update';
  static const String _kUpdatePath = '/sim/update';

  // Future<Map<String, dynamic>> fetchActivationByPhone(String msisdn) async {
  //   try {
  //     final response = await ApiClient.instance.dio.get(
  //       _kLookupPath,
  //       queryParameters: {'msisdn': msisdn},
  //     );

  //     final data = response.data;
  //     if (data is! Map<String, dynamic>) {
  //       throw Exception('Réponse backend invalide');
  //     }

  //     final dynamic result = data['result'] ?? data['success'] ?? data['ok'];
  //     final bool isOk = result is bool ? result : true;
  //     final String? message = (data['message'] ?? data['error'] ?? data['detail'])?.toString();

  //     if (!isOk) {
  //       throw Exception(message ?? 'Recherche activation échouée');
  //     }

  //     final dynamic payload = data['data'] ?? data['item'] ?? data['activation'] ?? data['resultData'];
  //     if (payload is Map) {
  //       return Map<String, dynamic>.from(payload);
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

  Future<Map<String, dynamic>> fetchActivationByPhone(String msisdn) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (msisdn.trim().isEmpty) {
      throw Exception('Numéro de téléphone requis');
    }
    if (msisdn.endsWith('000')) {
      throw Exception('Abonné introuvable');
    }
    return {
      'msisdn': msisdn,
      'nom': 'DJINE',
      'prenom': 'SINTO PAFING',
      'sexe': true,
      'dateNaissance': '15/03/1990',
      'lieuNaissance': 'Conakry',
      'profession': 'Ingénieur',
      'adresseGeo': 'Kaloum, Conakry',
      'adressePostale': 'BP 1024 Conakry',
      'mail': 'sinto.pafing@outlook.com',
      'idNaturePiece': 2,
      'numeroPiece': '123456789',
      'dateValiditePiece': '20/12/2028',
      'idFront': 'data:image/png;base64,SGVsbG8=',
      'idBack': 'data:image/png;base64,V29ybGQ=',
    };
  }

  // Future<Map<String, dynamic>> updateClient({
  //   required Map<String, dynamic> fields,
  //   required File idFront,
  //   required File idBack,
  // }) async {
  //   try {
  //     final formData = FormData.fromMap({
  //       ...fields,
  //       'idFront': await MultipartFile.fromFile(idFront.path, filename: idFront.uri.pathSegments.last),
  //       'idBack': await MultipartFile.fromFile(idBack.path, filename: idBack.uri.pathSegments.last),
  //     });

  //     final response = await ApiClient.instance.dio.post(
  //       _kUpdatePath,
  //       data: formData,
  //       options: Options(
  //         contentType: 'multipart/form-data',
  //       ),
  //     );

  //     final data = response.data;
  //     if (data is! Map<String, dynamic>) {
  //       throw Exception('Réponse backend invalide');
  //     }

  //     final dynamic result = data['result'] ?? data['success'] ?? data['ok'];
  //     final bool isOk = result is bool ? result : true;
  //     final String? message = (data['message'] ?? data['error'] ?? data['detail'])?.toString();

  //     if (!isOk) {
  //       throw Exception(message ?? 'Mise à jour échouée');
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

  Future<Map<String, dynamic>> updateClient({
    required Map<String, dynamic> fields,
    required File idFront,
    required File idBack,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!fields.containsKey('msisdn') || (fields['msisdn']?.toString().isEmpty ?? true)) {
      throw Exception('MSISDN requis');
    }
    if (!idFront.existsSync() || !idBack.existsSync()) {
      throw Exception('Photos de la pièce requises');
    }
    return {
      'result': true,
      'message': 'Mise à jour effectuée avec succès (simulation)',
      'data': {
        ...fields,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    };
  }
}

final simUpdateRepositoryProvider = Provider<SimUpdateRepository>((ref) => SimUpdateRepository());
