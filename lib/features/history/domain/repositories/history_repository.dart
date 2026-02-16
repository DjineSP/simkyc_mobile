import '../entities/history_item.dart';
import '../entities/history_detail.dart';

abstract class HistoryRepository {
  Future<List<HistoryItem>> getHistory({
    required DateTime startDate,
    required DateTime endDate,
  });
}
