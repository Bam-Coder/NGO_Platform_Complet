import '../models/impact_report.dart';
import '../services/api_service.dart';

class ReportRepository {
  final ApiService apiService;

  ReportRepository({ApiService? apiService}) : apiService = apiService ?? ApiService();

  Future<List<ImpactReport>> fetchReports(String token) async {
    final response = await apiService.get('/impact-reports', token: token);
    if (response is List) {
      return response.map((json) => ImpactReport.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> addReport(ImpactReport report, String token) async {
    return apiService.addImpactReport(report, token: token);
  }
}
