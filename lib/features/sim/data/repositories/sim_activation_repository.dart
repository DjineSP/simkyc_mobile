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

  Future<String> fetchMsisdnFromSerial(String serial) async {
    try {

      final response = await ApiClient.instance.dio.get(
        '/api/Activation_Sim/GetMSISDN/$serial',
        options: Options(responseType: ResponseType.plain),
      );

      final data = response.data?.toString();
      
      if (data == null || data.isEmpty) {
        throw Exception('Réponse vide du serveur');
      }

      // Le serveur renvoie soit le MSISDN (ex: "658802241"), soit un message d'erreur
      // On considère que c'est un MSISDN valide s'il ne contient que des chiffres (et éventuellement des espaces)
      final cleanData = data.replaceAll(RegExp(r'\s+'), '');
      if (RegExp(r'^\d+$').hasMatch(cleanData)) {
         return cleanData;
      }

      // Sinon, c'est un message d'erreur texte (ex: "La carte SIM a été annulée...")
      throw Exception(data);

    } on DioException catch (e) {
      if (e.response?.data != null) {
         final raw = e.response?.data.toString();
         if (raw != null && raw.isNotEmpty) {
           throw Exception(raw);
         }
      }
      
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) throw Exception("Numéro de série introuvable");
      if (statusCode == 500) throw Exception("Erreur serveur lors de la récupération du MSISDN");
      
      throw Exception(e.message ?? 'Erreur lors de la récupération du MSISDN');
    }
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
}

final simActivationRepositoryProvider = Provider<SimActivationRepository>((ref) => SimActivationRepository());

final idNaturesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(simActivationRepositoryProvider);
  // Cache the data for the session
  ref.keepAlive();
  return repo.fetchIdNatures();
});
