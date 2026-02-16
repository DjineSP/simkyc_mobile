import '../../../../core/api/api_client.dart';
import '../models/reports_data.dart';

class ReportsRepository {
  Future<ReportsData> fetchReports({required DateTime start, required DateTime end}) async {
    try {
      // L'API ne semble pas supporter de filtre de date pour l'instant
      final response = await ApiClient.instance.dio.get('/api/Login/statistique');
      final data = response.data as Map<String, dynamic>;

      return ReportsData(
        activations: data['nombre_Activation'] ?? 0,
        reactivations: data['nombre_Reactivation'] ?? 0,
        updates: data['nombre_Mise_A_Jour'] ?? 0,
        reasons: {
          // Données simulées pour la répartition car l'API ne le fournit pas encore
          ReportReasonType.customer: 0,
          ReportReasonType.simChange: 0,
          ReportReasonType.tech: 0,
          ReportReasonType.fraud: 0,
          ReportReasonType.other: 0,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors du chargement des rapports');
    }
  }
}
