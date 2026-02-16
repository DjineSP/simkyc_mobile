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
  @override
  Future<List<HistoryItem>> getHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _dataSource.getHistory(startDate: startDate, endDate: endDate);
  }
}


