import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/history_detail.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryItem>> getHistory({required DateTime startDate, required DateTime endDate});
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<HistoryItem>> getHistory({required DateTime startDate, required DateTime endDate}) async {
    try {
      final data = {
        "debut": startDate.toIso8601String(),
        "fin": endDate.toIso8601String(),
      };
      
      final response = await _dio.post('/api/Login/historique', data: data);
      
      if (response.statusCode == 200 && response.data != null) {
        return _parseHistoryResponse(response.data);
      }
      return [];
    } catch (e) {
      debugPrint("Erreur GetHistory: $e");
      return [];
    }
  }

  List<HistoryItem> _parseHistoryResponse(dynamic data) {
    if (data is! Map<String, dynamic> || data['result'] == null) return [];
    
    final List<dynamic> resultTags = data['result'];
    final List<HistoryItem> allOperations = [];
    
    for (var tag in resultTags) {
      if (tag is Map<String, dynamic> && tag['operations'] != null) {
        final operations = tag['operations'] as List<dynamic>;
        for (var op in operations) {
          allOperations.add(_mapOperationToHistoryItem(op));
        }
      }
    }
    
    return allOperations;
  }

  HistoryItem _mapOperationToHistoryItem(dynamic json) {
    // Mapping des champs
    final id = json['id']?.toString() ?? '';
    final typeCode = json['type'] ?? 0;
    
    HistoryActionType type;
    switch (typeCode) {
      case 1:
        type = HistoryActionType.reactivation;
        break;
      case 2:
        type = HistoryActionType.update;
        break;
      case 0:
      default:
        type = HistoryActionType.activation;
        break;
    }
    
    final msisdn = json['msisdn']?.toString() ?? '';
    final clientName = json['client'] ?? '${json['noms'] ?? ''} ${json['prenoms'] ?? ''}'.trim();
    final etat = json['etat'] ?? 0;
    final status = HistoryStatus.fromCode(etat is int ? etat : 0);
    
    DateTime operationDate = DateTime.now();
    if (json['date_Operation'] != null) {
      operationDate = DateTime.tryParse(json['date_Operation']) ?? DateTime.now();
    }

    final info = json['profession'] ?? json['nature_Piece'] ?? '';

    // Création des détails
    final details = HistoryDetail(
      id: id,
      msisdn: msisdn,
      dateActivation: operationDate, // Ou autre date si dispo
      etat: etat is int ? etat : 0,
      noms: json['noms'],
      prenoms: json['prenoms'],
      sexe: json['sexe'], // bool direct dans le json
      dateNaissance: json['date_Naissance'] != null ? DateTime.tryParse(json['date_Naissance']) : null,
      lieuNaissance: json['lieu_Naissance'],
      profession: json['profession'],
      dateValiditePiece: json['date_Validite_Piece'] != null ? DateTime.tryParse(json['date_Validite_Piece']) : null,
      numeroPiece: json['numero_Piece'],
      adressePostale: json['adresse_Postale'],
      numeroTelephoneClient: json['numero_Telephone_Client'],
      mail: json['mail'],
      adresseGeographique: json['adresse_geographique'],
      // Mapper les autres champs si présents ou nécessaires
      // idNaturePiece, idFrontImage, etc ne sont pas dans l'exemple JSON mais peuvent être null
    );

    return HistoryItem(
      id: id,
      msisdn: msisdn,
      clientName: clientName,
      info: info,
      operationDate: operationDate,
      status: status,
      type: type,
      details: details,
    );
  }
}
