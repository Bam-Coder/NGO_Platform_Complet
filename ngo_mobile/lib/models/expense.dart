import 'dart:convert';

import '../core/media_url.dart';

class Expense {
  final int? id;
  final double amount;
  final String description;
  final int projectId;
  final String? projectName;
  final int budgetCategoryId;
  final String? budgetCategoryName;
  final DateTime date;
  final DateTime? createdAt;
  final String? receiptUrl;
  final double? gpsLat;
  final double? gpsLng;
  final String? status;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.projectId,
    this.projectName,
    required this.budgetCategoryId,
    this.budgetCategoryName,
    required this.date,
    this.createdAt,
    this.receiptUrl,
    this.gpsLat,
    this.gpsLng,
    this.status,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Safe type conversion helpers
    double safeDouble(dynamic value) => value is String ? (double.tryParse(value) ?? 0.0) : (value as num? ?? 0).toDouble();
    int safeInt(dynamic value) => value is String ? (int.tryParse(value) ?? 0) : (value as num? ?? 0).toInt();

    final project = json['project'];
    final budget = json['budget'];
    final projectIdValue =
        json['projectId'] ?? (project is Map ? project['id'] : null);
    final projectNameValue = project is Map ? project['name'] : null;
    final budgetIdValue =
        json['budgetCategoryId'] ?? (budget is Map ? budget['id'] : null);
    final budgetCategoryValue = budget is Map
        ? budget['category']
        : (json['budgetCategoryName'] ?? json['category']);
    String? categoryName(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        final dynamic nested =
            value['category'] ?? value['name'] ?? value['label'];
        return categoryName(nested);
      }
      if (value is String) return value;
      return value.toString();
    }

    return Expense(
      id: json['id'] != null ? safeInt(json['id']) : null,
      amount: safeDouble(json['amount']),
      description: json['description'] ?? '',
      projectId: safeInt(projectIdValue),
      projectName: projectNameValue is String ? projectNameValue : null,
      budgetCategoryId: safeInt(budgetIdValue),
      budgetCategoryName: categoryName(budgetCategoryValue),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      receiptUrl: json['receiptUrl']?.toString(),
      gpsLat: json['gpsLat'] != null ? safeDouble(json['gpsLat']) : null,
      gpsLng: json['gpsLng'] != null ? safeDouble(json['gpsLng']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'projectId': projectId,
      'budgetCategoryId': budgetCategoryId,
      'date': date.toIso8601String().substring(0, 10),
      'receiptUrl': receiptUrl,
      'gpsLat': gpsLat,
      'gpsLng': gpsLng,
    };
  }

  // Pour la création, les IDs ne sont pas dans le body
  Map<String, dynamic> toJsonForCreate() {
    return {
      'projectId': projectId,
      'budgetCategoryId': budgetCategoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String().substring(0, 10),
      'receiptUrl': receiptUrl,
      'gpsLat': gpsLat,
      'gpsLng': gpsLng,
    };
  }

  static String? encodeReceiptUrls(List<String> urls) {
    final cleaned = urls.where((u) => u.trim().isNotEmpty).toList(growable: false);
    if (cleaned.isEmpty) return null;
    if (cleaned.length == 1) return cleaned.first;
    return jsonEncode(cleaned);
  }

  static List<String> decodeReceiptUrls(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    final value = raw.trim();
    if (value.startsWith('[')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded
              .map((e) => normalizeMediaUrl(e?.toString()))
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }
    final normalized = normalizeMediaUrl(value);
    if (normalized == null || normalized.isEmpty) return const [];
    return [normalized];
  }
}
