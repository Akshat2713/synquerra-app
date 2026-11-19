import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api_constants.dart';
import '../session_expired_notifier.dart';

/// Handles 401s: refreshes the access token once, retries the failed request,
/// and signs the user out locally if the refresh token is rejected.
class TokenRefreshInterceptor extends Interceptor {
  static const _retriedKey = 'token_refresh_retried';

  final Dio _dio; // main client, used to retry the original request
  final Dio _refreshDio; // bare client (no interceptors) for the refresh call
  final FlutterSecureStorage _storage;
  final SessionExpiredNotifier _notifier;

  Completer<bool>? _refreshing;

  TokenRefreshInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required FlutterSecureStorage storage,
    required SessionExpiredNotifier notifier,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _storage = storage,
       _notifier = notifier;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;

    if (err.response?.statusCode != 401 || !_shouldRefresh(options)) {
      return handler.next(err);
    }

    // Already retried once with a fresh token and still 401 -> give up.
    if (options.extra[_retriedKey] == true) {
      await _forceLogout();
      return handler.next(err);
    }

    final sentToken = _extractToken(options.headers['Authorization']);
    final currentToken = await _storage.read(key: 'access_token');

    // Another request already refreshed while this one was in flight.
    final alreadyRefreshed =
        currentToken != null && sentToken != null && currentToken != sentToken;

    final ok = alreadyRefreshed ? true : await _refreshOnce();
    if (!ok) return handler.next(err);

    try {
      final response = await _retry(options);
      handler.resolve(response);
    } on DioException catch (e) {
      // Already processed by the other interceptors during the retry.
      handler.reject(e);
    }
  }

  bool _shouldRefresh(RequestOptions options) {
    final path = options.path;
    if (path.contains(ApiConstants.signIn) ||
        path.contains(ApiConstants.orgMemberSignIn) ||
        path.contains(ApiConstants.refreshToken) ||
        path.contains(ApiConstants.signOut)) {
      return false;
    }
    // Only requests that actually carried a token can be "expired".
    return options.headers.containsKey('Authorization');
  }

  String? _extractToken(dynamic header) {
    if (header is! String) return null;
    return header.startsWith('Bearer ') ? header.substring(7) : header;
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final newToken = await _storage.read(key: 'access_token');
    final headers = Map<String, dynamic>.from(options.headers)
      ..['Authorization'] = 'Bearer $newToken';

    return _dio.fetch<dynamic>(
      options.copyWith(
        headers: headers,
        extra: {...options.extra, _retriedKey: true},
      ),
    );
  }

  /// Single-flight: concurrent callers await the same refresh.
  Future<bool> _refreshOnce() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshing = completer;

    _doRefresh()
        .then(completer.complete)
        .catchError((_) => completer.complete(false))
        .whenComplete(() => _refreshing = null);

    return completer.future;
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) {
      await _forceLogout();
      return false;
    }

    try {
      final response = await _refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken}, // ASSUMED body
      );

      final body = response.data;
      if (body is! Map || body['status'] != 'success') {
        await _forceLogout();
        return false;
      }

      final payload = body['data'] is Map ? body['data'] as Map : body;
      final newAccess = payload['access_token'] as String?;
      final newRefresh = payload['refresh_token'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        await _forceLogout();
        return false;
      }

      await _saveTokens(newAccess, newRefresh ?? refreshToken);
      return true;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // Server explicitly rejected the refresh token -> sign out.
      if (code == 400 || code == 401 || code == 403) {
        await _forceLogout();
      }
      // Timeout / offline / 5xx: keep the session, let the error surface.
      return false;
    }
  }

  Future<void> _saveTokens(String access, String refresh) async {
    await Future.wait([
      _storage.write(key: 'access_token', value: access),
      _storage.write(key: 'refresh_token', value: refresh),
    ]);

    // Keep the cached user JSON in sync (it also stores the tokens).
    try {
      final raw = await _storage.read(key: 'cached_user');
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        map['accessToken'] = access;
        map['refreshToken'] = refresh;
        await _storage.write(key: 'cached_user', value: jsonEncode(map));
      }
    } catch (_) {}
  }

  Future<void> _forceLogout() async {
    try {
      await Future.wait([
        _storage.delete(key: 'cached_user'),
        _storage.delete(key: 'access_token'),
        _storage.delete(key: 'refresh_token'),
        _storage.delete(key: 'person_id'),
        _storage.delete(key: 'last_sent_fcm_token'),
      ]);
    } catch (_) {}
    _notifier.notify();
  }
}
