import '../models/project.dart';
import '../services/api_service.dart';

class ProjectRepository {
  final ApiService api;

  ProjectRepository({ApiService? apiService}) : api = apiService ?? ApiService();

  Future<List<Project>> fetchProjects(String token) async {
    final data = await api.get('/projects', token: token);
    return (data as List).map((json) => Project.fromJson(json)).toList();
  }

  Future<Project> addProject(Map<String, dynamic> payload, String token) async {
    final data = await api.post('/projects', payload, token: token);
    return Project.fromJson(data);
  }
}
