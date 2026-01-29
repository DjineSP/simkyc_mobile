import '../entities/history_item.dart';

abstract class HistoryRepository {
  Future<List<HistoryItem>> fetchHistory({
    required int offset,
    required int limit,
    String query = '',
    dynamic dateRange,
    HistoryActionType? filterType,
  });

  /// Récupère tout l'historique sans filtre ni pagination (pour le filtrage local)
  Future<List<HistoryItem>> getAllHistory();
}
