import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class UploadService {
  static bool isRemoteUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static bool isConfigured() {
    return true; // backend upload is always available if API is reachable
  }

  static Future<String> uploadImageFile(File file) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/uploads');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final token = AuthService.authToken ?? await AuthService.getSavedToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Upload failed: missing url');
    }
    return url;
  }
}
