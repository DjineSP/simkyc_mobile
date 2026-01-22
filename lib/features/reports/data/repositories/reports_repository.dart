import 'dart:async';

import '../models/reports_data.dart';

class ReportsRepository {
  Future<ReportsData> fetchReports({required DateTime start, required DateTime end}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final days = end.difference(start).inDays + 1;

    final activations = 12 + (days * 4);
    final reactivations = 3 + (days * 2);
    final newCustomers = 5 + (days * 3);

    return ReportsData(
      activations: activations,
      reactivations: reactivations,
      newCustomers: newCustomers,
      reasons: {
        ReportReasonType.customer: 2 + days,
        ReportReasonType.simChange: 1 + (days ~/ 2),
        ReportReasonType.tech: (days / 3).ceil(),
        ReportReasonType.fraud: (days / 7).ceil(),
        ReportReasonType.other: 1,
      },
    );
  }
}
