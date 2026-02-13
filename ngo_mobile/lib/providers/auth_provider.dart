import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

class AuthProvider extends ChangeNotifier {
  User? user;
  String? token;
  bool isLoading = false;
  bool isInitialized = false;
  final AuthService authService = AuthService();

  // Initialiser à partir du token sauvegardé
  Future<void> initializeFromStorage() async {
    try {
      final savedToken = await AuthService.getSavedToken();
      if (savedToken != null && AuthService.isTokenValid(savedToken)) {
        token = savedToken;
        AuthService.authToken = token;
        
        // Récupérer les données utilisateur sauvegardées
        final userData = StorageService.getUserData();
        if (userData != null) {
          int toInt(dynamic value) {
            if (value is int) return value;
            if (value is num) return value.toInt();
            if (value is String) return int.tryParse(value) ?? 0;
            return 0;
          }
          user = User(
            id: toInt(userData['id']),
            email: userData['email'],
            role: userData['role'],
          );
        }
        await SyncService.syncAll();
      } else if (savedToken != null) {
        // Token expiré
        await logout();
      }
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation: $e");
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await authService.login(email, password);
      token = response['token'];
      user = response['user'];
      await SyncService.syncAll();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erreur de connexion: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    await authService.logout();
    user = null;
    token = null;
    notifyListeners();
  }

  bool get isAuthenticated => token != null && user != null;
}
