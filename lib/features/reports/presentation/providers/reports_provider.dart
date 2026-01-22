import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reports_data.dart';
import '../../data/repositories/reports_repository.dart';

class ReportsState {
  final ReportsData? data;
  final bool isLoading;
  final String? error;
  final DateTime start;
  final DateTime end;

  const ReportsState({
    required this.data,
    required this.isLoading,
    required this.error,
    required this.start,
    required this.end,
  });

  factory ReportsState.initial() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return ReportsState(
      data: null,
      isLoading: true,
      error: null,
      start: start,
      end: end,
    );
  }

  ReportsState copyWith({
    ReportsData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
    DateTime? start,
    DateTime? end,
  }) {
    return ReportsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class ReportsNotifier extends Notifier<ReportsState> {
  @override
  ReportsState build() {
    final initial = ReportsState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> setDateRange({required DateTime start, required DateTime end}) async {
    state = state.copyWith(start: start, end: end);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(reportsRepositoryProvider);
      final data = await repo.fetchReports(start: state.start, end: state.end);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

final reportsProvider = NotifierProvider<ReportsNotifier, ReportsState>(() {
  return ReportsNotifier();
});
