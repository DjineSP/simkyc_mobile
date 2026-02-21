import 'dart:convert';
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
        'sexe': item['sexe'],
      };
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
      if (statusCode == 404) throw Exception("Abonné introuvable");
      if (statusCode == 500) throw Exception("Erreur serveur lors de la recherche");
      
      throw Exception(e.message ?? 'Erreur réseau');
    }
  }

  String? _toBackendDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    try {
      // Si format dd/MM/yyyy
      if (dateStr.toString().contains('/')) {
        final parts = dateStr.toString().split('/');
        if (parts.length == 3) {
           // yyyy-MM-dd
           return '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }
      // Sinon on renvoie tel quel (déjà yyyy-MM-dd ou autre)
      return dateStr.toString();
    } catch (_) {
      return dateStr.toString();
    }
  }

  Future<Map<String, dynamic>> updateClient({
    required int idActivationSim,
    required Map<String, dynamic> fields,
    required File idFront,
    required File idBack,
  }) async {
    try {
      final String base64Front = base64Encode(await idFront.readAsBytes());
      final String base64Back = base64Encode(await idBack.readAsBytes());

      // Construction du payload exact demandé
      final Map<String, dynamic> payload = {
        "idActivationSim": idActivationSim,
        "numeroTelephoneClient": fields['telephone'] ?? fields['msisdn'],
        "dateMiseAJour": DateTime.now().toIso8601String(),
        "etat": 0,
        "saveByPos": true,
        "idNaturePiece": fields['idNaturePiece'] ?? 0,
        "idFrontImage": base64Front,
        "idBackImage": base64Back,
        "noms": fields['nom'],
        "prenoms": fields['prenom'],
        "sexe": fields['sexe'], // bool
        "dateNaissance": _toBackendDate(fields['dateNaissance']),
        "lieuNaissance": fields['lieuNaissance'],
        "profession": fields['profession'],
        "dateValiditePiece": _toBackendDate(fields['dateValiditePiece']),
        "numeroPiece": fields['numeroPiece'],
        "adressePostale": fields['adressePostale'],
        "mail": fields['mail'],
        "adresseGeographique": fields['adresseGeo']
      };

      final response = await ApiClient.instance.dio.post(
        _kUpdatePath,
        data: payload,
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

      if (e.response?.data is String) {
         final raw = e.response?.data as String;
         if (raw.isNotEmpty) throw Exception(raw);
      }
      
      final statusCode = e.response?.statusCode;
      if (statusCode == 400) throw Exception("Données de mise à jour invalides");
      if (statusCode == 413) throw Exception("Images trop volumineuses");
      if (statusCode == 500) throw Exception("Erreur serveur lors de la mise à jour");
      
      throw Exception(e.message ?? 'Erreur réseau');
    }
  }
}

final simUpdateRepositoryProvider = Provider<SimUpdateRepository>((ref) => SimUpdateRepository());
