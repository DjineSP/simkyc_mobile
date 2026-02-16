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

/// Statut de l'opération
enum HistoryStatus {
  pending(0, 'En attente', Colors.orange),
  active(1, 'Activé', Colors.green),
  suspended(2, 'Suspendu', Colors.red);

  final int code;
  final String label;
  final Color color;
  const HistoryStatus(this.code, this.label, this.color);

  static HistoryStatus fromCode(int code) {
    return HistoryStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => HistoryStatus.pending,
    );
  }
}

class HistoryItem {
  final String id; // Utile pour le bouton "Détails"
  final String msisdn;
  final String clientName;
  final String info; // Information principale
  final DateTime operationDate;
  final HistoryStatus status;
  final HistoryActionType type; // Pour savoir de quelle source cela vient
  final HistoryDetail? details;

  HistoryItem({
    required this.id,
    required this.msisdn,
    required this.clientName,
    required this.info,
    required this.operationDate,
    required this.status,
    required this.type,
    this.details,
  });
}
