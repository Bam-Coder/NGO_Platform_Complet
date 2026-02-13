import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String tokenBoxName = 'auth_tokens';
  static const String userBoxName = 'user_data';
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(tokenBoxName);
    await Hive.openBox(userBoxName);
  }

  static Future<void> saveToken(String token) async {
    final box = Hive.box(tokenBoxName);
    await box.put(tokenKey, token);
  }

  static String? getToken() {
    final box = Hive.box(tokenBoxName);
    return box.get(tokenKey) as String?;
  }

  static Future<void> deleteToken() async {
    final box = Hive.box(tokenBoxName);
    await box.delete(tokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final box = Hive.box(userBoxName);
    await box.put(userKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    final box = Hive.box(userBoxName);
    final data = box.get(userKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> deleteUserData() async {
    final box = Hive.box(userBoxName);
    await box.delete(userKey);
  }

  static Future<void> clearAll() async {
    await deleteToken();
    await deleteUserData();
  }
}
