import 'package:flutter/material.dart';
import '../models/impact_report.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository repository = ReportRepository();
  List<ImpactReport> reports = [];
  bool loading = false;

  Future<void> loadReports(String token, {Set<int>? allowedProjectIds}) async {
    loading = true;
    notifyListeners();
    try {
      final all = await repository.fetchReports(token);
      if (allowedProjectIds != null && allowedProjectIds.isNotEmpty) {
        reports =
            all.where((r) => allowedProjectIds.contains(r.projectId)).toList();
      } else {
        reports = all;
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des rapports: $e");
      reports = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> addReport(ImpactReport report, String token) async {
    try {
      final result = await repository.addReport(report, token);
      if (result) {
        reports.add(report);
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint("Erreur lors de l'ajout du rapport: $e");
      return false;
    }
  }
}
