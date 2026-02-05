import 'package:flutter/material.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/history_detail.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _dataSource;

  HistoryRepositoryImpl({HistoryRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? HistoryRemoteDataSourceImpl();

  @override
  Future<List<HistoryItem>> fetchHistory({
    required int offset,
    required int limit,
    String query = '',
    dynamic dateRange,
    HistoryActionType? filterType,
  }) async {
    List<HistoryItem> allItems = [];

    // 1. Charger les données en parallèle depuis les 3 endpoints simulés
    final futures = <Future<List<HistoryItem>>>[];

    if (filterType == null || filterType == HistoryActionType.activation) {
      futures.add(_dataSource.getActivations());
    }
    if (filterType == null || filterType == HistoryActionType.reactivation) {
      futures.add(_dataSource.getReactivations());
    }
    if (filterType == null || filterType == HistoryActionType.update) {
      futures.add(_dataSource.getUpdates());
    }

    final results = await Future.wait(futures);
    for (final list in results) {
      allItems.addAll(list);
    }

    // 2. Filtrage local (Query)
    var filteredItems = allItems;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filteredItems = filteredItems
          .where((item) =>
              item.msisdn.contains(q) ||
              item.clientName.toLowerCase().contains(q))
          .toList();
    }

    // 3. Filtrage par Date (DateRange)
    if (dateRange != null) {
      // On gère les deux types (Flutter DateTimeRange et notre custom DateTimeRangeFilter)
      // On utilise 'dynamic' pour accéder aux propriétés start/end sans erreur de cast immédiate
      final start = (dateRange as dynamic).start as DateTime;
      final end = (dateRange as dynamic).end as DateTime;

      filteredItems = filteredItems.where((item) {
        return item.operationDate.isAfter(start.subtract(const Duration(days: 1))) &&
               item.operationDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }

    // 4. Tri global par date (du plus récent au plus ancien)
    filteredItems.sort((a, b) => b.operationDate.compareTo(a.operationDate));

    // 5. Pagination locale
    if (offset >= filteredItems.length) return [];
    final end = (offset + limit < filteredItems.length)
        ? offset + limit
        : filteredItems.length;

    return filteredItems.sublist(offset, end);
  }
  @override
  Future<List<HistoryItem>> getAllHistory() async {
    final futures = <Future<List<HistoryItem>>>[
      _dataSource.getActivations(),
      _dataSource.getReactivations(),
      _dataSource.getUpdates(),
    ];

    final results = await Future.wait(futures);
    List<HistoryItem> allItems = [];
    for (final list in results) {
      allItems.addAll(list);
    }
    // Tri par défaut (plus récent d'abord)
    allItems.sort((a, b) => b.operationDate.compareTo(a.operationDate));
    return allItems;
  }

  @override
  Future<HistoryDetail?> getHistoryDetail(String id, HistoryActionType type) async {
    switch (type) {
      case HistoryActionType.activation:
        return await _dataSource.getActivationDetail(id);
      case HistoryActionType.reactivation:
        return await _dataSource.getReactivationDetail(id);
      case HistoryActionType.update:
        return await _dataSource.getUpdateDetail(id);
    }
  }
}


