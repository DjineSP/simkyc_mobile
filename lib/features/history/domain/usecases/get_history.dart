import '../entities/history_item.dart';
import '../repositories/history_repository.dart';
// Assurez-vous d'importer la classe DateTimeRangeFilter si elle est personnalisée, 
// sinon utilisez DateTimeRange de flutter/material.dart

class GetHistory {
  final HistoryRepository repository;

  GetHistory(this.repository);

  Future<List<HistoryItem>> call({
    required int offset,
    required int limit,
    String query = '',
    dynamic dateRange, // DateTimeRangeFilter? ou DateTimeRange?
    HistoryActionType? filterType, // Nouveau paramètre pour le filtre "Tous", "Activation", etc.
  }) {
    return repository.fetchHistory(
      offset: offset,
      limit: limit,
      query: query,
      dateRange: dateRange,
      filterType: filterType,
    );
  }
}
