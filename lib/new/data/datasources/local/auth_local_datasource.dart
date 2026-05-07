// lib/data/datasources/local/auth_local_datasource.dart
import 'dart:convert';
import 'package:synquerra/new/data/models/user_model.dart';
import 'secure_storage_service.dart';

class AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  AuthLocalDataSource({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  /// Save user data to secure storage
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.saveUserData(userJson);
    await _secureStorage.saveTokens(user.accessToken, user.refreshToken);
  }

  /// Get user data from secure storage
  Future<UserModel?> getUser() async {
    final userJson = await _secureStorage.getUserData();
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  /// Clear all user data (logout)
  Future<void> clearUserData() async {
    await _secureStorage.clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _secureStorage.isAuthenticated();
  }
}
