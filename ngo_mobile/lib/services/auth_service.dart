import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../core/constants.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final String _baseUrl = ApiConstants.baseUrl;
  static String? authToken;

  // Récupérer le token sauvegardé au démarrage
  static Future<String?> getSavedToken() async {
    return StorageService.getToken();
  }

  // Vérifier si le token est encore valide
  static bool isTokenValid(String token) {
    try {
      final decodedToken = Jwt.parseJwt(token);
      final expiryTime = decodedToken['exp'] as int?;
      if (expiryTime == null) return false;
      
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now < expiryTime;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      authToken = token;

      // Sauvegarder le token
      await StorageService.saveToken(token);

      // Décodage du token
      final Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

      int toInt(dynamic value) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      // Créer l'objet User
      final user = User(
        id: toInt(decodedToken['sub']),
        role: decodedToken['role'] ?? 'AGENT',
        email: email,
      );

      // Sauvegarder les données utilisateur
      await StorageService.saveUserData({
        'id': user.id,
        'email': user.email,
        'role': user.role,
      });

      return {'token': authToken, 'user': user};
    } else {
      throw Exception('Failed to login. Status: ${response.statusCode} - Body: ${response.body}');
    }
  }


  Future<void> logout() async {
    authToken = null;
    await StorageService.clearAll();
  }
}
