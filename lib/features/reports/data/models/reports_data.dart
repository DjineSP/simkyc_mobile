enum ReportReasonType {
  customer,
  simChange,
  tech,
  fraud,
  other,
}

class ReportsData {
  final int activations;
  final int reactivations;
  final int newCustomers;
  final Map<ReportReasonType, int> reasons;

  const ReportsData({
    required this.activations,
    required this.reactivations,
    required this.newCustomers,
    required this.reasons,
  });
}
