import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/history_item.dart';
import '../../data/repositories/history_repository.dart';

class HistoryState {
  final List<HistoryItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final DateTimeRangeFilter? dateRange;

  const HistoryState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.query,
    required this.dateRange,
  });

  factory HistoryState.initial() => const HistoryState(
        items: <HistoryItem>[],
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        query: '',
        dateRange: null,
      );

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    DateTimeRangeFilter? dateRange,
    bool clearDateRange = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  static const _pageSize = 20;

  @override
  HistoryState build() {
    final initial = HistoryState.initial();
    Future.microtask(_refresh);
    return initial;
  }

  Future<void> setQuery(String query) async {
    state = state.copyWith(query: query);
    await _refresh();
  }

  Future<void> setDateRange(DateTimeRange? range) async {
    if (range == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(
        dateRange: DateTimeRangeFilter(start: range.start, end: range.end),
      );
    }
    await _refresh();
  }

  Future<void> refresh() => _refresh();

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repo = ref.read(historyRepositoryProvider);
      final next = await repo.fetchHistory(
        offset: state.items.length,
        limit: _pageSize,
        query: state.query,
        dateRange: state.dateRange,
      );

      state = state.copyWith(
        items: [...state.items, ...next],
        hasMore: next.length == _pageSize,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> _refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      items: <HistoryItem>[],
    );

    try {
      final repo = ref.read(historyRepositoryProvider);
      final first = await repo.fetchHistory(
        offset: 0,
        limit: _pageSize,
        query: state.query,
        dateRange: state.dateRange,
      );
      state = state.copyWith(
        items: first,
        isLoading: false,
        hasMore: first.length == _pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});
