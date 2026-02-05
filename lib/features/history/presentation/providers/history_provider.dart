import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/history_repository.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/history_detail.dart';
import '../../domain/repositories/history_repository.dart';

// Cette classe semble être un filtre personnalisé, nous la conservons pour la compatibilité.
class DateTimeRangeFilter { final DateTime start; final DateTime end; const DateTimeRangeFilter({required this.start, required this.end}); }
class HistoryState {
  final List<HistoryItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final DateTimeRangeFilter? dateRange;
  final HistoryActionType? filterType;

  const HistoryState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.query,
    required this.dateRange,
    this.filterType,
  });

  factory HistoryState.initial() => const HistoryState(
        items: <HistoryItem>[],
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        query: '',
        dateRange: null,
        filterType: null,
      );

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    DateTimeRangeFilter? dateRange,
    HistoryActionType? filterType,
    bool clearDateRange = false,
    bool clearFilterType = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  // Cache local de toutes les données chargées
  List<HistoryItem> _allItems = [];

  @override
  HistoryState build() {
    final initial = HistoryState.initial();
    Future.microtask(_loadData);
    return initial;
  }

  Future<void> setQuery(String query) async {
    state = state.copyWith(query: query);
    _applyFilters();
  }

  Future<void> setDateRange(DateTimeRange? range) async {
    if (range == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(
        dateRange: DateTimeRangeFilter(start: range.start, end: range.end),
      );
    }
    _applyFilters();
  }

  Future<void> setFilterType(HistoryActionType? type) async {
    if (type == null) {
      state = state.copyWith(clearFilterType: true);
    } else {
      state = state.copyWith(filterType: type);
    }
    _applyFilters();
  }

  Future<void> refresh() => _loadData();

  // La pagination n'est plus nécessaire côté serveur car on a tout,
  // mais on peut simuler ou retirer loadMore si l'UI le demande.
  Future<void> loadMore() async {
    // Avec le filtrage local complet, loadMore n'a plus vraiment de sens sauf si on pagine localement.
    // Pour l'instant on laisse vide ou on marque comme "fin".
    state = state.copyWith(hasMore: false);
  }

  Future<void> _loadData() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: false, // On charge tout d'un coup
    );

    try {
      final repo = ref.read(historyRepositoryProvider);
      // On charge TOUT
      _allItems = await repo.getAllHistory();
      
      // On applique les filtres initiaux
      _applyFilters();
    } catch (_) {
      state = state.copyWith(isLoading: false, items: []);
    }
  }

  void _applyFilters() {
    var filtered = List<HistoryItem>.from(_allItems);

    // 1. Filter by Type
    if (state.filterType != null) {
      filtered = filtered.where((item) => item.type == state.filterType).toList();
    }

    // 2. Filter by Query
    if (state.query.isNotEmpty) {
      final q = state.query.toLowerCase();
      filtered = filtered.where((item) =>
          item.msisdn.contains(q) ||
          item.clientName.toLowerCase().contains(q)).toList();
    }

    // 3. Filter by Date
    if (state.dateRange != null) {
      final start = state.dateRange!.start;
      final end = state.dateRange!.end;
      filtered = filtered.where((item) {
        return item.operationDate.isAfter(start.subtract(const Duration(days: 1))) &&
               item.operationDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Sort (Already sorted by repo but good to ensure)
    // filtered.sort((a, b) => b.operationDate.compareTo(a.operationDate));

    state = state.copyWith(
      items: filtered,
      isLoading: false,
      hasMore: false, // Tout est chargé
    );
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  // Injection de l'implémentation concrète du repository.
  return HistoryRepositoryImpl();
});

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});

final historyDetailProvider = FutureProvider.family<HistoryDetail?, ({String id, HistoryActionType type})>((ref, arg) async {
  final repo = ref.read(historyRepositoryProvider);
  return await repo.getHistoryDetail(arg.id, arg.type);
});
