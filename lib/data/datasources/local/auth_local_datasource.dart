import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/auth/user_model.dart';
import '../../../core/error/app_exceptions.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _keyUser = 'cached_user';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  AuthLocalDataSource(this._storage);

  Future<void> saveUser(UserModel user) async {
    await Future.wait([
      _storage.write(key: _keyUser, value: jsonEncode(user.toJson())),
      _storage.write(key: _keyAccessToken, value: user.accessToken),
      _storage.write(key: _keyRefreshToken, value: user.refreshToken),
    ]);
  }

  Future<UserModel?> getUser() async {
    try {
      final raw = await _storage.read(key: _keyUser);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException(message: 'Failed to read cached user.');
    }
  }

  Future<void> clearUser() async {
    await Future.wait([
      _storage.delete(key: _keyUser),
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }
}
