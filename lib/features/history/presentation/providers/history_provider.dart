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
    // Initial: Last 30 days
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    final initialRange = DateTimeRangeFilter(start: start, end: end);
    
    // Initial state with date range set
    state = HistoryState.initial().copyWith(dateRange: initialRange);
    
    Future.microtask(_loadData);
    return state;
  }

  Future<void> setQuery(String query) async {
    state = state.copyWith(query: query);
    _applyFilters();
  }

  Future<void> setDateRange(DateTimeRange? range) async {
    if (range == null) {
      // Revert to default 30 days if cleared (though UI might not allow clearing to null if we enforce it)
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      state = state.copyWith(dateRange: DateTimeRangeFilter(start: start, end: end));
    } else {
      state = state.copyWith(
        dateRange: DateTimeRangeFilter(start: range.start, end: range.end),
      );
    }
    // Date change triggers fetch
    await _loadData();
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

  Future<void> loadMore() async {
    state = state.copyWith(hasMore: false);
  }

  Future<void> _loadData() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: false, 
    );

    try {
      final repo = ref.read(historyRepositoryProvider);
      
      final start = state.dateRange!.start;
      final end = state.dateRange!.end;
      
      // Fetch with specific dates
      _allItems = await repo.getHistory(startDate: start, endDate: end);
      
      // Apply local filters (Query, Type)
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

    // Date filtering is handled by the API now.
    // However, if we want to be extra sure or handle hour precision, we could filter.
    // But typically API handles it.
    
    // Sort
    filtered.sort((a, b) => b.operationDate.compareTo(a.operationDate));

    state = state.copyWith(
      items: filtered,
      isLoading: false,
      hasMore: false,
    );
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl();
});

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});

// Removed historyDetailProvider as details are now passed directly
