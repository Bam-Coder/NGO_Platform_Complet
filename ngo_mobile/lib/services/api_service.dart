import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/expense.dart';
import '../models/impact_report.dart';
import '../models/budget.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class ApiService {
  final String _baseUrl = ApiConstants.baseUrl;
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = _headers(token: token);
    late http.Response response;

    try {
      if (method == 'GET') {
        response = await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 20));
      } else if (method == 'POST') {
        response = await _client
            .post(uri, headers: headers, body: json.encode(data ?? const {}))
            .timeout(const Duration(seconds: 20));
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }
    } on TimeoutException {
      throw Exception('Request timeout for $endpoint');
    }

    final status = response.statusCode;
    if (status == 200 || status == 201) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    throw Exception(
      'Request failed ($method $endpoint). Status: $status, Body: ${response.body}',
    );
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    return _request('GET', endpoint, token: token);
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    return _request('POST', endpoint, data: data, token: token);
  }

  Future<List<Budget>> getBudgetsForProject(int projectId) async {
    final String? token = AuthService.authToken;
    if (token == null) return [];
    try {
      final data = await get('/budgets/project/$projectId', token: token);
      return (data as List).map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Erreur de chargement des budgets : $e");
      rethrow;
    }
  }

  Future<bool> addExpense(Expense expense, {String? token}) async {
    final String? authToken = token ?? AuthService.authToken;
    if (authToken == null || authToken.isEmpty) return false;

    final endpoint = '/expenses/${expense.projectId}/${expense.budgetCategoryId}';
    try {
      await post(endpoint, expense.toJsonForCreate(), token: authToken);
      return true;
    } catch (e) {
      debugPrint("Erreur lors de l'ajout de la dépense: $e");
      return false;
    }
  }

  Future<bool> addImpactReport(ImpactReport report, {String? token}) async {
    final String? authToken = token ?? AuthService.authToken;
    if (authToken == null || authToken.isEmpty) return false;

    final userData = StorageService.getUserData();
    final userId = userData?['id'];
    if (userId == null) {
      debugPrint("Impossible d'ajouter un rapport: utilisateur inconnu.");
      return false;
    }

    final endpoint = '/impact-reports/${report.projectId}/$userId';
    try {
      await post(endpoint, report.toJson(), token: authToken);
      return true;
    } catch (e) {
      debugPrint("Erreur lors de l'ajout du rapport: $e");
      return false;
    }
  }
}
