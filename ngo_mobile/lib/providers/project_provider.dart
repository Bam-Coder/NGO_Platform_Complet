import 'package:flutter/material.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository repository = ProjectRepository();
  List<Project> projects = [];
  bool loading = false;

  Future<void> loadProjects(String token, {int? userId}) async {
    loading = true;
    notifyListeners();
    try {
      final all = await repository.fetchProjects(token);
      if (userId != null) {
        final hasManager = all.any((p) => p.managerId != null);
        projects = hasManager
            ? all.where((p) => p.managerId == userId).toList()
            : all;
      } else {
        projects = all;
      }
    } catch (e) {
      // Ligne de débogage pour voir l'erreur exacte
      debugPrint("Erreur lors du chargement des projets: $e");
      projects = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addProject(Map<String, dynamic> payload, String token) async {
    final project = await repository.addProject(payload, token);
    projects.add(project);
    notifyListeners();
  }
}
