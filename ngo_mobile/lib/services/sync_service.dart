import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import '../models/impact_report.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'upload_service.dart';

/// Service centralisé pour la gestion du offline & synchronisation.
///
/// - Stocke les dépenses et rapports en attente dans Hive
/// - Tente de les renvoyer quand la connexion est disponible
/// - Fournit un compteur simple pour l'UI (SyncStatusWidget)
class SyncService {
  static bool _syncInProgress = false;
  static const String _offlineExpensesBox = 'offline_expenses';
  static const String _offlineReportsBox = 'offline_reports';

  static Box<Map>? _expensesBox;
  static Box<Map>? _reportsBox;

  static final ApiService _api = ApiService();
  static Future<String?> _ensureRemoteExpenseReceipts(String? value) async {
    if (value == null || value.isEmpty) return value;
    final receipts = Expense.decodeReceiptUrls(value);
    if (receipts.isEmpty) return value;
    final List<String> uploaded = [];
    for (final r in receipts) {
      if (UploadService.isRemoteUrl(r)) {
        uploaded.add(r);
      } else {
        uploaded.add(await UploadService.uploadImageFile(File(r)));
      }
    }
    return Expense.encodeReceiptUrls(uploaded);
  }

  static Future<List<String>> _ensureRemotePhotos(List<String> photos) async {
    if (photos.isEmpty) return photos;
    final List<String> out = [];
    for (final p in photos) {
      if (UploadService.isRemoteUrl(p)) {
        out.add(p);
      } else {
        out.add(await UploadService.uploadImageFile(File(p)));
      }
    }
    return out;
  }

  /// À appeler au démarrage de l'app (après Hive.initFlutter)
  static Future<void> init() async {
    _expensesBox ??= await Hive.openBox<Map>(_offlineExpensesBox);
    _reportsBox ??= await Hive.openBox<Map>(_offlineReportsBox);
  }

  /// Nombre total d'éléments en attente de synchronisation.
  static int getPendingCount() {
    final int expenses = _expensesBox?.length ?? 0;
    final int reports = _reportsBox?.length ?? 0;
    return expenses + reports;
  }

  /// Ajoute une dépense à la file offline.
  static Future<void> queueExpense(Expense expense) async {
    if (_expensesBox == null) return;

    await _expensesBox!.add({
      'projectId': expense.projectId,
      'budgetCategoryId': expense.budgetCategoryId,
      'data': expense.toJsonForCreate(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Ajoute un rapport à la file offline.
  static Future<void> queueImpactReport(ImpactReport report) async {
    if (_reportsBox == null) return;

    await _reportsBox!.add({
      'projectId': report.projectId,
      'data': report.toJson(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Tente de synchroniser toutes les dépenses & rapports en attente.
  ///
  /// Retourne true si au moins un élément a été synchronisé avec succès.
  static Future<bool> syncAll() async {
    if (_syncInProgress) return false;
    _syncInProgress = true;
    String? token = AuthService.authToken;
    if (token == null || token.isEmpty) {
      token = await AuthService.getSavedToken();
      if (token != null && token.isNotEmpty) {
        AuthService.authToken = token;
      }
    }
    if (token == null || token.isEmpty) {
      _syncInProgress = false;
      return false;
    }

    bool hasSuccess = false;
    try {

    // Synchroniser les dépenses
    if (_expensesBox != null && _expensesBox!.isNotEmpty) {
      final keys = _expensesBox!.keys.toList(growable: false);
      for (final key in keys) {
        final Map? raw = _expensesBox!.get(key);
        if (raw == null) continue;

        try {
          final int projectId = raw['projectId'] as int;
          final int budgetCategoryId = raw['budgetCategoryId'] as int;
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(raw['data'] as Map);

          final String? receiptUrl =
              await _ensureRemoteExpenseReceipts(data['receiptUrl'] as String?);

          // Reconstruire l'objet Expense pour réutiliser l'API centrale
          final Expense expense = Expense(
            amount: (data['amount'] as num).toDouble(),
            description: data['description'] as String? ?? '',
            projectId: projectId,
            budgetCategoryId: budgetCategoryId,
            date: DateTime.parse(data['date'] as String),
            receiptUrl: receiptUrl,
            gpsLat: (data['gpsLat'] as num?)?.toDouble(),
            gpsLng: (data['gpsLng'] as num?)?.toDouble(),
          );

          final bool ok = await _api.addExpense(expense);
          if (ok) {
            await _expensesBox!.delete(key);
            hasSuccess = true;
          }
        } catch (e) {
          debugPrint('Erreur de sync dépense offline: $e');
          // On garde dans la box pour réessayer plus tard
        }
      }
    }

    // Synchroniser les rapports
    if (_reportsBox != null && _reportsBox!.isNotEmpty) {
      final keys = _reportsBox!.keys.toList(growable: false);
      for (final key in keys) {
        final Map? raw = _reportsBox!.get(key);
        if (raw == null) continue;

        try {
          final int projectId = raw['projectId'] as int;
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(raw['data'] as Map);

          final List<String> photos =
              await _ensureRemotePhotos((data['photos'] as List?)?.cast<String>() ?? const []);

          final ImpactReport report = ImpactReport(
            projectId: projectId,
            title: data['title'] as String? ?? '',
            description: data['description'] as String? ?? '',
            beneficiariesCount: (data['beneficiariesCount'] as num).toInt(),
            activitiesDone: data['activitiesDone'] as String? ?? '',
            photos: photos,
            gpsLat: (data['gpsLat'] as num?)?.toDouble(),
            gpsLng: (data['gpsLng'] as num?)?.toDouble(),
            date: DateTime.parse(data['date'] as String),
          );

          final bool ok = await _api.addImpactReport(report);
          if (ok) {
            await _reportsBox!.delete(key);
            hasSuccess = true;
          }
        } catch (e) {
          debugPrint('Erreur de sync rapport offline: $e');
        }
      }
    }

    return hasSuccess;
    } finally {
      _syncInProgress = false;
    }
  }
}
