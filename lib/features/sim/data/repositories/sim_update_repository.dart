import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';

class SimUpdateRepository {
  static const String _kLookupPath = '/api/MiseAJour';
  static const String _kUpdatePath = '/api/MiseAJour';

  String? _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    try {
      // Tente de parser yyyy-MM-dd
      final date = DateTime.parse(dateStr.toString());
      // Retourne dd/MM/yyyy
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr.toString(); // Retourne tel quel si échec
    }
  }

  Future<Map<String, dynamic>> fetchActivationByPhone(String msisdn) async {
    try {
      final response = await ApiClient.instance.dio.get(
        '$_kLookupPath/$msisdn',
      );

      final data = response.data;
      Map<String, dynamic> item;

      if (data is List && data.isNotEmpty) {
        item = data.first as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
         // Fallback si jamais c'est un objet unique
         // Vérifier si c'est encapsulé dans result/data
         if (data.containsKey('data')) {
           final inner = data['data'];
           if (inner is List && inner.isNotEmpty) {
             item = inner.first;
           } else if (inner is Map<String, dynamic>) {
             item = inner;
           } else {
             item = data;
           }
         } else {
            item = data;
         }
      } else {
        throw Exception('Aucune donnée trouvée pour ce numéro');
      }

      // Normalisation des données pour l'UI
      return {
        ...item,
        'nom': item['noms'],
        'prenom': item['prenoms'],
        'adresseGeo': item['adresseGeographique'],
        'dateNaissance': _formatDate(item['dateNaissance']),
        'dateValiditePiece': _formatDate(item['dateValiditePiece']),
        'sexe': item['sexe'], // bool
        // Conserver les autres champs bruts si besoin (idNaturePiece, numeroPiece, etc)
      };
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
  //     throw Exception('Abonné introuvable');
  //   }
  //   return {
  //     'msisdn': msisdn,
  //     'nom': 'DJINE',
  //     'prenom': 'SINTO PAFING',
  //     'sexe': true,
  //     'dateNaissance': '15/03/1990',
  //     'lieuNaissance': 'Conakry',
  //     'profession': 'Ingénieur',
  //     'adresseGeo': 'Kaloum, Conakry',
  //     'adressePostale': 'BP 1024 Conakry',
  //     'mail': 'sinto.pafing@outlook.com',
  //     'idNaturePiece': 2,
  //     'numeroPiece': '123456789',
  //     'dateValiditePiece': '20/12/2028',
  //     'idFront': 'data:image/png;base64,SGVsbG8=',
  //     'idBack': 'data:image/png;base64,V29ybGQ=',
  //   };
  // }

  Future<Map<String, dynamic>> updateClient({
    required Map<String, dynamic> fields,
    required File idFront,
    required File idBack,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        'idFront': await MultipartFile.fromFile(idFront.path, filename: idFront.uri.pathSegments.last),
        'idBack': await MultipartFile.fromFile(idBack.path, filename: idBack.uri.pathSegments.last),
      });

      final response = await ApiClient.instance.dio.post(
        _kUpdatePath,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Réponse backend invalide');
      }

      final dynamic result = data['result'] ?? data['success'] ?? data['ok'];
      final bool isOk = result is bool ? result : true;
      final String? message = (data['message'] ?? data['error'] ?? data['detail'])?.toString();

      if (!isOk) {
        throw Exception(message ?? 'Mise à jour échouée');
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

  // Future<Map<String, dynamic>> updateClient({
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
  //     'message': 'Mise à jour effectuée avec succès (simulation)',
  //     'data': {
  //       ...fields,
  //       'updatedAt': DateTime.now().toIso8601String(),
  //     },
  //   };
  // }
}

final simUpdateRepositoryProvider = Provider<SimUpdateRepository>((ref) => SimUpdateRepository());
