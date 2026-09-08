import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/auth/user_model.dart';
import '../../../core/error/app_exceptions.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;
  static const _keyUser = 'cached_user';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyPersonId = 'person_id';

  AuthLocalDataSource(this._storage);

  Future<void> saveUser(UserModel user) async {
    try {
      await Future.wait([
        _storage.write(key: _keyUser, value: jsonEncode(user.toJson())),
        _storage.write(key: _keyAccessToken, value: user.accessToken),
        _storage.write(key: _keyRefreshToken, value: user.refreshToken),
        _storage.write(key: _keyPersonId, value: user.personId),
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to save cached user: $e');
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final raw = await _storage.read(key: _keyUser);
      if (raw == null || raw.isEmpty) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // Return null instead of throwing to prevent accidental forced logout
    }
  }

  Future<String?> getPersonId() async {
    return _storage.read(key: _keyPersonId);
  }

  Future<void> clearUser() async {
    await Future.wait([
      _storage.delete(key: _keyUser),
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyPersonId),
    ]);
  }
}
