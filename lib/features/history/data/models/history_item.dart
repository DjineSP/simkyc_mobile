class HistoryItem {
  final String id;
  final String name;
  final String msisdn;
  final String idNumber;
  final int statusIndex;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    required this.name,
    required this.msisdn,
    required this.idNumber,
    required this.statusIndex,
    required this.createdAt,
  });
}
