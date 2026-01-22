import 'dart:async';

import '../models/history_item.dart';

class HistoryRepository {
  Future<List<HistoryItem>> fetchHistory({
    required int offset,
    required int limit,
    String query = '',
    DateTimeRangeFilter? dateRange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final all = List.generate(
      240,
      (index) {
        final createdAt = DateTime.now().subtract(Duration(
          days: index % 60,
          hours: index % 24,
          minutes: (index * 7) % 60,
        ));
        return HistoryItem(
          id: 'hist_${index + 1}',
          name: 'Client ${index + 1}',
          msisdn: '6${(90000000 + index).toString()}',
          idNumber: 'CM${1000 + index}',
          statusIndex: index % 3,
          createdAt: createdAt,
        );
      },
    )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final q = query.trim().toLowerCase();

    bool matchesDate(HistoryItem item) {
      final r = dateRange;
      if (r == null) return true;
      return !item.createdAt.isBefore(r.start) && !item.createdAt.isAfter(r.end);
    }

    final filtered = all.where((item) {
      final matchesText = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.msisdn.contains(q) ||
          item.idNumber.toLowerCase().contains(q);
      return matchesText && matchesDate(item);
    }).toList();

    final start = offset;
    if (start >= filtered.length) return <HistoryItem>[];

    final end = (start + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }
}

class DateTimeRangeFilter {
  final DateTime start;
  final DateTime end;

  DateTimeRangeFilter({required this.start, required this.end});
}
