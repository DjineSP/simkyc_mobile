import 'package:flutter/material.dart';
import 'history_detail.dart';

/// Type d'action pour le filtrage
enum HistoryActionType {
  activation('Activation'),
  reactivation('Réactivation'),
  update('Mise à jour');

  final String label;
  const HistoryActionType(this.label);
}


class HistoryItem {
  final String id; // Utile pour le bouton "Détails"
  final String msisdn;
  final String clientName;
  final String info; // Information principale
  final DateTime operationDate;
  final String? statut;
  final HistoryActionType type; // Pour savoir de quelle source cela vient
  final HistoryDetail? details;

  HistoryItem({
    required this.id,
    required this.msisdn,
    required this.clientName,
    required this.info,
    required this.operationDate,
    this.statut,
    required this.type,
    this.details,
  });
}
