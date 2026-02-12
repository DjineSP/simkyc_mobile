import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/history_detail.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryItem>> getActivations();
  Future<List<HistoryItem>> getReactivations();
  Future<List<HistoryItem>> getUpdates();
  
  Future<HistoryDetail?> getActivationDetail(String id);
  Future<HistoryDetail?> getReactivationDetail(String id);
  Future<HistoryDetail?> getUpdateDetail(String id);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<HistoryItem>> getActivations() async {
    try {
      // Endpoint déduit. À confirmer avec le backend.
      final response = await _dio.get('/api/Activation_Sim/all'); 
      return _parseList(response.data, HistoryActionType.activation);
    } catch (e) {
      // En cas d'erreur ou 404, on retourne une liste vide pour ne pas bloquer les autres flux
      debugPrint("Erreur Activations: $e");
      return [];
    }
  }

  @override
  Future<List<HistoryItem>> getReactivations() async {
    try {
      final response = await _dio.get('/api/Reactivation_Sim/all');
      return _parseList(response.data, HistoryActionType.reactivation);
    } catch (e) {
      debugPrint("Erreur Reactivations: $e");
      return [];
    }
  }

  @override
  Future<List<HistoryItem>> getUpdates() async {
    try {
      final response = await _dio.get('/api/MiseAJour/all');
      return _parseList(response.data, HistoryActionType.update);
    } catch (e) {
      debugPrint("Erreur Updates: $e");
      return [];
    }
  }

  @override
  Future<HistoryDetail?> getActivationDetail(String id) async {
    debugPrint("Calling getActivationDetail with ID: $id");
    try {
      final response = await _dio.get('/api/Activation_Sim/$id');
      debugPrint("Response Detail: ${response.data}");
      return HistoryDetail.fromJson(response.data);
    } catch (e) {
      debugPrint("Erreur GetActivationDetail: $e");
      return null;
    }
  }

  @override
  Future<HistoryDetail?> getReactivationDetail(String id) async {
    debugPrint("Calling getReactivationDetail with ID: $id");
    try {
      final response = await _dio.get('/api/Reactivation_Sim/$id');
      return HistoryDetail.fromJson(response.data);
    } catch (e) {
      debugPrint("Erreur GetReactivationDetail: $e");
      return null;
    }
  }

  @override
  Future<HistoryDetail?> getUpdateDetail(String id) async {
    debugPrint("Calling getUpdateDetail with ID: $id");
    try {
      final response = await _dio.get('/api/MiseAJour/$id');
      return HistoryDetail.fromJson(response.data);
    } catch (e) {
      debugPrint("Erreur GetUpdateDetail: $e");
      return null;
    }
  }

  List<HistoryItem> _parseList(dynamic data, HistoryActionType type) {
    if (data is! List) return [];
    
    return data.map((json) {
      // Mapping basé sur le JSON fourni par le user
      // Adaptation des clés selon le type si nécessaire (ici on utilise des clés génériques ou tentatives)
      
      // ID: Dépend du type
      String id = '';
      if (type == HistoryActionType.activation) {
        id = (json['iD_Activation_Sim'] ?? json['id'])?.toString() ?? '';
      } else if (type == HistoryActionType.reactivation) {
        id = (json['iD_Reactivation_Sim'] ?? json['id'])?.toString() ?? '';
      } else {
         id = (json['iD_Mise_A_Jour_Client'] ?? json['id'])?.toString() ?? '';
      }

      // Date
      DateTime date = DateTime.now();
      final dateStr = json['dateActivation'] ?? json['dateReactivation'] ?? json['dateMiseAJour'] ?? json['createDate'];
      if (dateStr != null) {
        date = DateTime.tryParse(dateStr) ?? DateTime.now();
      }

      // Nom Complet
      final nom = json['noms'] ?? '';
      final prenom = json['prenoms'] ?? '';
      final fullName = '$nom $prenom'.trim();

      // Info (Profession ou autre)
      final info = json['profession'] ?? json['numeroPiece'] ?? 'Aucune info';

      // Status (etat: 0 -> ? on assume 1 (Actif) par défaut si 0)
      final etat = json['etat'] ?? 1;
      // Mapping simple: 0=En attente/Inconnu, 1=Actif, 2=Suspendu ? 
      // Le user n'a pas précisé, on utilise fromCode qui a des fallbacks.
      final status = HistoryStatus.fromCode(etat is int ? etat : 1); 

      return HistoryItem(
        id: id,
        msisdn: json['msisdn']?.toString() ?? 'Inconnu',
        clientName: fullName.isNotEmpty ? fullName : 'Client Inconnu',
        info: info.toString(),
        operationDate: date,
        status: status,
        type: type,
      );
    }).toList();
  }
}
